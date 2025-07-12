import gleam/bytes_tree
import gleam/erlang/process
import mist.{type Connection, type ResponseData}
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}

const index = "
  <html>
    <head>
      <title>noite</title>
    </head>
    <body>
      Hello, Rinha!
    </body>
  </html>
"

pub fn main() {
  let assert Ok(_) = {
    fn(req: Request(Connection)) -> Response(ResponseData) {
      case request.path_segments(req) {
        [] -> {
          response.new(200)
          |> response.set_body(mist.Bytes(bytes_tree.from_string(index)))
        }
        _ -> {
          response.new(404)
          |> response.set_body(mist.Bytes(bytes_tree.new()))
        }
      }
    }
  }
  |> mist.new
  |> mist.bind("localhost")
  |> mist.with_ipv6
  |> mist.port(3000)
  |> mist.start
    
  process.sleep_forever()
}
