-- CRIANDO UMA TABELA DE TESTES, PARA GUARDAR OS DADOS
DROP TABLE IF EXISTS connector.cron_job_test;
CREATE TABLE connector.cron_job_test(id int8, created_at timestamptz);

-- AGENDANDO O CROM QUE RODA DE 5 EM 5 MINUTOS, EXECUTANDO UM INSERT NA TABELA CRIADA
SELECT cron.schedule(
               'test-job-run-details',
               '*/5 * * * *',
               $$
                   INSERT INTO connector.cron_job_test(id,created_at) SELECT 1,NOW();
$$);

-- VALIDAÇÃO DE QUE O CRON FOI CRIADO E ESTÁ ATIVO PARA SER EXECUTADO
SELECT * FROM cron.job;

-- VALIDAÇÃO SE O CRON ESTÁ EXECUTANDO CORRETAMENTE
-- APÓS 15 MINUTOS DEVEM EXISTIR 3 REGISTROS NESTA TEBELA
SELECT * FROM connector.cron_job_test;

-- REAIZAÇÃO DO "DESAGENDAMENTO DO CRON CRIADO"
-- A VARIÁVEL ID, DEVE SER SUBSTITUIDA PELO ID DA TABELA cron.job, DO CRON EM QUESTÃO
SELECT cron.unschedule(ID);
