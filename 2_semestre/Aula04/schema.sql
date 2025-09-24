-- Script PostgreSQL para sistema de monitoramento de eventos
-- Criado para o projeto de Desenvolvimento Web II

-- ENUM protegido contra recriação
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'evento_status') THEN
    CREATE TYPE evento_status AS ENUM ('Ativo', 'Encerrado', 'Em Monitoramento');
  END IF;
END$$;

-- ENUM para nível de alerta
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'alerta_nivel') THEN
    CREATE TYPE alerta_nivel AS ENUM ('Baixo', 'Médio', 'Alto', 'Crítico');
  END IF;
END$$;

-- ENUM para tipo de notificação
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'notificacao_tipo') THEN
    CREATE TYPE notificacao_tipo AS ENUM ('Email', 'SMS', 'Push', 'WhatsApp');
  END IF;
END$$;

-- Tabela de tipos de evento
CREATE TABLE IF NOT EXISTS tipo_evento (
  id_tipo_evento  BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  nome            VARCHAR(80)  NOT NULL,
  descricao       VARCHAR(255),
  cor_identificacao VARCHAR(7) DEFAULT '#007bff', -- Código de cor para identificação visual
  icone           VARCHAR(50), -- Nome do ícone para interface
  ativo           BOOLEAN DEFAULT true
);

-- Tabela de localizações
CREATE TABLE IF NOT EXISTS localizacao (
  id_localizacao  BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  latitude        NUMERIC(8,5)  NOT NULL CHECK (latitude  BETWEEN -90  AND 90),
  longitude       NUMERIC(8,5)  NOT NULL CHECK (longitude BETWEEN -180 AND 180),
  cidade          VARCHAR(100),
  estado          VARCHAR(2),
  pais            VARCHAR(100) DEFAULT 'Brasil',
  endereco        TEXT, -- Endereço completo para referência
  bairro          VARCHAR(100),
  cep             VARCHAR(10)
);

-- Tabela de usuários da aplicação
CREATE TABLE IF NOT EXISTS usuario_app (
  id_usuario      BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  nome            VARCHAR(120) NOT NULL,
  email           VARCHAR(160) UNIQUE,
  senha_hash      TEXT         NOT NULL,
  telefone        VARCHAR(20),
  data_cadastro   TIMESTAMP DEFAULT NOW(),
  ultimo_login    TIMESTAMP,
  ativo           BOOLEAN DEFAULT true,
  tipo_usuario    VARCHAR(20) DEFAULT 'comum' -- comum, moderador, administrador
);

-- Tabela de eventos
CREATE TABLE IF NOT EXISTS evento (
  id_evento       BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  titulo          VARCHAR(160) NOT NULL,
  descricao       TEXT,
  data_hora       TIMESTAMP NOT NULL,
  data_fim        TIMESTAMP, -- Data de encerramento do evento
  status          evento_status NOT NULL DEFAULT 'Ativo',
  id_tipo_evento  BIGINT NOT NULL REFERENCES tipo_evento(id_tipo_evento) ON UPDATE CASCADE ON DELETE RESTRICT,
  id_localizacao  BIGINT NOT NULL REFERENCES localizacao(id_localizacao) ON UPDATE CASCADE ON DELETE RESTRICT,
  id_usuario_criador BIGINT REFERENCES usuario_app(id_usuario) ON UPDATE CASCADE ON DELETE SET NULL,
  prioridade      INTEGER DEFAULT 1 CHECK (prioridade BETWEEN 1 AND 5), -- 1=baixa, 5=crítica
  tags            TEXT[], -- Array de tags para categorização
  evidencia_foto  TEXT[], -- URLs das fotos de evidência
  criado_em       TIMESTAMP DEFAULT NOW(),
  atualizado_em   TIMESTAMP DEFAULT NOW()
);

-- Tabela de relatos dos usuários
CREATE TABLE IF NOT EXISTS relato (
  id_relato       BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  texto           TEXT        NOT NULL,
  data_hora       TIMESTAMP   NOT NULL DEFAULT NOW(),
  id_evento       BIGINT      NOT NULL REFERENCES evento(id_evento)       ON UPDATE CASCADE ON DELETE CASCADE,
  id_usuario      BIGINT      NOT NULL REFERENCES usuario_app(id_usuario) ON UPDATE CASCADE ON DELETE RESTRICT,
  avaliacao       INTEGER CHECK (avaliacao BETWEEN 1 AND 5), -- Avaliação do relato (1-5 estrelas)
  moderado        BOOLEAN DEFAULT false, -- Se o relato foi revisado por moderador
  id_moderador    BIGINT REFERENCES usuario_app(id_usuario) ON UPDATE CASCADE ON DELETE SET NULL,
  data_moderacao  TIMESTAMP
);

-- Tabela de alertas do sistema
CREATE TABLE IF NOT EXISTS alerta (
  id_alerta       BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  mensagem        TEXT        NOT NULL,
  data_hora       TIMESTAMP   NOT NULL DEFAULT NOW(),
  nivel           alerta_nivel NOT NULL DEFAULT 'Médio',
  id_evento       BIGINT      NOT NULL REFERENCES evento(id_evento) ON UPDATE CASCADE ON DELETE CASCADE,
  id_usuario_destinatario BIGINT REFERENCES usuario_app(id_usuario) ON UPDATE CASCADE ON DELETE SET NULL,
  lido            BOOLEAN DEFAULT false,
  acao_requerida TEXT -- Descrição da ação que deve ser tomada
);

