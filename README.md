# Gleam-HTTP

Submission for Rinha de Backend 3rd edition competition written in Gleam.

> Implementation Repository: https://github.com/zanfranceschi/rinha-de-backend-2025

## References

- Specification: https://github.com/zanfranceschi/rinha-de-backend-2025/blob/main/INSTRUCOES.md

- Explanation video: https://www.youtube.com/watch?v=ldPkTtkJ86k

- Payment processor official implementation: https://github.com/zanfranceschi/rinha-de-backend-2025-payment-processor

## Shades

### Detalhes dos Endpoints: https://github.com/zanfranceschi/rinha-de-backend-2025/blob/main/INSTRUCOES.md#detalhes-dos-endpoints

### Pontuação

O critério de pontução da Rinha de Backend será quanto de lucro seu backend conseguiu ter ao final do teste. Ou seja, quanto mais pagamentos você fizer com a menor taxa financeira, melhor. Lembre-se de que se houver inconsistências detectadas pelo Banco Central, você terá que pagar uma multa de 35% sobre o total de lucro.

Existe um critério técnico para pontuação também. Se seu backend e os Payment Processors tiverem tempos de respostas muito rápidos, você poderá pontuar também. A métrica usada para performance será o p99 (pegaremos o 1% piores tempos de resposta - percentil 99). A partir de um p99 de 10ms para menos, vocẽ recebe um bônus sobre seu total lucro de 2% para cada 1ms abaixo de 11ms.

A fórmula para a porcentagem de bônus por performance é (11 - p99) * 0,02. Se o valor for negativo, o bônus é 0% – não há penalidade para resultados com p99 maiores que 11ms.

Exemplos:

p99 de 10ms = 2% de bônus
p99 de 9ms = 4% de bônus
p99 de 5ms = 12% de bônus
p99 de 1ms = 20% de bônus
¹ O percentil será calculado em cima de todas as requisições HTTP feitas no teste e não apenas em cima das requisições feitas para o seu backend.

² Todos os pagamentos terão exatamente o mesmo valor – não serão gerados valores aleatórios.

### Arquitetura, Restrições e Submissão

Seu backend deverá seguir a arquitetura/restrições seguintes.

Web Servers: Possuir pelo menos duas instâncias de servidores web que irão responder às requisições POST /payments e GET /payments-summary. Ou seja, alguma forma de distribuição de carga deverá ocorrer (geralmente através de um load balancer como o nginx, por exemplo).

Conteinerização: Você deverá disponibilizar seu backend no formato de docker compose. Todas as imagens declaradas no docker compose (docker-compose.yml) deverão estar publicamente disponíveis em registros de imagens (https://hub.docker.com/ por exemplo).

Você deverá restringir o uso de CPU e Memória em 1,5 unidades de CPU e 350MB de memória entre todos os serviços declarados como quiser através dos atributos deploy.resources.limits.cpus e deploy.resources.limits.memory como no exemplo do trecho seguinte.

services:
  seu-servico:
    ...
    deploy:
      resources:
        limits:
          cpus: "0.15"
          memory: "42MB"
Exemplos de docker-compose.yml aqui, aqui e aqui.

Porta 9999: Seus endpoints deverão estar expostos na porta 9999 acessíveis via http://localhost:9999 – exemplo aqui.

Outras restrições
As imagens devem ser compatíveis com linux-amd64.
O modo de rede deve ser bridge – o modo host não é permitido.
Não é permitido modo privileged.
Não é permitido uso de serviços replicados – isso dificulta a verificação dos recursos usados.



* Uma resposta HTTP 429 - Too Many Requests pode vir acompanhada (na Rinha vem) de um Header "Retry-After: X" – onde X é um intervalo em segundos. Depois desse intervalo, você pode fazer a requisição novamente.
