-- Teste 1: Aumento válido de 10% nos Periféricos (ID 3)
CALL atualizar_preco_categoria(3, 10.00, @qtd, @msg);
SELECT @qtd AS produtos_alterados, @msg AS mensagem;

-- Teste 2: Desconto válido de 20% nos Notebooks (ID 1)
CALL atualizar_preco_categoria(1, -20.00, @qtd, @msg);
SELECT @qtd AS produtos_alterados, @msg AS mensagem;

-- Teste 3: Desconto acima do limite (-60%) -> deve retornar erro
CALL atualizar_preco_categoria(1, -60.00, @qtd, @msg);
SELECT @qtd AS produtos_alterados, @msg AS mensagem;

-- Teste 4: Percentual zero -> deve retornar aviso sem alterar dados
CALL atualizar_preco_categoria(2, 0.00, @qtd, @msg);
SELECT @qtd AS produtos_alterados, @msg AS mensagem;

-- Teste 5: Categoria inexistente -> deve retornar erro
CALL atualizar_preco_categoria(99, 15.00, @qtd, @msg);
SELECT @qtd AS produtos_alterados, @msg AS mensagem;

-- Conferir registros gerados na auditoria
SELECT * FROM log_operacoes ORDER BY id_log DESC;