import tempo
import gleam/json
import gleam/dynamic/decode

pub type PaymentObj {
  PaymentObj(correlation_id: String, amount: Float)
}

pub type PaymentObjRes {
  PaymentObjRes(correlation_id: String, amount: Float, requested_at: String)
}

pub fn into_payment_res(str: String) -> PaymentObjRes {
  let payments_decoder = {
    use correlation_id <- decode.field("correlationId", decode.string)
    use amount <- decode.field("amount", decode.float)
    decode.success(PaymentObjRes(correlation_id:, amount:, requested_at: tempo.format_local(tempo.ISO8601Milli)))
  }

  let assert Ok(payment) = json.parse(from: str, using: payments_decoder)

  payment
}

pub fn from_payment_res(obj: PaymentObjRes) -> String {
  json.object([
    #("correlationId", json.string(obj.correlation_id)),
    #("amount", json.float(obj.amount)),
    #("requestedAt", json.string(obj.requested_at))
  ])
  |> json.to_string
}
