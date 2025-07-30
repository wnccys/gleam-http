import gleam/bit_array
import gleeunit
import client.{new, set_header, to, get, post}

pub fn main() {
  gleeunit.main()
}

pub fn client_get_test() {
  let assert Ok(resp) = new()
  |> set_header("accept", "application/vnd.hmrc.1.0+json")
  |> set_header("content-type", "application/json")
  |> to("https://test-api.service.hmrc.gov.uk/hello/world")
  |> get()


  let assert Ok(_body) = bit_array.to_string(resp.body)
}

pub fn client_post_test() {
  let assert Ok(resp) = new()
  |> set_header("accept", "*/*")
  |> set_header("content-type", "application/json")
  |> to("https://test-api.service.hmrc.gov.uk/hello/world")
  |> post("{ \"hello\": \"world\" }")

  let assert Ok(_body) = bit_array.to_string(resp.body)
}

