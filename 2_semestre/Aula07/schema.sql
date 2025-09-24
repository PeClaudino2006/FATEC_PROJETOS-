DROP TABLE IF EXISTS transacoes CASCADE;
DROP TABLE IF EXISTS contas CASCADE;
DROP TABLE IF EXISTS clientes CASCADE;

CREATE TABLE clientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cidade VARCHAR(50)
);

CREATE TABLE contas (
    id SERIAL PRIMARY KEY,
    cliente_id INT NOT NULL REFERENCES clientes(id),
    saldo NUMERIC(10,2) NOT NULL
);
CREATE TABLE transacoes (
    id SERIAL PRIMARY KEY,
    conta_id INT NOT NULL REFERENCES contas(id),
    tipo VARCHAR(20) CHECK (tipo IN ('Depósito','Saque')),
    valor NUMERIC(10,2) NOT NULL,
    data_transacao DATE NOT NULL
);

INSERT INTO clientes (nome, cidade) VALUES
('Ana', 'São Paulo'),
('Bruno', 'Jacareí'),
('Carlos', 'São José'),
('Diana', 'Jacareí'),
('Eduardo', 'São Paulo');

INSERT INTO contas (cliente_id, saldo) VALUES
(1, 5000),
(2, 3500),
(3, 7200),
(4, 4100),
(5, 6000);

INSERT INTO transacoes (conta_id, tipo, valor, data_transacao) VALUES
(1, 'Depósito', 1000, '2025-08-01'),
(1, 'Saque', 500, '2025-08-05'),
(2, 'Depósito', 1500, '2025-08-03'),
(3, 'Saque', 200, '2025-08-04'),
(4, 'Depósito', 300, '2025-08-02'),
(5, 'Saque', 1000, '2025-08-06'),
(2, 'Saque', 700, '2025-08-07'),
(3, 'Depósito', 400, '2025-08-08'),
(4, 'Saque', 300, '2025-08-09');

SELECT COUNT(*) AS total_clientes
FROM clientes;

SELECT SUM(saldo) AS saldo_total
FROM contas;

SELECT AVG(valor) AS media_saques
FROM transacoes
WHERE tipo = 'Saque';
