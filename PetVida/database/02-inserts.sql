
-- 1. TUTOR

INSERT INTO tutor (
    nome, cpf, telefone, email, logradouro, numero,
    complemento, bairro, cidade, estado, cep
)
VALUES (
    'Pedro Alves', '56204681966', '11934679212',
    'Pedroalves@gmail.com', 'Rua das Flores', '150',
    'Apartamento 1', 'Centro', 'São Paulo', 'SP', '001001000'
);


-- 2. FUNCIONARIO

INSERT INTO funcionario (
    nome, email, senha_hash, telefone, perfil, ativo
)
VALUES
('Ana Souza', 'ana@email.com', 'hash1', '11996289039', 'veterinario', 1),
('Carlos Lima', 'carlos@gmail.com', 'hash2', '11963281039', 'veterinario', 1),
('Pedro Alves', 'pedro@email.com', 'hash3', '11934576813', 'gerente', 1);


-- 3. VETERINARIO

INSERT INTO veterinario (id_funcionario, crmv)
VALUES
(1, 'CRMV-SP-12345'),
(2, 'CRMV-SP-67890');


-- 4. ANIMAL

INSERT INTO animal (
    id_tutor, nome, especie, raca, sexo,
    data_nascimento, nasc_aproximada
)
VALUES
(1, 'Rex', 'cao', 'Labrador', 'M', '2022-05-10', 0),
(1, 'Mimi', 'gato', 'siames', 'F', '2023-08-15', 0);


-- 5. SERVICO

INSERT INTO servico (nome, descricao, preco_atual)
VALUES
('consulta veterinaria', 'consulta geral do animal', 120.00),
('vacinacao', 'aplicacao de vacina no animal', 80.00),
('banho', 'banho para animais', 50.00);


-- 6. AGENDAMENTO

INSERT INTO agendamento (
    id_animal, id_veterinario, id_agendado_por,
    data_hora, status
)
VALUES
(1, 1, 3, '2025-02-15 12:40:00', 'agendado'),
(2, 2, 3, '2025-03-04 09:00:00', 'realizado');


-- 7. ATENDIMENTO

INSERT INTO atendimento (
    id_agendamento, peso, diagnostico, observacoes
)
VALUES
(1, 12.50, 'Animal saudavel', 'Manter vacinas em dia'),
(2, 4.20, 'Leve irritacao na pele', 'Retornar em 15 dias');


-- 8. ATENDIMENTO_SERVICO

INSERT INTO atendimento_servico (
    id_atendimento, id_servico, quantidade, preco_cobrado
)
VALUES
(1, 1, 1, 120.00),
(1, 2, 1, 80.00),
(2, 3, 1, 50.00);


-- CONSULTA PARA CONFERIR OS TUTORES

SELECT id_tutor, nome FROM tutor;
