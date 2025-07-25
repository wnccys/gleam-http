import gleam/bytes_tree
import gleam/dict.{type Dict}
import gleam/http
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/list
import gleam/string
import mist.{type Connection, type ResponseData}

pub type RouteSegments =
  List(String)

type RouteHandlerFn =
  fn(Request(mist.Connection), Dict(String, String)) ->
    Response(mist.ResponseData)

pub type Route =
  #(http.Method, RouteSegments, RouteHandlerFn)

pub type Router {
  Router(routes: List(Route))
}

pub fn new() -> Router {
  Router(routes: [])
}

pub fn add_route(
  router: Router,
  method: http.Method,
  route_path: String,
  handler: RouteHandlerFn,
) -> Router {
  let segments =
    route_path
    |> string.split("/")
    |> list.filter(fn(s) { s != "" })

  let route_handler = #(method, segments, handler)
  Router(routes: [route_handler, ..router.routes])
}

pub fn get(
  router: Router,
  route_path: String,
  handler: fn(Request(Connection), Dict(String, String)) ->
    Response(ResponseData),
) -> Router {
  add_route(router, http.Get, route_path, handler)
}

pub fn post(
  router: Router,
  route_path: String,
  handler: fn(Request(Connection), Dict(String, String)) ->
    Response(ResponseData),
) -> Router {
  add_route(router, http.Post, route_path, handler)
}

pub fn put(
  router: Router,
  route_path: String,
  handler: fn(Request(Connection), Dict(String, String)) ->
    Response(ResponseData),
) -> Router {
  add_route(router, http.Put, route_path, handler)
}

pub fn delete(
  router: Router,
  route_path: String,
  handler: fn(Request(Connection), Dict(String, String)) ->
    Response(ResponseData),
) -> Router {
  add_route(router, http.Delete, route_path, handler)
}

pub fn handle_request(
  router: Router,
  req: Request(Connection),
) -> Response(ResponseData) {
  let path_segments = request.path_segments(req)

  match_route(req.method, path_segments, router.routes, req)
}

pub fn match_route(
  method: http.Method,
  path: List(String),
  routes: List(Route),
  req: Request(Connection),
) -> Response(ResponseData) {
  case routes {
    [] -> not_found()

    [route, ..rest] -> {
      let #(route_method, segments, handler) = route

      case route_method == method {
        True -> {
          case match_segments(segments, path) {
            Ok(params) -> handler(req, params)
            Error(_) -> match_route(method, path, rest, req)
            // Try next route
          }
        }
        False -> match_route(method, path, rest, req)
        // Wrong method, try next route
      }
    }
  }
}

pub fn match_segments(
  patterns: List(String),
  path: List(String),
) -> Result(Dict(String, String), String) {
  case patterns, path {
    [], [] -> Ok(dict.new())

    [curr_pattern, ..remaining_patterns], [curr_path, ..remaining_path] -> {
      case curr_pattern |> string.starts_with(":") {
        True -> {
          let param_name = curr_pattern |> string.drop_start(1)

          case match_segments(remaining_patterns, remaining_path) {
            Ok(params) -> Ok(params |> dict.insert(param_name, curr_path))
            Error(msg) -> Error(msg)
          }
        }

        False ->
          case curr_pattern == curr_path {
            True -> match_segments(remaining_patterns, remaining_path)
            False ->
              Error(
                "Segment mismatch: expected: '"
                <> curr_pattern
                <> "' but got '"
                <> curr_path
                <> "'",
              )
          }
      }
    }

    _, _ -> Error("Pattern and path segments mismatch")
  }
}

pub fn not_found() {
  response.new(404)
  |> response.set_header("Content-Type", "application/json")
  |> response.set_body(
    mist.Bytes(bytes_tree.from_string(
      "{\"status\":404, \"message\":\"é rota não\"}",
    )),
  )
}
