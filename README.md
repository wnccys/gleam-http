# Gleam-HTTP

Submission for Rinha de Backend 3rd edition competition written in Gleam.

> Implementation Repository: https://github.com/zanfranceschi/rinha-de-backend-2025

## References

- Specification: https://github.com/zanfranceschi/rinha-de-backend-2025/blob/main/INSTRUCOES.md

- Explanation video: https://www.youtube.com/watch?v=ldPkTtkJ86k

- Payment processor official implementation: https://github.com/zanfranceschi/rinha-de-backend-2025-payment-processor

## Shades

* Uma resposta HTTP 429 - Too Many Requests pode vir acompanhada (na Rinha vem) de um Header "Retry-After: X" – onde X é um intervalo em segundos. Depois desse intervalo, você pode fazer a requisição novamente.
