-- ==============================================
-- LIMPEZA (DROP TABLES)
-- ==============================================
-- A ordem importa! Primeiro as tabelas que dependem das outras.
DROP TABLE IF EXISTS venda CASCADE;
DROP TABLE IF EXISTS produto CASCADE;
DROP TABLE IF EXISTS loja CASCADE;
DROP TABLE IF EXISTS fabricante CASCADE;
 
-- ==============================================
-- Tabela de fabricantes de consoles e acessórios
-- ==============================================
CREATE TABLE fabricante (
    id_fabricante SERIAL PRIMARY KEY,
    nome_fabricante VARCHAR(100) NOT NULL,
    pais VARCHAR(50)
);
 
-- ==============================================
-- Tabela de produtos vendidos na rede de lojas
-- ==============================================
CREATE TABLE produto (
    id_produto SERIAL PRIMARY KEY,
    nome VARCHAR(120) NOT NULL,
    preco NUMERIC(10,2) NOT NULL CHECK (preco > 0),
    id_fabricante INT,
    FOREIGN KEY (id_fabricante) REFERENCES fabricante(id_fabricante)
);
 
-- ==============================================
-- Tabela de lojas da rede
-- ==============================================
CREATE TABLE loja (
    id_loja SERIAL PRIMARY KEY,
    nome_loja VARCHAR(120) NOT NULL,
    cidade VARCHAR(80) NOT NULL
);
 
-- ==============================================
-- Tabela de vendas
-- ==============================================
CREATE TABLE venda (
    id_venda SERIAL PRIMARY KEY,
    id_produto INT NOT NULL,
    id_loja INT NOT NULL,
    quantidade INT NOT NULL CHECK (quantidade > 0),
    data_venda DATE NOT NULL,
    FOREIGN KEY (id_produto) REFERENCES produto(id_produto),
    FOREIGN KEY (id_loja) REFERENCES loja(id_loja)
);
 
-- ==============================================
-- INSERTS: FABRICANTES
-- ==============================================
INSERT INTO fabricante (nome_fabricante, pais) VALUES
    ('Nintendo', 'Japão'),
    ('Sony', 'Japão'),
    ('Microsoft', 'Estados Unidos'),
    ('Razer', 'Estados Unidos'),
    ('HyperX', 'Estados Unidos'),
    ('Logitech', 'Suíça'),
    ('Capcom', 'Japão');
 
-- ==============================================
-- INSERTS: PRODUTOS
-- ==============================================
INSERT INTO produto (nome, preco, id_fabricante) VALUES
    ('Nintendo Switch OLED', 2499.90, 1),
    ('Joy-Con Pair', 499.90, 1),
    ('PlayStation 5', 4399.00, 2),
    ('DualSense Controller', 399.90, 2),
    ('Xbox Series X', 4599.90, 3),
    ('Xbox Wireless Controller', 349.90, 3),
    ('Razer Kraken Headset', 499.90, 4),
    ('HyperX Cloud II Headset', 649.90, 5),
    ('Logitech G Pro Mouse', 399.90, 6),
    ('Resident Evil 4 Remake', 299.90, 7),
    ('Street Fighter 6', 349.90, 7);
 
-- ==============================================
-- INSERTS: LOJAS
-- ==============================================
INSERT INTO loja (nome_loja, cidade) VALUES
    ('Rede Games SP - Paulista', 'São Paulo'),
    ('Rede Games RJ - Barra', 'Rio de Janeiro'),
    ('Rede Games MG - BH Shopping', 'Belo Horizonte'),
    ('Rede Games PR - Curitiba', 'Curitiba');
 
-- ==============================================
-- INSERTS: VENDAS
-- ==============================================
INSERT INTO venda (id_produto, id_loja, quantidade, data_venda) VALUES
    (1, 1, 20, '2025-09-20'),
    (2, 1, 35, '2025-09-21'),
    (3, 2, 15, '2025-09-22'),
    (4, 2, 40, '2025-10-01'),
    (5, 3, 10, '2025-10-02'),
    (6, 3, 5, '2025-10-02'),
    (7, 4, 12, '2025-10-05'),
    (8, 4, 18, '2025-10-05'),
    (9, 1, 20, '2025-10-06'),
    (10, 2, 25, '2025-10-06'),
    (11, 3, 30, '2025-10-07');

	--7: 
SELECT produto.nome, loja.nome_loja, venda.quantidade
FROM venda
JOIN produto ON venda.id_produto = produto.id_produto
JOIN loja ON venda.id_loja = loja.id_loja;
 
    --8:
SELECT loja.nome_loja, SUM(venda.quantidade)
FROM venda
JOIN loja ON venda.id_loja = loja.id_loja
GROUP BY loja.nome_loja;
 
    --9:
SELECT loja.nome_loja, SUM(venda.quantidade)
FROM venda
JOIN loja ON venda.id_loja = loja.id_loja
GROUP BY loja.nome_loja
HAVING SUM(venda.quantidade) > 30;
 
   --10:
SELECT nome_fabricante
FROM fabricante
WHERE id_fabricante IN (
    SELECT id_fabricante
    FROM produto
    WHERE id_produto IN (
        SELECT id_produto
        FROM venda
    )
);
