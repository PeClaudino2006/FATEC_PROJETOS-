DROP TABLE IF EXISTS compra_jogo;
DROP TABLE IF EXISTS compra;
DROP TABLE IF EXISTS jogo;
DROP TABLE IF EXISTS cliente;
DROP TABLE IF EXISTS loja;



CREATE TABLE IF NOT EXISTS loja (
    id_loja SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cidade VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS jogo (
    id_jogo SERIAL PRIMARY KEY,
    titulo VARCHAR(100) NOT NULL,
    ano_lancamento INT,
    genero VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS cliente (
    id_cliente SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    cidade VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS compra (
    id_compra SERIAL PRIMARY KEY,
    data_compra DATE NOT NULL,
    id_cliente INT REFERENCES cliente(id_cliente),
    id_loja INT REFERENCES loja(id_loja)
);

CREATE TABLE IF NOT EXISTS compra_jogo (
    id_compra INT REFERENCES compra(id_compra),
    id_jogo INT REFERENCES jogo(id_jogo),
    quantidade INT DEFAULT 1,
    PRIMARY KEY (id_compra, id_jogo)
);

INSERT INTO loja (nome, cidade) 
VALUES
('Game Center', 'São Paulo'),
('PlayHouse', 'Rio de Janeiro'),
('MegaGames', 'Curitiba');

INSERT INTO cliente (nome, email, cidade) VALUES
('Lucas Mendes', 'lucas.mendes@email.com', 'São Paulo'),
('Ana Souza', 'ana.souza@email.com', 'Belo Horizonte'),
('João Pereira', 'joao.pereira@email.com', 'Rio de Janeiro');

INSERT INTO jogo (titulo, ano_lancamento, genero) VALUES
('The Last Warrior', 2021, 'Ação'),
('Galaxy Quest', 2020, 'Ficção Científica'),
('Mystic Valley', 2022, 'RPG');

INSERT INTO compra (data_compra, id_cliente, id_loja) VALUES
('2025-09-01', 1, 1),
('2025-09-03', 2, 2); 

INSERT INTO compra_jogo (id_compra, id_jogo, quantidade) VALUES
(1, 1, 1),
(1, 2, 2);

INSERT INTO compra_jogo (id_compra, id_jogo, quantidade) VALUES
(2, 2, 1), 
(2, 3, 1); 

select id_cliente, nome, cidade from cliente;

select titulo, ano_lancamento from jogo
where ano_lancamento > 2020;

select sum(quantidade) as "Quantidade de jogos comprados" from compra_jogo
