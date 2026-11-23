# TechStore (`loja_tech`)

Banco de dados MySQL para gerenciamento de um e-commerce de tecnologia utilizando **Stored Procedures**.

## Estrutura do Banco

* **`categorias`**: Agrupa os produtos (Notebooks, Smartphones, Periféricos, etc.).
* **`produtos`**: Catálogo com preço, estoque e status ativo/inativo.
* **`clientes`**: Cadastro de clientes da loja.
* **`pedidos`** e **`itens_pedido`**: Registro de compras e itens de cada pedido.
* **`log_operacoes`**: Histórico de auditoria das operações executadas pelas procedures.

## Stored Procedure: `atualizar_preco_categoria`

Reajusta o preço de todos os produtos ativos de uma categoria específica.

### Regras de Negócio
* **Desconto máximo:** `50%` (`-50.00`).
* **Aumento máximo:** `100%` (`100.00`).
* Bloqueia percentuais nulos ou iguais a `0`.
* Verifica se a categoria existe e está ativa antes de atualizar.
* Grava um registro de auditoria na tabela `log_operacoes`.

### Exemplo de Uso

```sql
-- Aplicar aumento de 10% na categoria 3 (Periféricos)
CALL atualizar_preco_categoria(3, 10.00, @qtd, @msg);

-- Visualizar o retorno
SELECT @qtd AS produtos_alterados, @msg AS mensagem;
