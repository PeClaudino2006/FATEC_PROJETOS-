
CREATE TABLE loja (
    id_loja SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cidade VARCHAR(100) NOT NULL
);

CREATE TABLE jogo (
    id_jogo SERIAL PRIMARY KEY,
    titulo VARCHAR(150) NOT NULL,
    ano_lancamento INT NOT NULL,
    genero VARCHAR(50) NOT NULL
);

CREATE TABLE cliente (
    id_cliente SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    cidade VARCHAR(100) NOT NULL
);

CREATE TABLE compra (
    id_compra SERIAL PRIMARY KEY,
    data_compra DATE NOT NULL,
    id_cliente INT REFERENCES cliente(id_cliente),
    id_loja INT REFERENCES loja(id_loja)
);

CREATE TABLE compra_jogo (
    id_compra INT REFERENCES compra(id_compra),
    id_jogo INT REFERENCES jogo(id_jogo),
    quantidade INT NOT NULL,
    PRIMARY KEY (id_compra, id_jogo)
);

-- Questão 3 - Inserção de lojas
INSERT INTO loja (nome, cidade) VALUES
('GameHouse', 'São Paulo'),
('PixelPlay', 'Rio de Janeiro'),
('LevelUp', 'Belo Horizonte');

-- Questão 4 - Inserção de clientes
INSERT INTO cliente (nome, email, cidade) VALUES
('Ana Silva', 'ana.silva@email.com', 'São Paulo'),
('Carlos Souza', 'carlos.souza@email.com', 'Rio de Janeiro'),
('Mariana Lima', 'mariana.lima@email.com', 'Belo Horizonte');

-- Questão 5 - Inserção de jogos
INSERT INTO jogo (titulo, ano_lancamento, genero) VALUES
('Elden Ring', 2022, 'RPG'),
('Valorant', 2020, 'FPS'),
('The Legend of Zelda: Tears of the Kingdom', 2023, 'Aventura');

-- Questão 6 - Inserção de compras
INSERT INTO compra (data_compra, id_cliente, id_loja) VALUES
('2025-09-01', 1, 1),
('2025-09-02', 2, 2);

-- Questão 7 - Inserção de jogos nas compras
INSERT INTO compra_jogo (id_compra, id_jogo, quantidade) VALUES
(1, 1, 2), -- Compra 1, Elden Ring
(1, 2, 1), -- Compra 1, Valorant
(2, 2, 3), -- Compra 2, Valorant
(2, 3, 1); -- Compra 2, Zelda

-- Questão 8 - Consulta simples
SELECT id_cliente, nome, cidade
FROM cliente;

-- Questão 9 - Consulta com filtro
SELECT titulo, ano_lancamento
FROM jogo
WHERE ano_lancamento > 2020;

-- Questão 10 - Função de agregação
SELECT SUM(quantidade) AS total_jogos_comprados
FROM compra_jogo;

