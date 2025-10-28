DROP TABLE IF EXISTS emprestimo_livro;
DROP TABLE IF EXISTS emprestimo;
DROP TABLE IF EXISTS cliente;
DROP TABLE IF EXISTS livro_autor;
DROP TABLE IF EXISTS livro;
DROP TABLE IF EXISTS autor;
DROP TABLE IF EXISTS editora;

-- ========================
-- Criação de Tabelas
-- ========================

-- Autores
CREATE TABLE autor (
    id_autor SERIAL PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    nacionalidade VARCHAR(100)
);

-- Editoras
CREATE TABLE editora (
    id_editora SERIAL PRIMARY KEY,
    nome_editora VARCHAR(150) NOT NULL,
    cidade VARCHAR(100)
);

-- Livros
CREATE TABLE livro (
    id_livro SERIAL PRIMARY KEY,
    titulo VARCHAR(200) NOT NULL,
    ano_publicacao INT NOT NULL,
    isbn VARCHAR(20) UNIQUE,
    paginas INT,
    id_editora INT REFERENCES editora(id_editora)
);

-- Tabela associativa Livro/Autor 
CREATE TABLE livro_autor (
    id_livro INT NOT NULL REFERENCES livro(id_livro),
    id_autor INT NOT NULL REFERENCES autor(id_autor),
    PRIMARY KEY (id_livro, id_autor)
);

-- Clientes (Leitores)
CREATE TABLE cliente (
    id_cliente SERIAL PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    telefone VARCHAR(20)
);

-- Empréstimos
CREATE TABLE emprestimo (
    id_emprestimo SERIAL PRIMARY KEY,
    data_emprestimo DATE NOT NULL,
    data_devolucao DATE,
    id_cliente INT NOT NULL REFERENCES cliente(id_cliente)
);

-- Tabela associativa Empréstimo/Livro 
CREATE TABLE emprestimo_livro (
    id_emprestimo INT NOT NULL REFERENCES emprestimo(id_emprestimo),
    id_livro INT NOT NULL REFERENCES livro(id_livro),
    PRIMARY KEY (id_emprestimo, id_livro)
);

-- ===========================
-- Inserção de Dados Iniciais
-- ===========================

-- Autores
INSERT INTO autor (nome, nacionalidade) VALUES
('J.K. Rowling', 'Britânica'),
('George R.R. Martin', 'Americano'),
('J.R.R. Tolkien', 'Britânico');

-- Editoras
INSERT INTO editora (nome_editora, cidade) VALUES
('Bloomsbury', 'Londres'),
('Bantam Books', 'Nova York'),
('Allen & Unwin', 'Londres');

-- Livros
INSERT INTO livro (titulo, ano_publicacao, isbn, paginas, id_editora) VALUES
('Harry Potter e a Pedra Filosofal', 1997, '9780747532699', 223, 1),
('A Guerra dos Tronos', 1996, '9780553103540', 694, 2),
('O Senhor dos Anéis', 1954, '9780261102385', 1178, 3);

-- Livro/Autor
INSERT INTO livro_autor (id_livro, id_autor) VALUES
(1, 1),
(2, 2),
(3, 3);

-- Clientes
INSERT INTO cliente (nome, email, telefone) VALUES
('Ana Souza', 'ana@gmail.com', '(11)91234-5678'),
('Bruno Lima', 'bruno@gmail.com', '(21)99876-5432'),
('Carla Mendes', 'carla@gmail.com', '(31)98765-4321');

-- Empréstimos
INSERT INTO emprestimo (data_emprestimo, data_devolucao, id_cliente) VALUES
('2025-09-01', '2025-09-10', 1),
('2025-09-02', NULL, 2);

-- Empréstimo/Livro
INSERT INTO emprestimo_livro (id_emprestimo, id_livro) VALUES
(1, 1),
(1, 2),
(2, 3);

----------------------------------------------------------
-- Consultas 1
-- Listar quantos livros cada autor publicou por editora.
-- Mostra o nome do autor, a editora e o total de livros publicados.
----------------------------------------------------------
SELECT 
    a.nome AS autor,
    e.nome_editora AS editora,
    COUNT(l.id_livro) AS total_livros
FROM autor a
JOIN livro_autor la ON a.id_autor = la.id_autor
JOIN livro l ON la.id_livro = l.id_livro
JOIN editora e ON l.id_editora = e.id_editora
GROUP BY a.nome, e.nome_editora
ORDER BY a.nome, total_livros DESC;

----------------------------------------------------------
-- Consulta 2
-- Listar a média de páginas dos livros por autor.
-- Mostra o nome do autor e a média de páginas de seus livros.
----------------------------------------------------------
SELECT 
    a.nome AS autor,
    ROUND(AVG(l.paginas), 2) AS media_paginas
FROM autor a
JOIN livro_autor la ON a.id_autor = la.id_autor
JOIN livro l ON la.id_livro = l.id_livro
GROUP BY a.nome
ORDER BY media_paginas DESC;
