import gleam/result
import gleam/list
import gleam/http
import gleam/http/response.{type Response, Response}
import gleam/erlang/charlist.{type Charlist}

// Base FFI erlang compat types
pub type ErlHttpOption {
  Ssl(List(ErlSslOption))
  Autoredirect(Bool)
  Timeout(Int)
}

pub type BodyFormat {
  Binary
}

pub type ErlOption {
  BodyFormat(BodyFormat)
  SocketOpts(List(SocketOpt))
}

pub type SocketOpt {
  Ipfamily(Inet6fb4)
}

pub type Inet6fb4 {
  Inet6fb4
}

pub type ErlSslOption {
  Verify(ErlVerifyOption)
}

pub type ErlVerifyOption {
  VerifyNone
}

pub type ConnectError {
  Posix(code: String)
  TlsAlert(code: String, detail: String)
}

// ((version, status, status), headers, body)
pub type HttpOk = #(#(Charlist, Int, Charlist), List(#(Charlist, Charlist)), BitArray)
pub type HttpError {
  InvalidUtf8Response
  FailedToConnect(ip4: ConnectError, ip6: ConnectError)
  ResponseTimeout
}

/// Erlang FFI def
@external(erlang, "httpc", "request")
fn get_erl(
  method: http.Method,
  request: #(Charlist, List(#(Charlist, Charlist))),
  http_options: List(ErlHttpOption),
  options: List(ErlOption)
) -> Result(HttpOk, HttpError)

@external(erlang, "httpc", "request")
fn post_erl(
  method: http.Method,
  request: #(Charlist, List(#(Charlist, Charlist)), Charlist, Charlist),
  http_options: List(ErlHttpOption),
  options: List(ErlOption)
) -> Result(HttpOk, HttpError)

pub type HttpClient {
  HttpClient(
    to: Charlist,
    config: Configuration,
    headers: List(#(Charlist, Charlist)),
    erl_http_options: List(ErlHttpOption),
    erl_options: List(ErlOption),
  )
}

pub opaque type Configuration {
  Builder(
    // Default to true, unless explicitly set
    verify_tls: Bool,
    follow_redirects: Bool,
    timeout: Int,
  )
}

/// Default client configuration
fn configure() -> Configuration {
  Builder(verify_tls: True, follow_redirects: False, timeout: 30_000)
}

pub fn get(client: HttpClient) -> Result(Response(BitArray), HttpError) {
  let assert Ok(resp) =
    get_erl(
      http.Get,
      #(client.to, client.headers),
      client.erl_http_options,
      client.erl_options
    )

  let #(#(_version, status, _status), headers, body) = resp
  Ok(Response(status, list.map(headers, string_headers), body))
}

pub fn post(client: HttpClient, body: String) -> Result(Response(BitArray), HttpError) {
    let content_type =
        list.find(
          client.headers,
          fn(header) {
            let #(k, _) = header

            charlist.to_string(k) == "Content-Type" || charlist.to_string(k) == "content-type"
        })
        |> result.try(fn(header) { let #(_, v) = header Ok(v) })
        |> result.unwrap(charlist.from_string("application/json"))

    let assert Ok(resp) =
      post_erl(
        http.Post,
        #(client.to, client.headers, content_type, charlist.from_string(body)),
        client.erl_http_options,
        client.erl_options
      )

    let #(#(_version, status, _status), headers, body) = resp
    Ok(Response(status, list.map(headers, string_headers), body))
}

pub fn new() -> HttpClient {
  let config = configure()

  let erl_http_options = [
    Autoredirect(config.follow_redirects),
    Timeout(config.timeout),
  ]
  let erl_options = [BodyFormat(Binary), SocketOpts([Ipfamily(Inet6fb4)])]

  HttpClient(
    charlist.from_string(""),
    config,
    [],
    erl_http_options,
    erl_options
  )
}

pub fn to(client: HttpClient, url: String) -> HttpClient {
  HttpClient(..client, to: charlist.from_string(url))
}

pub fn set_header(client: HttpClient, key: String, value: String) -> HttpClient {
  HttpClient(..client, headers: [#(charlist.from_string(key), charlist.from_string(value)), ..client.headers])
}

// fn set_http_option(client: HttpClient, opt: ErlHttpOption) -> HttpClient {}
// fn set_req_option(client: HttpClient, opt: ErlOption) -> HttpClient {}

fn string_headers(header: #(Charlist, Charlist)) -> #(String, String) {
  let #(k, v) = header
  #(charlist.to_string(k), charlist.to_string(v))
}
