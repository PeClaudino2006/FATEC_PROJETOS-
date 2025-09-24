CREATE TABLE IF NOT EXISTS autor (
  id_autor        BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  nome            VARCHAR(120) NOT NULL,
  nacionalidade   VARCHAR(60)
);

CREATE TABLE IF NOT EXISTS livro (
  id_livro        BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  titulo          VARCHAR(200) NOT NULL,
  ano_publicacao  INT CHECK (ano_publicacao BETWEEN 1500 AND 2100),
  isbn            VARCHAR(20) UNIQUE
);

CREATE TABLE IF NOT EXISTS cliente (
  id_cliente      BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  nome            VARCHAR(120) NOT NULL,
  email           VARCHAR(160) UNIQUE,
  telefone        VARCHAR(30)
);

CREATE TABLE IF NOT EXISTS emprestimo (
  id_emprestimo   BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  data_emprestimo DATE NOT NULL,
  data_devolucao  DATE,
  id_cliente      BIGINT NOT NULL REFERENCES cliente(id_cliente) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT chk_devolucao_posterior CHECK (
    data_devolucao IS NULL OR data_devolucao >= data_emprestimo
  )
);

CREATE TABLE IF NOT EXISTS livro_autor (
  id_livro  BIGINT NOT NULL REFERENCES livro(id_livro)  ON UPDATE CASCADE ON DELETE CASCADE,
  id_autor  BIGINT NOT NULL REFERENCES autor(id_autor)  ON UPDATE CASCADE ON DELETE RESTRICT,
  PRIMARY KEY (id_livro, id_autor)
);

CREATE TABLE IF NOT EXISTS emprestimo_livro (
  id_emprestimo BIGINT NOT NULL REFERENCES emprestimo(id_emprestimo) ON UPDATE CASCADE ON DELETE CASCADE,
  id_livro      BIGINT NOT NULL REFERENCES livro(id_livro)           ON UPDATE CASCADE ON DELETE RESTRICT,
  PRIMARY KEY (id_emprestimo, id_livro)
);

CREATE INDEX IF NOT EXISTS idx_livro_titulo             ON livro (titulo);
CREATE INDEX IF NOT EXISTS idx_autor_nome               ON autor (nome);
CREATE INDEX IF NOT EXISTS idx_cliente_email            ON cliente (email);
CREATE INDEX IF NOT EXISTS idx_emprestimo_cliente_data  ON emprestimo (id_cliente, data_emprestimo);
