
DROP DATABASE IF EXISTS petvida;
CREATE DATABASE petvida
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE petvida;


-- FUNCIONARIO

CREATE TABLE funcionario (
    id_funcionario INT          NOT NULL AUTO_INCREMENT,
    nome           VARCHAR(100) NOT NULL,
    email          VARCHAR(100) NOT NULL,
    senha_hash     VARCHAR(255) NOT NULL,
    telefone       VARCHAR(20)  NOT NULL,
    perfil         ENUM('recepcionista', 'veterinario', 'gerente') NOT NULL,
    ativo          TINYINT(1)   NOT NULL DEFAULT 1,
    CONSTRAINT pk_funcionario PRIMARY KEY (id_funcionario),
    CONSTRAINT uk_funcionario_email UNIQUE (email)
) ENGINE = InnoDB;


-- VETERINARIO
CREATE TABLE veterinario (
    id_funcionario INT         NOT NULL,
    crmv           VARCHAR(20) NOT NULL,
    CONSTRAINT pk_veterinario PRIMARY KEY (id_funcionario),
    CONSTRAINT uk_veterinario_crmv UNIQUE (crmv),
    CONSTRAINT fk_veterinario_funcionario FOREIGN KEY (id_funcionario)
        REFERENCES funcionario (id_funcionario)
) ENGINE = InnoDB;


-- TUTOR

CREATE TABLE tutor (
    id_tutor    INT          NOT NULL AUTO_INCREMENT,
    nome        VARCHAR(100) NOT NULL,
    cpf         CHAR(11)     NOT NULL,          -- só números, sem pontos e traço
    telefone    VARCHAR(20)  NOT NULL,
    email       VARCHAR(100) NULL,
    logradouro  VARCHAR(150) NOT NULL,
    numero      VARCHAR(10)  NOT NULL,
    complemento VARCHAR(50)  NULL,
    bairro      VARCHAR(80)  NOT NULL,
    cidade      VARCHAR(80)  NOT NULL,
    estado      CHAR(2)      NOT NULL,
    cep         CHAR(8)      NOT NULL,          -- só números
    CONSTRAINT pk_tutor PRIMARY KEY (id_tutor),
    CONSTRAINT uk_tutor_cpf UNIQUE (cpf)
) ENGINE = InnoDB;


-- ANIMAL


CREATE TABLE animal (
    id_animal         INT          NOT NULL AUTO_INCREMENT,
    id_tutor          INT          NOT NULL,
    nome              VARCHAR(60)  NOT NULL,
    especie           ENUM('cao', 'gato', 'ave', 'roedor') NOT NULL,
    raca              VARCHAR(60)  NULL,
    sexo              ENUM('M', 'F') NOT NULL,
    data_nascimento   DATE         NULL,
    nasc_aproximada   TINYINT(1)   NOT NULL DEFAULT 0,  -- 1 = data estimada
    CONSTRAINT pk_animal PRIMARY KEY (id_animal),
    CONSTRAINT fk_animal_tutor FOREIGN KEY (id_tutor)
        REFERENCES tutor (id_tutor)
) ENGINE = InnoDB;


-- SERVICO
CREATE TABLE servico (
    id_servico  INT           NOT NULL AUTO_INCREMENT,
    nome        VARCHAR(80)   NOT NULL,
    descricao   VARCHAR(255)  NULL,
    preco_atual DECIMAL(10,2) NOT NULL,
    CONSTRAINT pk_servico PRIMARY KEY (id_servico),
    CONSTRAINT uk_servico_nome UNIQUE (nome),
    CONSTRAINT ck_servico_preco CHECK (preco_atual >= 0)
) ENGINE = InnoDB;


-- AGENDAMENTO


CREATE TABLE agendamento (
    id_agendamento  INT      NOT NULL AUTO_INCREMENT,
    id_animal       INT      NOT NULL,
    id_veterinario  INT      NOT NULL,
    id_agendado_por INT      NOT NULL,
    data_hora       DATETIME NOT NULL,
    status          ENUM('agendado', 'confirmado', 'realizado', 'cancelado', 'faltou')
                    NOT NULL DEFAULT 'agendado',
    slot_ativo      DATETIME AS (
                        CASE WHEN status = 'cancelado' THEN NULL ELSE data_hora END
                    ) STORED,
    CONSTRAINT pk_agendamento PRIMARY KEY (id_agendamento),
    CONSTRAINT uk_agendamento_vet_horario UNIQUE (id_veterinario, slot_ativo),
    CONSTRAINT ck_agendamento_slot CHECK (
        MINUTE(data_hora) IN (0, 30) AND SECOND(data_hora) = 0
    ),
    CONSTRAINT fk_agendamento_animal FOREIGN KEY (id_animal)
        REFERENCES animal (id_animal),
    CONSTRAINT fk_agendamento_veterinario FOREIGN KEY (id_veterinario)
        REFERENCES veterinario (id_funcionario),
    CONSTRAINT fk_agendamento_funcionario FOREIGN KEY (id_agendado_por)
        REFERENCES funcionario (id_funcionario)
) ENGINE = InnoDB;


-- ATENDIMENTO

CREATE TABLE atendimento (
    id_atendimento INT          NOT NULL AUTO_INCREMENT,
    id_agendamento INT          NOT NULL,
    peso           DECIMAL(6,2) NOT NULL,       -- em kg
    diagnostico    TEXT         NULL,
    observacoes    TEXT         NULL,
    CONSTRAINT pk_atendimento PRIMARY KEY (id_atendimento),
    CONSTRAINT uk_atendimento_agendamento UNIQUE (id_agendamento),
    CONSTRAINT ck_atendimento_peso CHECK (peso > 0),
    CONSTRAINT fk_atendimento_agendamento FOREIGN KEY (id_agendamento)
        REFERENCES agendamento (id_agendamento)
) ENGINE = InnoDB;


-- ATENDIMENTO_SERVICO
CREATE TABLE atendimento_servico (
    id_atendimento INT           NOT NULL,
    id_servico     INT           NOT NULL,
    quantidade     INT           NOT NULL DEFAULT 1,
    preco_cobrado  DECIMAL(10,2) NOT NULL,
    CONSTRAINT pk_atendimento_servico PRIMARY KEY (id_atendimento, id_servico),
    CONSTRAINT ck_atend_serv_quantidade CHECK (quantidade > 0),
    CONSTRAINT ck_atend_serv_preco CHECK (preco_cobrado >= 0),
    CONSTRAINT fk_atend_serv_atendimento FOREIGN KEY (id_atendimento)
        REFERENCES atendimento (id_atendimento),
    CONSTRAINT fk_atend_serv_servico FOREIGN KEY (id_servico)
        REFERENCES servico (id_servico)
) ENGINE = InnoDB;