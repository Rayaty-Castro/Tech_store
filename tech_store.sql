create database loja_tech;
USE loja_tech;

DELIMITER //

CREATE PROCEDURE atualizar_preco_categoria(
    IN  p_id_categoria   INT,
    IN  p_percentual     DECIMAL(6,2),
    OUT p_qtd_alterados  INT,
    OUT p_mensagem       VARCHAR(255)
)
BEGIN
    DECLARE v_nome_categoria  VARCHAR(100);
    DECLARE v_ativo_categoria BOOLEAN;

    -- Handler para reverter a transação em caso de falha inesperada no banco
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_qtd_alterados = 0;
        SET p_mensagem = 'ERRO: Falha interna ao atualizar os preços. Operação revertida.';
    END;

    -- 1. Validação de percentual nulo ou zero
    IF p_percentual IS NULL OR p_percentual = 0 THEN
        SET p_qtd_alterados = 0;
        SET p_mensagem = 'AVISO: O percentual de ajuste não pode ser zero ou nulo. Nenhum preço foi alterado.';

    -- 2. Validação do limite máximo de desconto (50%)
    ELSEIF p_percentual < -50.00 THEN
        SET p_qtd_alterados = 0;
        SET p_mensagem = 'ERRO: O desconto máximo permitido é de 50%.';

    -- 3. Validação do limite máximo de aumento (100%)
    ELSEIF p_percentual > 100.00 THEN
        SET p_qtd_alterados = 0;
        SET p_mensagem = 'ERRO: O aumento máximo permitido é de 100%.';

    ELSE
        -- 4. Verifica se a categoria existe e está ativa
        SELECT nome, ativo
          INTO v_nome_categoria, v_ativo_categoria
          FROM categorias
         WHERE id_categoria = p_id_categoria;

        IF v_nome_categoria IS NULL THEN
            SET p_qtd_alterados = 0;
            SET p_mensagem = 'ERRO: Categoria não encontrada.';

        ELSEIF v_ativo_categoria = FALSE THEN
            SET p_qtd_alterados = 0;
            SET p_mensagem = CONCAT('ERRO: A categoria "', v_nome_categoria, '" está inativa.');

        ELSE
            START TRANSACTION;

            -- 5. Atualiza os preços apenas dos produtos ativos da categoria
            UPDATE produtos
               SET preco = ROUND(preco * (1 + (p_percentual / 100)), 2)
             WHERE id_categoria = p_id_categoria
               AND ativo = TRUE;

            SET p_qtd_alterados = ROW_COUNT();

            -- 6. Registra a auditoria em log_operacoes se houve alteração
            IF p_qtd_alterados > 0 THEN
                INSERT INTO log_operacoes (tabela_afetada, operacao, descricao)
                VALUES (
                    'produtos',
                    'UPDATE',
                    CONCAT(
                        'Ajuste de ', p_percentual, '% nos preços da categoria "',
                        v_nome_categoria, '" (ID: ', p_id_categoria, '). ',
                        'Produtos alterados: ', p_qtd_alterados
                    )
                );

                SET p_mensagem = CONCAT(
                    'Sucesso! Preços reajustados em ', p_percentual,
                    '% para ', p_qtd_alterados, ' produto(s) ativo(s) da categoria "',
                    v_nome_categoria, '".'
                );
            ELSE
                SET p_mensagem = CONCAT(
                    'Aviso: Nenhum produto ativo encontrado na categoria "',
                    v_nome_categoria, '" para atualizar.'
                );
            END IF;

            COMMIT;
        END IF;
    END IF;
END //

DELIMITER ;