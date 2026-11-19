

USE petvida;


SET @id_veterinario = 4;      
SET @dia = CURDATE();             

SELECT
    TIME_FORMAT(ag.data_hora, '%H:%i') AS horario,
    an.nome                            AS animal,
    an.especie,
    t.nome                             AS tutor,
    ag.status
FROM agendamento ag
JOIN animal an ON an.id_animal = ag.id_animal
JOIN tutor  t  ON t.id_tutor   = an.id_tutor
WHERE ag.id_veterinario = @id_veterinario
  AND DATE(ag.data_hora) = @dia
  AND ag.status <> 'cancelado'
ORDER BY ag.data_hora;



SET @id_animal = 1;               -- Thor

SELECT
    DATE_FORMAT(ag.data_hora, '%d/%m/%Y %H:%i')                    AS data,
    f.nome                                                         AS veterinario,
    at.peso,
    at.diagnostico,
    GROUP_CONCAT(s.nome ORDER BY s.nome SEPARATOR ', ')            AS servicos
FROM atendimento at
JOIN agendamento         ag ON ag.id_agendamento = at.id_agendamento
JOIN funcionario         f  ON f.id_funcionario  = ag.id_veterinario
JOIN atendimento_servico ats ON ats.id_atendimento = at.id_atendimento
JOIN servico             s  ON s.id_servico      = ats.id_servico
WHERE ag.id_animal = @id_animal
GROUP BY at.id_atendimento, ag.data_hora, f.nome, at.peso, at.diagnostico
ORDER BY ag.data_hora DESC;


-- RELATÓRIO 3: Faturamento do mês, total e por veterinário
-- Usa o preco_cobrado (preço da época), nunca o preco_atual (RN05).
-- O período vai do dia 1 do mês até o dia 1 do mês seguinte.

SET @inicio_mes = DATE_FORMAT(CURDATE(), '%Y-%m-01');   -- ou '2026-11-01'
SET @fim_mes    = @inicio_mes + INTERVAL 1 MONTH;

-- 3a) Faturamento por veterinário
--     LEFT JOIN: veterinário sem atendimento no mês aparece com 0,00.
SELECT
    f.nome                                                   AS veterinario,
    COUNT(DISTINCT fat.id_atendimento)                       AS atendimentos,
    COALESCE(SUM(fat.quantidade * fat.preco_cobrado), 0)     AS faturamento
FROM veterinario v
JOIN funcionario f ON f.id_funcionario = v.id_funcionario
LEFT JOIN (
    SELECT ag.id_veterinario, ats.id_atendimento, ats.quantidade, ats.preco_cobrado
    FROM atendimento_servico ats
    JOIN atendimento at ON at.id_atendimento = ats.id_atendimento
    JOIN agendamento ag ON ag.id_agendamento = at.id_agendamento
    WHERE ag.data_hora >= @inicio_mes
      AND ag.data_hora <  @fim_mes
) AS fat ON fat.id_veterinario = v.id_funcionario
GROUP BY v.id_funcionario, f.nome
ORDER BY faturamento DESC;

-- 3b) Faturamento total do mês
SELECT
    DATE_FORMAT(@inicio_mes, '%m/%Y')                     AS mes,
    COUNT(DISTINCT at.id_atendimento)                     AS atendimentos,
    COALESCE(SUM(ats.quantidade * ats.preco_cobrado), 0)  AS faturamento_total
FROM atendimento_servico ats
JOIN atendimento at ON at.id_atendimento = ats.id_atendimento
JOIN agendamento ag ON ag.id_agendamento = at.id_agendamento
WHERE ag.data_hora >= @inicio_mes
  AND ag.data_hora <  @fim_mes;




SELECT
    s.nome                                   AS servico,
    SUM(ats.quantidade)                      AS vezes_realizado,
    SUM(ats.quantidade * ats.preco_cobrado)  AS faturamento
FROM atendimento_servico ats
JOIN servico     s  ON s.id_servico      = ats.id_servico
JOIN atendimento at ON at.id_atendimento = ats.id_atendimento
JOIN agendamento ag ON ag.id_agendamento = at.id_agendamento
WHERE ag.data_hora >= @inicio_mes
  AND ag.data_hora <  @fim_mes
GROUP BY s.id_servico, s.nome
ORDER BY vezes_realizado DESC, faturamento DESC
LIMIT 3;




SELECT
    TIME_FORMAT(ag.data_hora, '%H:%i')  AS horario,
    t.nome                              AS tutor,
    t.telefone,
    an.nome                             AS animal,
    f.nome                              AS veterinario,
    ag.status
FROM agendamento ag
JOIN animal      an ON an.id_animal      = ag.id_animal
JOIN tutor       t  ON t.id_tutor        = an.id_tutor
JOIN funcionario f  ON f.id_funcionario  = ag.id_veterinario
WHERE DATE(ag.data_hora) = CURDATE() + INTERVAL 1 DAY
  AND ag.status IN ('agendado', 'confirmado')
ORDER BY ag.data_hora;