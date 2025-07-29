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

/// Erlang FFI def
@external(erlang, "httpc", "request")
fn get_erl(
  // In our case [get | post]
  method: atom.Atom,
  // [Url, Headers]
  request: #(Charlist, List(#(Charlist, Charlist))),
  // Omitted, no need
  http_options: List(ErlHttpOption),
  // Omitted, no need
  options: List(ErlOption)
) -> Result(HttpOk, HttpError)

@external(erlang, "httpc", "request")
fn post_erl(
  // In our case [get | post]
  method: atom.Atom,
  // [Url, Headers]
  request: #(Charlist, List(#(Charlist, Charlist)), String, String),
  // Omitted, no need
  http_options: List(Dynamic),
  // Omitted, no need
  options: List(Dynamic)
) -> Result(HttpOk, HttpError)

type HttpOk = #(#(String, Int, String), List(#(String, String)), String)
type HttpError = Dynamic

type HttpClient {
  HttpClient(
    to: Charlist,
    headers: List(#(Charlist, Charlist)),
  )
}

fn get(client: HttpClient) -> Result(HttpOk, HttpError) {
  get_erl(atom.create("get"), #(client.to, client.headers), [], [])
}

// WIP
fn post(client: HttpClient, body: String) -> Result(HttpOk, HttpError) {
  post_erl(atom.create("post"), #(client.to, client.headers, "cnt-type","body"), [], [])
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

