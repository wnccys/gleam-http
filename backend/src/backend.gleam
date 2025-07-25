import gleam/string
import gleam/io
import gleam/httpc
import gleam/bytes_tree
import gleam/erlang/process
import mist.{type Connection, type ResponseData}
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}

pub fn main() {
  let error = 
    response.new(404)
    |> response.set_body(mist.Bytes(bytes_tree.new()))
    

  let assert Ok(_) = {
    fn(req: Request(Connection)) -> Response(ResponseData) {
      case request.path_segments(req) {
        // POST
        ["payments"] -> {
            response.new(200)
            |> response.set_body(mist.Bytes(bytes_tree.new()))
        }
        // GET
        ["payments-summary"] -> {
          response.new(200)
          |> response.set_body(mist.Bytes(bytes_tree.new()))
        }
        // POST
        // This route is not basic as the others, it is here now (before the others are minimally completed)
        // because it is needed is order to run the tests
        ["purge-payments"] -> {
          response.new(200)
          |> response.set_body(mist.Bytes(bytes_tree.new()))
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
  |> mist.port(9999)
  |> mist.start
    
  process.sleep_forever()
}