-- NOVA TABELA: Sistema de notificações
CREATE TABLE IF NOT EXISTS notificacao (
  id_notificacao  BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  id_usuario      BIGINT NOT NULL REFERENCES usuario_app(id_usuario) ON UPDATE CASCADE ON DELETE CASCADE,
  titulo          VARCHAR(200) NOT NULL,
  mensagem        TEXT NOT NULL,
  tipo            notificacao_tipo NOT NULL DEFAULT 'Push',
  data_envio      TIMESTAMP DEFAULT NOW(),
  data_leitura    TIMESTAMP,
  lida            BOOLEAN DEFAULT false,
  prioridade      INTEGER DEFAULT 1 CHECK (prioridade BETWEEN 1 AND 3), -- 1=baixa, 2=média, 3=alta
  categoria       VARCHAR(50), -- alerta, evento, sistema, etc.
  dados_extras    JSONB, -- Dados adicionais em formato JSON
  tentativas_envio INTEGER DEFAULT 0,
  status_envio    VARCHAR(20) DEFAULT 'pendente' -- pendente, enviado, falha, cancelado
);

-- Tabela de configurações de notificação por usuário
CREATE TABLE IF NOT EXISTS configuracao_notificacao (
  id_config       BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  id_usuario      BIGINT NOT NULL REFERENCES usuario_app(id_usuario) ON UPDATE CASCADE ON DELETE CASCADE,
  tipo_evento     BIGINT REFERENCES tipo_evento(id_tipo_evento) ON UPDATE CASCADE ON DELETE CASCADE,
  email_ativado   BOOLEAN DEFAULT true,
  sms_ativado     BOOLEAN DEFAULT false,
  push_ativado    BOOLEAN DEFAULT true,
  whatsapp_ativado BOOLEAN DEFAULT false,
  nivel_minimo    alerta_nivel DEFAULT 'Médio',
  raio_km         INTEGER DEFAULT 10, -- Raio em km para notificações de eventos próximos
  horario_inicio  TIME DEFAULT '08:00:00',
  horario_fim     TIME DEFAULT '22:00:00',
  dias_semana     INTEGER[] DEFAULT '{1,2,3,4,5,6,7}', -- 1=domingo, 7=sábado
  UNIQUE(id_usuario, tipo_evento)
);

-- Tabela de histórico de ações dos usuários
CREATE TABLE IF NOT EXISTS log_acao (
  id_log          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  id_usuario      BIGINT REFERENCES usuario_app(id_usuario) ON UPDATE CASCADE ON DELETE SET NULL,
  acao            VARCHAR(100) NOT NULL, -- login, logout, criar_evento, editar_evento, etc.
  tabela_afetada  VARCHAR(50), -- Nome da tabela afetada pela ação
  id_registro     BIGINT, -- ID do registro afetado
  dados_anteriores JSONB, -- Dados antes da modificação
  dados_novos     JSONB, -- Dados após a modificação
  ip_address      INET,
  user_agent      TEXT,
  data_hora       TIMESTAMP DEFAULT NOW(),
  sucesso         BOOLEAN DEFAULT true,
  mensagem_erro   TEXT
);

CREATE INDEX IF NOT EXISTS idx_evento_tipo_data          ON evento (id_tipo_evento, data_hora DESC);
CREATE INDEX IF NOT EXISTS idx_evento_localizacao        ON evento (id_localizacao);
CREATE INDEX IF NOT EXISTS idx_evento_status_data        ON evento (status, data_hora DESC);
CREATE INDEX IF NOT EXISTS idx_evento_prioridade         ON evento (prioridade DESC, data_hora DESC);
CREATE INDEX IF NOT EXISTS idx_localizacao_cidade_estado ON localizacao (estado, cidade);

CREATE INDEX IF NOT EXISTS idx_usuario_email             ON usuario_app (email);
CREATE INDEX IF NOT EXISTS idx_usuario_tipo              ON usuario_app (tipo_usuario);
CREATE INDEX IF NOT EXISTS idx_relato_evento_data        ON relato (id_evento, data_hora DESC);
CREATE INDEX IF NOT EXISTS idx_relato_usuario_data       ON relato (id_usuario, data_hora DESC);
CREATE INDEX IF NOT EXISTS idx_alerta_evento_data        ON alerta (id_evento, data_hora DESC);
CREATE INDEX IF NOT EXISTS idx_alerta_usuario_nivel      ON alerta (id_usuario_destinatario, nivel, data_hora DESC);
CREATE INDEX IF NOT EXISTS idx_notificacao_usuario_data  ON notificacao (id_usuario, data_envio DESC);
CREATE INDEX IF NOT EXISTS idx_notificacao_tipo_status   ON notificacao (tipo, status_envio, data_envio DESC);
CREATE INDEX IF NOT EXISTS idx_config_notif_usuario      ON configuracao_notificacao (id_usuario);
CREATE INDEX IF NOT EXISTS idx_log_acao_usuario_data     ON log_acao (id_usuario, data_hora DESC);
CREATE INDEX IF NOT EXISTS idx_log_acao_tabela_data      ON log_acao (tabela_afetada, data_hora DESC);
