import gleam/list
import gleam/bytes_tree
import gleam/result
import gleeunit
import router.{type Router, delete, get, post, put}
import mist.{type Connection, type ResponseData}
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/dict.{type Dict}

pub fn main() -> Nil {
  gleeunit.main()
}

// Test 1: Route parameters
pub fn route_params_test(router: Router) -> Router {
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
pub fn http_methods_test(router: Router) -> Router {
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
pub fn complex_routes_test(router: Router) -> Router {
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

pub fn query_params_test(router: Router) -> Router {
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
