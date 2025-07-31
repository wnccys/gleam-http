import gleam/bit_array
import gleeunit
import client.{new, to, get, post}

pub fn main() {
  gleeunit.main()
}

// ===== Localhost tests =====
pub fn localhost_payments_test() {
  let assert Ok(resp) = new()
  |> to("http://localhost:9999/payments")
  |> post("")

  assert resp.status == 200
}

pub fn localhost_payments_summary_test() {
  let assert Ok(resp) = new()
  |> to("http://localhost:9999/payments-summary")
  |> get()

  assert resp.status == 200
}

// ===== Body match tests ======
pub fn localhost_payments_body_test() {
  let assert Ok(resp) = new()
  |> to("http://localhost:9999/payments")
  |> post("")

  assert resp.status == 200
  let assert Ok(body) = bit_array.to_string(resp.body)
  assert body == "{ \"hello\": \"world\" }"
}

pub fn localhost_payments_summary_body_test() {
  let assert Ok(resp) = new()
  |> to("http://localhost:9999/payments-summary")
  |> get()

  assert resp.status == 200
  assert resp.body == bit_array.from_string("")
}

// ===== Wrong method tests ===== 
pub fn localhost_payments_method_error_status_test() {
  let assert Ok(resp) = new()
  |> to("http://localhost:9999/payments")
  |> get()

  assert resp.status == 404
}

pub fn localhost_payments_summary_method_error_status_test() {
  let assert Ok(resp) = new()
  |> to("http://localhost:9999/payments-summary")
  |> post("")

  assert resp.status == 404
}

