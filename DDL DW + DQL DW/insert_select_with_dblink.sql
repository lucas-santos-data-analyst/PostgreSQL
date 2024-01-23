--########### /////////// ###########


DELETE FROM cron.job WHERE jobid = 14;

SELECT DISTINCT
    MAX(db.update_at)
FROM wb_detailed_basis db;

UPDATE cron.job SET schedule ='0 2 * * *' WHERE jobid = 14;

SELECT * FROM cron.job;

UPDATE cron.job SET active = FALSE WHERE active=TRUE;


--###### CREATE TASK #######

SELECT cron.schedule(
               'att_dash',
               '30 2 * * *',
               $$
                   DELETE FROM wb_financers_natures;
INSERT INTO public.wb_financers_natures (
    title_id,
    financer_nature,
    financer_nature_code,
    fiscal_operation,
    fiscal_operation_code,
    update_at )
SELECT
    title_id,
    financer_nature,
    financer_nature_code,
    fiscal_operation,
    fiscal_operation_code,
    update_at
FROM dw_staging.dblink(
             'host=000.00.00.000 user=user_user password=**************** dbname=dbname****',
             e'
                    SELECT DISTINCT
                        frt.id title_id,
                        fn.title financer_nature,
                        fn.code financer_nature_code,
                        fo.title fiscal_operation,
                        fo.code fiscal_operation_code,
                        now()::timestamp update_at
                    FROM financial_receivable_titles frt
                        LEFT JOIN financers_natures fn ON fn.id = frt.financer_nature_id
                        LEFT JOIN financial_operations fo ON fo.id = frt.financial_operation_id
                    WHERE frt.deleted = FALSE
                      AND frt.finished = FALSE
                      AND frt.renegotiated = FALSE
                      AND frt.issue_date::DATE >= DATE(YEAR(curdate()) - 1 || ''-'' || MONTH(curdate()) || ''-1'');
                    ') destiny (
                                              title_id              VARCHAR,
                                              financer_nature       VARCHAR,
                                              financer_nature_code  VARCHAR,
                                              fiscal_operation      VARCHAR,
                                              fiscal_operation_code VARCHAR,
                                              update_at             TIMESTAMP);

INSERT INTO
    public.wb_billings (
    title_id,
    client_id,
    contract_id,
    title_number,
    title_amount,
    expiration_date,
    issue_date,
    receipt_date,
    rollrate_date,
    title_type,
    title_balance,
    title_receipt_amount,
    fine_amount,
    increase_amount,
    total_amount,
    payment_form,
    renegotiation_number,
    renegotiation_date,
    renegotiation_type,
    update_at
)
SELECT
    title_id,
    client_id,
    contract_id,
    title_number,
    title_amount,
    expiration_date,
    issue_date,
    receipt_date,
    rollrate_date,
    title_type,
    title_balance,
    title_receipt_amount,
    fine_amount,
    increase_amount,
    total_amount,
    payment_form,
    renegotiation_number,
    renegotiation_date,
    renegotiation_type,
    update_at
FROM dw_staging.dblink(
             'host=000.00.00.000 user=user_user password=**************** dbname=dbname****',
             e'
                    WITH
                        title_type AS (SELECT DISTINCT
                            frt.id title_id,
                            CASE
                                WHEN frt.origin = 8
                                    AND t.origin = 4
                                    THEN ''Fat. Mensal''
                                WHEN frt.origin = 8
                                    AND t.origin = 44
                                    THEN ''Fat. Antecipado''
                                ELSE fn.title
                                END "type"
                        FROM financial_receivable_titles frt
                            LEFT JOIN financial_receivable_titles t ON (t.bill_title_id = frt.id)
                            LEFT JOIN financers_natures fn ON fn.id = frt.financer_nature_id
                        WHERE frt.deleted = FALSE
                            AND frt.finished = FALSE
                            AND frt.renegotiated = FALSE),
                        reneg AS (SELECT DISTINCT * FROM(SELECT DISTINCT
                            MAX(rng.id) OVER (PARTITION BY rng.financial_receivable_title_id) mx,
                            rng.id,
                            rng.financial_receivable_title_id tit_ren,
                            rng.financial_renegotiation_id ren,
                            CASE WHEN rn.date IS NULL THEN rn.created::DATE
                                ELSE rn.date::DATE
                                END dt_ren,
                            CASE WHEN rng.type = 1 THEN ''Renegociação''
                                ELSE ''Renegociado''
                                END tipo
                        FROM financial_renegotiation_titles rng
                            INNER JOIN financial_renegotiations rn
                            ON (rn.id = rng.financial_renegotiation_id
                                AND rn.deleted = FALSE)) r
                        WHERE r.id = r.mx)
                    SELECT DISTINCT
                        frt.id title_id,
                        frt.client_id client_id,
                        frt.contract_id contract_id,
                        frt.title title_number,
                        frt.title_amount title_amount,
                        frt.expiration_date::DATE expiration_date,
                        frt.issue_date::DATE issue_date,
                        f.receipt_date::DATE receipt_date,
                        CASE
                            WHEN f.receipt_date::DATE IS NULL AND r.dt_ren::DATE IS NULL THEN curdate()::DATE
                            WHEN f.receipt_date::DATE IS NULL THEN r.dt_ren::DATE
                            ELSE f.receipt_date::DATE
                            END rollrate_date,
                        tt.type title_type,
                        CASE
                            WHEN frt.balance < 0 THEN 0
                            ELSE frt.balance
                            END title_balance,
                        f.amount title_receipt_amount,
                        f.fine_amount fine_amount,
                        f.increase_amount increase_amount,
                        f.total_amount total_amount,
                        pf.title payment_form,
                        r.ren renegotiation_number,
                        r.dt_ren renegotiation_date,
                        r.tipo renegotiation_type,
                        now()::timestamp update_at
                    FROM financial_receivable_titles frt
                        LEFT JOIN financial_receipt_titles f ON f.financial_receivable_title_id = frt.id
                        LEFT JOIN payment_forms pf ON pf.id = f.payment_form_id
                        LEFT JOIN financers_natures fn ON fn.id = frt.financer_nature_id
                        LEFT JOIN reneg r ON r.tit_ren = frt.id
                        LEFT JOIN title_type tt ON tt.title_id = frt.id
                    WHERE frt.deleted = FALSE
                        AND frt.finished = FALSE
                        AND frt.renegotiated = FALSE
                        AND frt.issue_date::DATE >= DATE(YEAR(curdate()) - 1 || ''-'' || MONTH(curdate()) || ''-1'');
                    ') destiny (
                                              title_id           VARCHAR, client_id            VARCHAR,  contract_id          VARCHAR,
                                              title_number       VARCHAR, title_amount         DECIMAL,  expiration_date      DATE,
                                              issue_date         DATE,    receipt_date         DATE,     rollrate_date        DATE,
                                              title_type         VARCHAR, title_balance        DECIMAL,  title_receipt_amount DECIMAL,
                                              fine_amount        DECIMAL, increase_amount      DECIMAL,  total_amount         DECIMAL,
                                              payment_form       VARCHAR, renegotiation_number VARCHAR,  renegotiation_date   DATE,
                                              renegotiation_type VARCHAR, update_at            TIMESTAMP );

INSERT INTO
    public.wb_receipts (
    title_id,
    client_id,
    contract_id,
    title_number,
    title_amount,
    expiration_date,
    issue_date,
    receipt_date,
    rollrate_date,
    title_type,
    title_balance,
    title_receipt_amount,
    fine_amount,
    increase_amount,
    total_amount,
    payment_form,
    renegotiation_number,
    renegotiation_date,
    renegotiation_type,
    update_at
)
SELECT
    title_id,
    client_id,
    contract_id,
    title_number,
    title_amount,
    expiration_date,
    issue_date,
    receipt_date,
    rollrate_date,
    title_type,
    title_balance,
    title_receipt_amount,
    fine_amount,
    increase_amount,
    total_amount,
    payment_form,
    renegotiation_number,
    renegotiation_date,
    renegotiation_type,
    update_at
FROM dw_staging.dblink(
             'host=000.00.00.000 user=user_user password=**************** dbname=dbname****',
             e'WITH
                        title_type AS (SELECT DISTINCT
                            frt.id title_id,
                            CASE
                                WHEN frt.origin = 8
                                    AND t.origin = 4
                                    THEN ''Fat. Mensal''
                                WHEN frt.origin = 8
                                    AND t.origin = 44
                                    THEN ''Fat. Antecipado''
                                ELSE fn.title
                                END "type"
                        FROM financial_receivable_titles frt
                            LEFT JOIN financial_receivable_titles t ON (t.bill_title_id = frt.id)
                            LEFT JOIN financers_natures fn ON fn.id = frt.financer_nature_id
                        WHERE frt.deleted = FALSE
                            AND frt.finished = FALSE
                            AND frt.renegotiated = FALSE),
                        reneg AS (SELECT DISTINCT * FROM(SELECT DISTINCT
                            MAX(rng.id) OVER (PARTITION BY rng.financial_receivable_title_id) mx,
                            rng.id,
                            rng.financial_receivable_title_id tit_ren,
                            rng.financial_renegotiation_id ren,
                            CASE WHEN rn.date IS NULL THEN rn.created::DATE
                                ELSE rn.date::DATE
                                END dt_ren,
                            CASE WHEN rng.type = 1 THEN ''Renegociação''
                                ELSE ''Renegociado''
                                END tipo
                        FROM financial_renegotiation_titles rng
                            INNER JOIN financial_renegotiations rn
                            ON (rn.id = rng.financial_renegotiation_id
                                AND rn.deleted = FALSE)) r
                        WHERE r.id = r.mx)
                    SELECT DISTINCT
                        frt.id title_id,
                        frt.client_id client_id,
                        frt.contract_id contract_id,
                        frt.title title_number,
                        frt.title_amount title_amount,
                        frt.expiration_date::DATE expiration_date,
                        frt.issue_date::DATE issue_date,
                        f.receipt_date::DATE receipt_date,
                        CASE
                            WHEN f.receipt_date::DATE IS NULL AND r.dt_ren::DATE IS NULL THEN curdate()::DATE
                            WHEN f.receipt_date::DATE IS NULL THEN r.dt_ren::DATE
                            ELSE f.receipt_date::DATE
                            END rollrate_date,
                        tt.type title_type,
                        CASE
                            WHEN frt.balance < 0 THEN 0
                            ELSE frt.balance
                            END title_balance,
                        f.amount title_receipt_amount,
                        f.fine_amount fine_amount,
                        f.increase_amount increase_amount,
                        f.total_amount total_amount,
                        pf.title payment_form,
                        r.ren renegotiation_number,
                        r.dt_ren renegotiation_date,
                        r.tipo renegotiation_type,
                        now()::timestamp update_at
                    FROM financial_receivable_titles frt
                        LEFT JOIN financial_receipt_titles f ON f.financial_receivable_title_id = frt.id
                        LEFT JOIN payment_forms pf ON pf.id = f.payment_form_id
                        LEFT JOIN financers_natures fn ON fn.id = frt.financer_nature_id
                        LEFT JOIN reneg r ON r.tit_ren = frt.id
                        LEFT JOIN title_type tt ON tt.title_id = frt.id
                    WHERE frt.deleted = FALSE
                        AND frt.finished = FALSE
                        AND frt.renegotiated = FALSE
                        AND f.receipt_date::DATE >= DATE(YEAR(curdate()) - 1 || ''-'' || MONTH(curdate()) || ''-1'');
                    ') destiny (
                                              title_id           VARCHAR, client_id            VARCHAR,  contract_id          VARCHAR,
                                              title_number       VARCHAR, title_amount         DECIMAL,  expiration_date      DATE,
                                              issue_date         DATE,    receipt_date         DATE,     rollrate_date        DATE,
                                              title_type         VARCHAR, title_balance        DECIMAL,  title_receipt_amount DECIMAL,
                                              fine_amount        DECIMAL, increase_amount      DECIMAL,  total_amount         DECIMAL,
                                              payment_form       VARCHAR, renegotiation_number VARCHAR,  renegotiation_date   DATE,
                                              renegotiation_type VARCHAR, update_at            TIMESTAMP            );

INSERT INTO
    public.wb_expirations (
    title_id,
    client_id,
    contract_id,
    title_number,
    title_amount,
    expiration_date,
    issue_date,
    receipt_date,
    rollrate_date,
    title_type,
    title_balance,
    title_receipt_amount,
    fine_amount,
    increase_amount,
    total_amount,
    payment_form,
    renegotiation_number,
    renegotiation_date,
    renegotiation_type,
    update_at
)
SELECT
    title_id,
    client_id,
    contract_id,
    title_number,
    title_amount,
    expiration_date,
    issue_date,
    receipt_date,
    rollrate_date,
    title_type,
    title_balance,
    title_receipt_amount,
    fine_amount,
    increase_amount,
    total_amount,
    payment_form,
    renegotiation_number,
    renegotiation_date,
    renegotiation_type,
    update_at
FROM dw_staging.dblink(
             'host=000.00.00.000 user=user_user password=**************** dbname=dbname****',
             e'WITH
                        title_type AS (SELECT DISTINCT
                            frt.id title_id,
                            CASE
                                WHEN frt.origin = 8
                                    AND t.origin = 4
                                    THEN ''Fat. Mensal''
                                WHEN frt.origin = 8
                                    AND t.origin = 44
                                    THEN ''Fat. Antecipado''
                                ELSE fn.title
                                END "type"
                        FROM financial_receivable_titles frt
                            LEFT JOIN financial_receivable_titles t ON (t.bill_title_id = frt.id)
                            LEFT JOIN financers_natures fn ON fn.id = frt.financer_nature_id
                        WHERE frt.deleted = FALSE
                            AND frt.finished = FALSE
                            AND frt.renegotiated = FALSE),
                        reneg AS (SELECT DISTINCT * FROM(SELECT DISTINCT
                            MAX(rng.id) OVER (PARTITION BY rng.financial_receivable_title_id) mx,
                            rng.id,
                            rng.financial_receivable_title_id tit_ren,
                            rng.financial_renegotiation_id ren,
                            CASE WHEN rn.date IS NULL THEN rn.created::DATE
                                ELSE rn.date::DATE
                                END dt_ren,
                            CASE WHEN rng.type = 1 THEN ''Renegociação''
                                ELSE ''Renegociado''
                                END tipo
                        FROM financial_renegotiation_titles rng
                            INNER JOIN financial_renegotiations rn
                            ON (rn.id = rng.financial_renegotiation_id
                                AND rn.deleted = FALSE)) r
                        WHERE r.id = r.mx)
                    SELECT DISTINCT
                        frt.id title_id,
                        frt.client_id client_id,
                        frt.contract_id contract_id,
                        frt.title title_number,
                        frt.title_amount title_amount,
                        frt.expiration_date::DATE expiration_date,
                        frt.issue_date::DATE issue_date,
                        f.receipt_date::DATE receipt_date,
                        CASE
                            WHEN f.receipt_date::DATE IS NULL AND r.dt_ren::DATE IS NULL THEN curdate()::DATE
                            WHEN f.receipt_date::DATE IS NULL THEN r.dt_ren::DATE
                            ELSE f.receipt_date::DATE
                            END rollrate_date,
                        tt.type title_type,
                        CASE
                            WHEN frt.balance < 0 THEN 0
                            ELSE frt.balance
                            END title_balance,
                        f.amount title_receipt_amount,
                        f.fine_amount fine_amount,
                        f.increase_amount increase_amount,
                        f.total_amount total_amount,
                        pf.title payment_form,
                        r.ren renegotiation_number,
                        r.dt_ren renegotiation_date,
                        r.tipo renegotiation_type,
                        now()::timestamp update_at
                    FROM financial_receivable_titles frt
                        LEFT JOIN financial_receipt_titles f ON f.financial_receivable_title_id = frt.id
                        LEFT JOIN payment_forms pf ON pf.id = f.payment_form_id
                        LEFT JOIN financers_natures fn ON fn.id = frt.financer_nature_id
                        LEFT JOIN reneg r ON r.tit_ren = frt.id
                        LEFT JOIN title_type tt ON tt.title_id = frt.id
                    WHERE frt.deleted = FALSE
                        AND frt.finished = FALSE
                        AND frt.renegotiated = FALSE
                        AND frt.expiration_date::DATE >= DATE(YEAR(curdate()) - 1 || ''-'' || MONTH(curdate()) || ''-1'');
                    ') destiny (
                                              title_id           VARCHAR, client_id            VARCHAR,  contract_id          VARCHAR,
                                              title_number       VARCHAR, title_amount         DECIMAL,  expiration_date      DATE,
                                              issue_date         DATE,    receipt_date         DATE,     rollrate_date        DATE,
                                              title_type         VARCHAR, title_balance        DECIMAL,  title_receipt_amount DECIMAL,
                                              fine_amount        DECIMAL, increase_amount      DECIMAL,  total_amount         DECIMAL,
                                              payment_form       VARCHAR, renegotiation_number VARCHAR,  renegotiation_date   DATE,
                                              renegotiation_type VARCHAR, update_at            TIMESTAMP            );

INSERT INTO
    public.wb_detailed_basis (
    contract_id,           registration_document,   city,
    contract_number,       contract_amount,         client_type,
    contract_type,         cancellation_end_date,   date_sale,
    billing_type,          cancellation_motive,     connection_status,
    contract_stage,        contract_status,         has_connection,
    number_of_connections, base_life_time,          approval_date,
    provider,              payment_type,            client_situation,
    update_at
)
SELECT
    contract_id,           registration_document,   city,
    contract_number,       contract_amount,         client_type,
    contract_type,         cancellation_end_date,   date_sale,
    billing_type,          cancellation_motive,     connection_status,
    contract_stage,        contract_status,         has_connection,
    number_of_connections, base_life_time,          approval_date,
    provider,              payment_type,            client_situation,
    update_at
FROM dw_staging.dblink(
             'host=000.00.00.000 user=user_user password=**************** dbname=dbname****',
             e'WITH
                        life_time_basis AS (SELECT DISTINCT
                            c.id contract_id,
                            (datediff(
                                NOW(),
                                COALESCE(c.approval_date, c.created::DATE))
                                / 30) days
                        FROM contracts c
                        WHERE c.deleted = FALSE),
                        cnx_count AS (SELECT
                            ac2.contract_id,
                            count(DISTINCT ac2.user) num_connections
                        FROM authentication_contracts ac2
                            JOIN contracts AS con ON (ac2.contract_id = con.id)
                        WHERE con.deleted = FALSE
                        GROUP BY 1),
                        cancellation_motive AS (SELECT
                            c.id id_contrato,
                            MAX(cet.title) AS mot
                        FROM contracts c
                            JOIN contract_events ce ON ce.contract_id = c.id
                            JOIN contract_event_types cet ON cet.id = ce.contract_event_type_id
                        WHERE c.stage = 3
                            AND cet.objective IN (2, 4)
                            AND c.status IN (4, 9)
                            AND c.deleted = FALSE
                        GROUP BY c.id),
                        total_contract_items AS (SELECT DISTINCT
                            c.id AS contract_id,
                            (CASE WHEN (sum(ci.total_amount) OVER (PARTITION BY ci.contract_id) >= 300 AND pessoas.type_tx_id = 1) THEN ''B2B - Big Accounts'' ELSE NULL END) AS c_valor,
                            c.client_id,
                            (CASE WHEN (sum(ci.total_amount) OVER (PARTITION BY LEFT(pessoas.tx_id, 8)) >= 300 AND pessoas.type_tx_id = 1) THEN ''B2B - Big Accounts'' ELSE NULL END) AS clt_valor
                        FROM contract_items ci
                            JOIN contracts AS c ON (ci.contract_id = c.id)
                            JOIN people pessoas ON pessoas.id = c.client_id
                        WHERE ci.deleted = FALSE
                            AND ci.is_composition = FALSE
                            AND c.deleted = FALSE
                            AND c.stage = 3)
                    SELECT DISTINCT
                        c.id::TEXT contract_id,
                        p.tx_id registration_document,
                        UPPER(pa.city) city,
                        UPPER(pa.state) state,
                        c.contract_number contract_number,
                        c.amount contract_amount,
                        CASE
                            WHEN ct.id IN (217, 218, 219, 246, 248, 255) THEN ''ISP''
                            WHEN ct.id IN (17, 226, 247, 239, 173, 158, 254) THEN ''Government''
                            WHEN p.name ILIKE ANY (
                                ARRAY [
                                    ''%City Hall%'',
                                    ''%chamber%'',
                                    ''%secretary%'',
                                    ''%County%''
                                    ]) THEN ''Government''
                            WHEN COALESCE(tci.clt_valor, tci.c_valor) IS NOT NULL THEN COALESCE(tci.clt_valor, tci.c_valor)
                            WHEN p.type_tx_id = 1 THEN ''MPE''
                            ELSE ''B2C''
                            END client_type,
                        CASE
                            WHEN c.status = 9 THEN c.end_date::DATE
                            WHEN c.status = 4 THEN c.cancellation_date::DATE
                            END cancellation_date,
                        c.created::date date_sale,
                        CASE
                            WHEN c.invoice_type = 1 THEN ''Monthly (Simple)''
                            WHEN c.invoice_type = 2 THEN ''Multiple Operations''
                            WHEN c.invoice_type = 3 THEN ''SCM/SVA Communication''
                            WHEN c.invoice_type = 4 THEN ''Advance''
                            WHEN c.invoice_type = 5 THEN ''Does not provide for billing''
                            END billing_type,
                        CASE
                            WHEN (c.stage = 3 AND c.status IN (4, 9))
                                THEN mot.mot
                            WHEN (c.stage = 5 AND c.status = 4)
                                THEN ''Installation not carried out''
                            ELSE NULL
                            END cancellation_motive,
                        CASE
                            WHEN ac.authentication_address_list_id = 3 THEN ''Block Notice''
                            WHEN ac.authentication_address_list_id = 2 THEN ''Block''
                            WHEN ac.authentication_address_list_id = 1 THEN ''Normal''
                            END connection_status,
                        c.v_stage contract_stage,
                        c.v_status contract_status,
                        CASE
                            WHEN ac.id IS NULL THEN ''NOT''
                            ELSE ''YES''
                            END has_connection,
                        conx.num_connections number_of_connections,
                        CASE
                            WHEN lf.days < 4 THEN ''00 a 03 Months''
                            WHEN lf.days <= 6 THEN ''04 a 06 Months''
                            WHEN lf.days <= 12 THEN ''07 a 12 Months''
                            WHEN lf.days <= 15 THEN ''13 a 15 Months''
                            WHEN lf.days <= 18 THEN ''16 a 18 Months''
                            WHEN lf.days <= 21 THEN ''19 a 21 Months''
                            WHEN lf.days <= 24 THEN ''22 a 24 Months''
                            WHEN lf.days > 24 THEN ''24 Months or more''
                            END base_life_time,
                        c.approval_date approval_date,
                        CASE
                            WHEN c.erp_code ILIKE ''%provider1%'' THEN ''Provider 1''
                            WHEN c.erp_code ILIKE ''%provider2%'' THEN ''Provider 2''
                            WHEN c.erp_code ILIKE ''%provider3%'' THEN ''Provider 3''
                            WHEN c.erp_code ILIKE ''%provider4%'' THEN ''Provider 4''
                            ELSE ''Provider Main''
                            END provider,
                        CASE
                            WHEN c.people_card_token_id IS NOT NULL THEN ''Recurrence''
                            ELSE ''Ticket''
                            END payment_type,
                        CASE
                            WHEN (c.status NOT IN (4, 9) AND c.stage = 3) THEN ''Active Customer''
                            WHEN (c.status IN (4, 9) AND c.stage = 3) THEN ''Former Client''
                            ELSE ''Canceled Sale''
                            END client_situation,
                        now()::timestamp update_at
                    FROM contracts c
                        JOIN contract_events ce ON (ce.contract_id = c.id AND c.deleted = FALSE)
                        JOIN contract_event_types cet ON (cet.id = ce.contract_event_type_id)
                        JOIN people p ON (p.id = c.client_id)
                        LEFT JOIN contract_types ct ON (ct.id = c.contract_type_id)
                        LEFT JOIN people_addresses pa ON (pa.id = c.people_address_id)
                        LEFT JOIN people vdd ON (vdd.id = c.seller_1_id)
                        LEFT JOIN authentication_contracts ac ON (ac.contract_id = c.id)
                        LEFT JOIN life_time_basis AS lf ON (c.id = lf.contract_id)
                        LEFT JOIN cnx_count conx ON (conx.contract_id = c.id)
                        LEFT JOIN cancellation_motive mot ON (mot.id_contrato = c.id)
                        LEFT JOIN total_contract_items cvlr ON (cvlr.contract_id = c.id)
                        LEFT JOIN total_contract_items valor ON (valor.client_id = p.id)
                        LEFT JOIN total_contract_items AS tci ON (tci.contract_id = c.id)
                    WHERE cet.id NOT IN (181, 198, 207, 197, 128, 180, 183, 127, 200, 129, 182, 192, 209, 205, 206)
                        AND c.deleted = FALSE
                        AND c.stage = 3;
                    ') destiny (
                                              contract_id           VARCHAR,   registration_document VARCHAR,  city              VARCHAR,
                                              contract_number       VARCHAR,   contract_amount       VARCHAR,  client_type       VARCHAR,
                                              contract_type         VARCHAR,   cancellation_end_date DATE,     date_sale         DATE,
                                              billing_type          VARCHAR,   cancellation_motive   VARCHAR,  connection_status VARCHAR,
                                              contract_stage        VARCHAR,   contract_status       VARCHAR,  has_connection    VARCHAR,
                                              number_of_connections INT,       base_life_time        VARCHAR,  approval_date     DATE,
                                              provider              VARCHAR,   payment_type          VARCHAR,  client_situation  VARCHAR,
                                              update_at             TIMESTAMP);
$$
);


SELECT * FROM cron.job;

RUN JOB att_dash;

execute cron.job where cron.job.jobid = 15