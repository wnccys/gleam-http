import gleam/io
import gleam/result
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
          let assert Ok(raw_req) = request.to("localhost:8001/payments")
          let resp = httpc.send(raw_req)

          case resp {
            Ok(n) -> {
              io.println(n.body)
            
              response.new(200)
              |> response.set_body(mist.Bytes(bytes_tree.new()))
            }
            Error(_) -> {
              error
            }
          }
        }
        // GET
        ["payments-summary"] -> {
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
  |> mist.port(3000)
  |> mist.start
    
  process.sleep_forever()
}
