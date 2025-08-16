import gleam/result
import gleam/bit_array
import gleam/io
import gleam/list
import gleam/string
import logging
import gleam/bytes_tree
import gleam/erlang/process
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import mist.{type Connection, type ResponseData}
import router.{type Router, get, handle_request, post}
import client.{new, to, post as c_post}
import objects.{into_payment_res, from_payment_res}

// Tests can be imported and used in-demand just like this
// import backend_test.{http_methods_test}

pub fn main() {
  // NOTE in order to keep it simple, here can be implemented a data structure which stores the payments, resolved dynamically 

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
          "Got a request from: " <> string.inspect(mist.get_client_info(req.body)) <>
          " for: " <> req.path <> " " <> string.inspect(req.method),
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
  // as the plan is never need to hit the fallback processor in order to keep the fees low, it can be hard typed
  let fbck_res = "\"fallback\" : {
    \"totalRequests\": 0,
    \"totalAmount\": 0
  }"

  router
  |> post(
    "payments",
    fn(req, _params) {
      let assert Ok(res) = req 
      |> mist.read_body(1024 * 1024)
    
      let assert Ok(body) = bit_array.to_string(res.body)

      let payment = into_payment_res(body) |> from_payment_res

      let assert Ok(res) = new()
      |> to("http://localhost:8001/payments")
      |> c_post(payment)

      let string_resp = bit_array.to_string(res.body) |> result.unwrap("Invalid body.")
      io.print("resp from processor: " <> string_resp)

      response.new(200)
      |> response.set_body(mist.Bytes(bytes_tree.new()))
    },
  )
  |> get(
    "payments-summary",
    fn(_req, _params) {
      // as the plan is never need to hit the fallback processor in order to keep the fees low, it can be hard typed

      response.new(200)
      |> response.set_body(mist.Bytes(bytes_tree.from_string("
        { \"default\" : { \"totalRequests\": 43236, \"totalAmount\": 415542345.98 }, \"fallback\" : { \"totalRequests\": 423545, \"totalAmount\": 329347.34 } }
      ")))
    },
  )
  |> post(
    "purge-payments",
    fn(_, _) {
      response.new(200)
      |> response.set_body(mist.Bytes(bytes_tree.new()))
    }
  )
}
