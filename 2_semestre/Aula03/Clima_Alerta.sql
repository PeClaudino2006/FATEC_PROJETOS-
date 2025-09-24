DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'evento_status') THEN
    CREATE TYPE evento_status AS ENUM ('Ativo', 'Encerrado', 'Em Monitoramento');
  END IF;
END$$;

CREATE TABLE IF NOT EXISTS tipo_evento (
  id_tipo_evento  BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  nome            VARCHAR(80)  NOT NULL,
  descricao       VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS localizacao (
  id_localizacao  BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  latitude        NUMERIC(8,5)  NOT NULL CHECK (latitude  BETWEEN -90  AND 90),
  longitude       NUMERIC(8,5)  NOT NULL CHECK (longitude BETWEEN -180 AND 180),
  cidade          VARCHAR(100),
  estado          VARCHAR(2)
);

CREATE TABLE IF NOT EXISTS usuario_app (
  id_usuario      BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  nome            VARCHAR(120) NOT NULL,
  email           VARCHAR(160) UNIQUE,
  senha_hash      TEXT         NOT NULL
);

CREATE TABLE IF NOT EXISTS evento (
  id_evento       BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  titulo          VARCHAR(160) NOT NULL,
  descricao       TEXT,
  data_hora       TIMESTAMP NOT NULL,
  status          evento_status NOT NULL DEFAULT 'Ativo',
  id_tipo_evento  BIGINT NOT NULL REFERENCES tipo_evento(id_tipo_evento) ON UPDATE CASCADE ON DELETE RESTRICT,
  id_localizacao  BIGINT NOT NULL REFERENCES localizacao(id_localizacao) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS relato (
  id_relato       BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  texto           TEXT        NOT NULL,
  data_hora       TIMESTAMP   NOT NULL DEFAULT NOW(),
  id_evento       BIGINT      NOT NULL REFERENCES evento(id_evento)       ON UPDATE CASCADE ON DELETE CASCADE,
  id_usuario      BIGINT      NOT NULL REFERENCES usuario_app(id_usuario) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS alerta (
  id_alerta       BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  mensagem        TEXT        NOT NULL,
  data_hora       TIMESTAMP   NOT NULL DEFAULT NOW(),
  nivel           VARCHAR(20) NOT NULL,
  id_evento       BIGINT      NOT NULL REFERENCES evento(id_evento) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_evento_tipo_data          ON evento (id_tipo_evento, data_hora DESC);
CREATE INDEX IF NOT EXISTS idx_evento_localizacao        ON evento (id_localizacao);
CREATE INDEX IF NOT EXISTS idx_localizacao_cidade_estado ON localizacao (estado, cidade);
CREATE INDEX IF NOT EXISTS idx_usuario_email             ON usuario_app (email);
CREATE INDEX IF NOT EXISTS idx_relato_evento_data        ON relato (id_evento, data_hora DESC);
CREATE INDEX IF NOT EXISTS idx_alerta_evento_data        ON alerta (id_evento, data_hora DESC);
