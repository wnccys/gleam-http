import gleam/string
import logging
import gleam/io
import gleam/bytes_tree
import gleam/dict.{type Dict}
import gleam/erlang/process
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import mist.{type Connection, type ResponseData}
import router.{type Router, get, handle_request, post}
// Tests can be imported and used in-demand just like this
// import backend_test.{http_methods_test}

pub fn main() {
  logging.configure()
  logging.set_level(logging.Debug)

  let _error =
    response.new(404)
    |> response.set_body(mist.Bytes(bytes_tree.new()))

  let router =
    router.new()
    |> payment_routes

  let assert Ok(_) =
    fn(req: Request(Connection)) -> Response(ResponseData) {
      logging.log(
      logging.Info,
      "Got a request from: " <> string.inspect(mist.get_client_info(req.body)) <> "for" <> req.path,
  )
      router |> handle_request(req)
    }
    |> mist.new
    |> mist.bind("localhost")
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
      |> response.set_body(mist.Bytes(bytes_tree.from_string("{ \"hello\": \"world\" }")))
    },
  )
  |> get(
    "payments-summary",
    fn(_req: Request(Connection), _params: Dict(String, String)) -> Response(
      mist.ResponseData,
    ) {
      response.new(200)
      |> response.set_body(mist.Bytes(bytes_tree.from_string("
        { \"default\" : { \"totalRequests\": 43236, \"totalAmount\": 415542345.98 }, \"fallback\" : { \"totalRequests\": 423545, \"totalAmount\": 329347.34 } }
      ")))
    },
  )
}
