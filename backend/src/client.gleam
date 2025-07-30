/// OUR OWN GLEAM HTTP CLIENT

import gleam/erlang/charlist.{type Charlist}
import gleam/string
import gleam/io
import gleam/erlang/atom
import gleam/dynamic.{type Dynamic}

// Base FFI erlang compat types
type ErlHttpOption {
  Ssl(List(ErlSslOption))
  Autoredirect(Bool)
  Timeout(Int)
}

type BodyFormat {
  Binary
}

type ErlOption {
  BodyFormat(BodyFormat)
  SocketOpts(List(SocketOpt))
}

type SocketOpt {
  Ipfamily(Inet6fb4)
}

type Inet6fb4 {
  Inet6fb4
}

type ErlSslOption {
  Verify(ErlVerifyOption)
}

type ErlVerifyOption {
  VerifyNone
}

pub type ConnectError {
  Posix(code: String)
  TlsAlert(code: String, detail: String)
}

// ((version, status, status), headers, body)
type HttpOk = #(#(Charlist, Int, Charlist), List(#(Charlist, Charlist)), BitArray)

pub type HttpError {
  /// The response body contained non-UTF-8 data, but UTF-8 data was expected.
  InvalidUtf8Response
  /// It was not possible to connect to the host.
  FailedToConnect(ip4: ConnectError, ip6: ConnectError)
  /// The response was not received within the configured timeout period.
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

type HttpClient {
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
pub fn configure() -> Configuration {
  Builder(verify_tls: True, follow_redirects: False, timeout: 15_000)
}

}

// WIP
fn post(client: HttpClient, body: String) -> Result(HttpOk, HttpError) {
  post_erl(atom.create("post"), #(client.to, client.headers, "cnt-type", body), [], [])
}

fn new() -> HttpClient {
  HttpClient(charlist.from_string(""), [])
}

fn to(client: HttpClient, url: String) -> HttpClient {
  HttpClient(..client, to: charlist.from_string(url))
}

fn set_header(client: HttpClient, key: String, value: String) -> HttpClient {
  HttpClient(..client, headers: [#(charlist.from_string(key), charlist.from_string(value)), ..client.headers])
}

pub fn main() {
  let client = new()
  |> set_header("accept", "application/vnd.hmrc.1.0+json")
  |> set_header("content-type", "text/html")
  // change compat test
  |> set_header("content-type", "application/json")
  |> to("https://test-api.service.hmrc.gov.uk/hello/world")
  |> get()

  io.println(string.inspect(client))
}

pub fn configure() -> Configuration {
  Builder(verify_tls: True, follow_redirects: False, timeout: 30_000)
}

pub opaque type Configuration {
  Builder(
    // Default to true, unless explicitly set
    verify_tls: Bool,
    follow_redirects: Bool,
    timeout: Int,
  )
}

// ================================================================================================================================
// TEST FUNCTIONS - Inspirado nos tests do spibola -> TODO
//  ================================================================================================================================

