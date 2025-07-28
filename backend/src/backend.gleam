import gleam/bytes_tree
import gleam/dict.{type Dict}
import gleam/erlang/process
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/list
import gleam/result
import mist.{type Connection, type ResponseData}
import router.{type Router, delete, get, handle_request, post, put}

pub fn main() {
  let _error =
    response.new(404)
    |> response.set_body(mist.Bytes(bytes_tree.new()))

  let router =
    router.new()
    |> get("helloworld", hello_world)
    |> payment_routes
    |> test_complex_routes
    |> test_http_methods
    |> test_query_params
    |> test_route_params

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

fn hello_world(
  _: Request(Connection),
  _: Dict(String, String),
) -> Response(mist.ResponseData) {
  response.new(200)
  |> response.set_header("Content-Type", "application/json")
  |> response.set_body(
    mist.Bytes(bytes_tree.from_string("{\"hello\": \"world\"}")),
  )
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
  |> post(
    "payments-summary",
    fn(_req: Request(Connection), _params: Dict(String, String)) -> Response(
      mist.ResponseData,
    ) {
      response.new(200)
      |> response.set_body(mist.Bytes(bytes_tree.new()))
    },
  )
}

// ================================================================================================================================
// TEST FUNCTIONS - Funções de exemplo feitas pelo claudin (Claude), foi mal rapaziada fiquei com preguiça de codar esse trem (:
//  ================================================================================================================================

// Test 1: Route parameters
pub fn test_route_params(router: Router) -> Router {
  router
  |> get(
    "users/:id",
    fn(_req: Request(Connection), params: Dict(String, String)) -> Response(
      ResponseData,
    ) {
      let user_id = params |> dict.get("id") |> result.unwrap("unknown")
      response.new(200)
      |> response.set_header("Content-Type", "text/plain")
      |> response.set_body(
        mist.Bytes(bytes_tree.from_string("User ID: " <> user_id)),
      )
    },
  )
  |> get(
    "users/:id/posts/:post_id",
    fn(_req: Request(Connection), params: Dict(String, String)) -> Response(
      ResponseData,
    ) {
      let user_id = params |> dict.get("id") |> result.unwrap("unknown")
      let post_id = params |> dict.get("post_id") |> result.unwrap("unknown")
      response.new(200)
      |> response.set_header("Content-Type", "text/plain")
      |> response.set_body(
        mist.Bytes(bytes_tree.from_string(
          "User: " <> user_id <> ", Post: " <> post_id,
        )),
      )
    },
  )
  |> get(
    "products/:category/:id",
    fn(_req: Request(Connection), params: Dict(String, String)) -> Response(
      ResponseData,
    ) {
      let category = params |> dict.get("category") |> result.unwrap("unknown")
      let product_id = params |> dict.get("id") |> result.unwrap("unknown")
      response.new(200)
      |> response.set_header("Content-Type", "text/plain")
      |> response.set_body(
        mist.Bytes(bytes_tree.from_string(
          "Category: " <> category <> ", Product: " <> product_id,
        )),
      )
    },
  )
}

// Test 2: HTTP Method differentiation
pub fn test_http_methods(router: Router) -> Router {
  router
  |> get(
    "items",
    fn(_req: Request(Connection), _params: Dict(String, String)) -> Response(
      ResponseData,
    ) {
      response.new(200)
      |> response.set_header("Content-Type", "text/plain")
      |> response.set_body(
        mist.Bytes(bytes_tree.from_string("GET: List all items")),
      )
    },
  )
  |> post(
    "items",
    fn(_req: Request(Connection), _params: Dict(String, String)) -> Response(
      ResponseData,
    ) {
      response.new(201)
      |> response.set_header("Content-Type", "text/plain")
      |> response.set_body(
        mist.Bytes(bytes_tree.from_string("POST: Create new item")),
      )
    },
  )
  |> put(
    "items/:id",
    fn(_req: Request(Connection), params: Dict(String, String)) -> Response(
      ResponseData,
    ) {
      let item_id = params |> dict.get("id") |> result.unwrap("unknown")
      response.new(200)
      |> response.set_header("Content-Type", "text/plain")
      |> response.set_body(
        mist.Bytes(bytes_tree.from_string("PUT: Update item " <> item_id)),
      )
    },
  )
  |> delete(
    "items/:id",
    fn(_req: Request(Connection), params: Dict(String, String)) -> Response(
      ResponseData,
    ) {
      let item_id = params |> dict.get("id") |> result.unwrap("unknown")
      response.new(200)
      |> response.set_header("Content-Type", "text/plain")
      |> response.set_body(
        mist.Bytes(bytes_tree.from_string("DELETE: Remove item " <> item_id)),
      )
    },
  )
}

// Test 3: Complex routing patterns
pub fn test_complex_routes(router: Router) -> Router {
  router
  |> get(
    "",
    fn(_req: Request(Connection), _params: Dict(String, String)) -> Response(
      ResponseData,
    ) {
      response.new(200)
      |> response.set_header("Content-Type", "text/plain")
      |> response.set_body(mist.Bytes(bytes_tree.from_string("Homepage")))
    },
  )
  |> get(
    "about",
    fn(_req: Request(Connection), _params: Dict(String, String)) -> Response(
      ResponseData,
    ) {
      response.new(200)
      |> response.set_header("Content-Type", "text/plain")
      |> response.set_body(mist.Bytes(bytes_tree.from_string("About page")))
    },
  )
  |> get(
    "api/v1/users/:id",
    fn(_req: Request(Connection), params: Dict(String, String)) -> Response(
      ResponseData,
    ) {
      let user_id = params |> dict.get("id") |> result.unwrap("unknown")
      response.new(200)
      |> response.set_header("Content-Type", "text/plain")
      |> response.set_body(
        mist.Bytes(bytes_tree.from_string("API v1 - User: " <> user_id)),
      )
    },
  )
  |> get(
    "api/v2/users/:id",
    fn(_req: Request(Connection), params: Dict(String, String)) -> Response(
      ResponseData,
    ) {
      let user_id = params |> dict.get("id") |> result.unwrap("unknown")
      response.new(200)
      |> response.set_header("Content-Type", "text/plain")
      |> response.set_body(
        mist.Bytes(bytes_tree.from_string("API v2 - User: " <> user_id)),
      )
    },
  )
}

// Test 4: Query parameters (from URL query string)
pub fn get_query_param(req: Request(Connection), param: String) -> String {
  case request.get_query(req) {
    Ok(query_params) -> {
      query_params
      |> list.find(fn(pair) { pair.0 == param })
      |> result.map(fn(pair) { pair.1 })
      |> result.unwrap("not_found")
    }
    Error(_) -> "no_query"
  }
}

pub fn test_query_params(router: Router) -> Router {
  router
  |> get(
    "search",
    fn(req: Request(Connection), _params: Dict(String, String)) -> Response(
      ResponseData,
    ) {
      let query = get_query_param(req, "q")
      let page = get_query_param(req, "page")
      response.new(200)
      |> response.set_header("Content-Type", "text/plain")
      |> response.set_body(
        mist.Bytes(bytes_tree.from_string(
          "Search: '" <> query <> "', Page: " <> page,
        )),
      )
    },
  )
  |> get(
    "filter",
    fn(req: Request(Connection), _params: Dict(String, String)) -> Response(
      ResponseData,
    ) {
      let category = get_query_param(req, "category")
      let min_price = get_query_param(req, "min_price")
      let max_price = get_query_param(req, "max_price")
      response.new(200)
      |> response.set_header("Content-Type", "text/plain")
      |> response.set_body(
        mist.Bytes(bytes_tree.from_string(
          "Filter - Category: "
          <> category
          <> ", Price: "
          <> min_price
          <> "-"
          <> max_price,
        )),
      )
    },
  )
}
