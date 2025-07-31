import gleam/bytes_tree
import gleam/dict.{type Dict}
import gleam/erlang/process
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import mist.{type Connection, type ResponseData}
import router.{type Router, get, handle_request, post}

pub fn main() {
  let _error =
    response.new(404)
    |> response.set_body(mist.Bytes(bytes_tree.new()))

  let router =
    router.new()
    |> payment_routes

  let assert Ok(_) =
    fn(req: Request(Connection)) -> Response(ResponseData) {
      router |> handle_request(req)
    }
    |> mist.new
    |> mist.bind("localhost")
    |> mist.with_ipv6
    |> mist.port(9999)
    |> mist.start

  process.sleep_forever()
}

fn payment_routes(router: Router) -> Router {
  router
  |> post(
    "payments",
    fn(_req: Request(Connection), _params: Dict(String, String)) -> Response(
      mist.ResponseData,
    ) {
      response.new(200)
      |> response.set_body(mist.Bytes(bytes_tree.new()))
    },
  )
  |> get(
    "payments-summary",
    fn(_req: Request(Connection), _params: Dict(String, String)) -> Response(
      mist.ResponseData,
    ) {
      response.new(200)
      |> response.set_body(mist.Bytes(bytes_tree.new()))
    },
  )
}
