-- #################################################################

CREATE TABLE public.detailed_basis
(
    contract_id           VARCHAR(255) NOT NULL
        PRIMARY KEY,
    registration_document VARCHAR(14)  NULL,
    city                  VARCHAR(255) NULL,
    contract_number       VARCHAR(255) NULL,
    contract_amount       VARCHAR(255) NULL,
    client_type           VARCHAR(50)  NULL,
    contract_type         VARCHAR(255) NULL,
    cancellation_end_date DATE         NULL,
    date_sale             DATE         NULL,
    billing_type          VARCHAR(50)  NULL,
    cancellation_motive   VARCHAR(255) NULL,
    connection_status     VARCHAR(50)  NULL,
    contract_stage        VARCHAR(50)  NULL,
    contract_status       VARCHAR(50)  NULL,
    has_connection        INT          NULL,
    number_of_connections INT          NULL,
    base_life_time        VARCHAR(80)  NULL,
    approval_date         DATE         NULL,
    provider              VARCHAR(40)  NULL,
    payment_type          VARCHAR(30)  NULL,
    client_situation      VARCHAR(30)  NULL
);

ALTER TABLE wb_detailed_basis
ALTER TABLE has_connection TYPE VARCHAR(255);
ALTER TABLE public.wb_detailed_basis DROP CONSTRAINT detailed_basis_pkey;
ALTER TABLE public.detailed_basis ADD COLUMN update_at TIMESTAMP;
ALTER TABLE public.detailed_basis RENAME TO wb_detailed_basis;

CREATE INDEX approval_date
   ON public.detailed_basis (approval_date);

CREATE INDEX cancellation_end_date
   ON public.detailed_basis (cancellation_end_date);

CREATE INDEX client_type
   ON public.detailed_basis (client_type);

CREATE INDEX contract_id
   ON public.detailed_basis (contract_id);

CREATE INDEX contract_number
   ON public.detailed_basis (contract_number);

CREATE INDEX contract_status
   ON public.detailed_basis (contract_status);

CREATE INDEX provider
   ON public.detailed_basis (provider);

-- ########################################################################

CREATE TABLE public.expirations
(
    title_id             VARCHAR(50) ,
    client_id            VARCHAR(50) NULL,
    contract_id          VARCHAR(50) NULL,
    title_number         VARCHAR(50) NULL,
    title_amount         VARCHAR(50) NULL,
    expiration_date      DATE        NULL,
    issue_date           DATE        NULL,
    receipt_date         DATE        NULL,
    rollrate_date        DATE        NULL,
    title_type           VARCHAR(50) NULL,
    title_balance        DECIMAL     NULL,
    title_receipt_amount DECIMAL     NULL,
    fine_amount          DECIMAL     NULL,
    increase_amount      DECIMAL     NULL,
    total_amount         DECIMAL     NULL,
    payment_form         VARCHAR(50) NULL,
    renegotiation_number VARCHAR(50) NULL,
    renegotiation_date   DATE        NULL,
    renegotiation_type   VARCHAR(50) NULL,
    -- constraint contract_id_title
    --    foreign key (contract_id) references public.detailed_basis (contract_id)
);

ALTER TABLE wb_expirations
ALTER TABLE title_amount TYPE VARCHAR(255);

ALTER TABLE wb_expirations
ALTER TABLE title_type TYPE VARCHAR(255);

ALTER TABLE wb_expirations
ALTER TABLE payment_form TYPE VARCHAR(255);

ALTER TABLE wb_expirations
ALTER TABLE renegotiation_number TYPE VARCHAR(255);

ALTER TABLE wb_expirations
ALTER TABLE renegotiation_type TYPE VARCHAR(255);

ALTER TABLE public.wb_expirations DROP CONSTRAINT contract_id_title;
ALTER TABLE public.wb_expirations DROP CONSTRAINT expirations_pkey;
ALTER TABLE public.expirations ADD COLUMN update_at TIMESTAMP;
ALTER TABLE public.expirations RENAME TO wb_expirations;

CREATE INDEX client_id_wbe
   ON public.wb_expirations (client_id);

CREATE INDEX contract_id_wbe
   ON public.wb_expirations (contract_id);

CREATE INDEX expiration_date_wbe
   ON public.wb_expirations (expiration_date);

CREATE INDEX issue_date_wbe
   ON public.wb_expirations (issue_date);

CREATE INDEX receipt_date_wbe
   ON public.wb_expirations (receipt_date);

CREATE INDEX title_number_wbe
   ON public.wb_expirations (title_number);

-- ########################################################################

CREATE TABLE public.wb_billings
(
    title_id             VARCHAR(50) NOT NULL
        PRIMARY KEY,
    client_id            VARCHAR(50) NULL,
    contract_id          VARCHAR(50) NULL,
    title_number         VARCHAR(50) NULL,
    title_amount         VARCHAR(50) NULL,
    expiration_date      DATE        NULL,
    issue_date           DATE        NULL,
    receipt_date         DATE        NULL,
    rollrate_date        DATE        NULL,
    title_type           VARCHAR(50) NULL,
    title_balance        DECIMAL     NULL,
    title_receipt_amount DECIMAL     NULL,
    fine_amount          DECIMAL     NULL,
    increase_amount      DECIMAL     NULL,
    total_amount         DECIMAL     NULL,
    payment_form         VARCHAR(50) NULL,
    renegotiation_number VARCHAR(50) NULL,
    renegotiation_date   DATE        NULL,
    renegotiation_type   VARCHAR(50) NULL,
    constraint billings_ibfk_1
        foreign key (contract_id) references public.detailed_basis (contract_id)
);

ALTER TABLE wb_billings
ALTER TABLE title_amount TYPE VARCHAR(255);

ALTER TABLE wb_billings
ALTER TABLE title_type TYPE VARCHAR(255);

ALTER TABLE wb_billings
ALTER TABLE payment_form TYPE VARCHAR(255);

ALTER TABLE wb_billings
ALTER TABLE renegotiation_number TYPE VARCHAR(255);

ALTER TABLE wb_billings
ALTER TABLE renegotiation_type TYPE VARCHAR(255);

ALTER TABLE public.wb_billings DROP CONSTRAINT billings_ibfk_1;
ALTER TABLE public.wb_billings DROP CONSTRAINT billings_pkey;
ALTER TABLE public.wb_billings RENAME TO wb_billings;
ALTER TABLE public.wb_billings ADD COLUMN update_at TIMESTAMP;

CREATE INDEX client_id_wbb
   ON public.wb_billings (client_id);

CREATE INDEX contract_id_wbb
   ON public.wb_billings (contract_id);

CREATE INDEX expiration_date_wbb
   ON public.wb_billings (expiration_date);

CREATE INDEX issue_date_wbb
   ON public.wb_billings (issue_date);

CREATE INDEX receipt_date_wbb
   ON public.wb_billings (receipt_date);

CREATE INDEX title_number_wbb
   ON public.wb_billings (title_number);

-- ########################################################################

CREATE TABLE public.receipts
(
    title_id             VARCHAR(50) NOT NULL
        PRIMARY KEY,
    client_id            VARCHAR(50) NULL,
    contract_id          VARCHAR(50) NULL,
    title_number         VARCHAR(50) NULL,
    title_amount         VARCHAR(50) NULL,
    expiration_date      DATE        NULL,
    issue_date           DATE        NULL,
    receipt_date         DATE        NULL,
    rollrate_date        DATE        NULL,
    title_type           VARCHAR(50) NULL,
    title_balance        DECIMAL     NULL,
    title_receipt_amount DECIMAL     NULL,
    fine_amount          DECIMAL     NULL,
    increase_amount      DECIMAL     NULL,
    total_amount         DECIMAL     NULL,
    payment_form         VARCHAR(50) NULL,
    renegotiation_number VARCHAR(50) NULL,
    renegotiation_date   DATE        NULL,
    renegotiation_type   VARCHAR(50) NULL,
    constraint receipts_ibfk_1
        foreign key (contract_id) references public.detailed_basis (contract_id)
);

ALTER TABLE wb_receipts
ALTER TABLE title_amount TYPE VARCHAR(255);

ALTER TABLE wb_receipts
ALTER TABLE title_type TYPE VARCHAR(255);

ALTER TABLE wb_receipts
ALTER TABLE payment_form TYPE VARCHAR(255);

ALTER TABLE wb_receipts
ALTER TABLE renegotiation_number TYPE VARCHAR(255);

ALTER TABLE wb_receipts
ALTER TABLE renegotiation_type TYPE VARCHAR(255);

ALTER TABLE public.wb_receipts DROP CONSTRAINT receipts_ibfk_1;
ALTER TABLE public.wb_receipts DROP CONSTRAINT receipts_pkey;
ALTER TABLE public.receipts ADD COLUMN update_at TIMESTAMP;
ALTER TABLE public.receipts RENAME TO wb_receipts;

CREATE INDEX client_id_wbr
    ON public.wb_receipts (client_id);

CREATE INDEX contract_id_wbr
    ON public.wb_receipts (contract_id);

CREATE INDEX expiration_date_wbr
    ON public.wb_receipts (expiration_date);

CREATE INDEX issue_date_wbr
    ON public.wb_receipts (issue_date);

CREATE INDEX receipt_date_wbr
    ON public.wb_receipts (receipt_date);

CREATE INDEX title_number_wbr
    ON wb_receipts (title_number);

-- #################################################################

CREATE TABLE financers_natures (
                                   title_id              VARCHAR(80)
                                       PRIMARY KEY
                                       NOT NULL,
                                   financer_nature       VARCHAR(255),
                                   financer_nature_code  VARCHAR(255),
                                   fiscal_operation      VARCHAR(255),
                                   fiscal_operation_code VARCHAR(255),
    /*CONSTRAINT financers_natures_ibfk_1
    FOREIGN KEY (title_id) REFERENCES public.expirations (title_id),
    CONSTRAINT financers_natures_ibfk_2
    FOREIGN KEY (title_id) REFERENCES public.billings (title_id),
    CONSTRAINT financers_natures_ibfk_3
    FOREIGN KEY (title_id) REFERENCES public.receipts (title_id)*/
);

ALTER TABLE public.wb_financers_natures ADD COLUMN update_at TIMESTAMP;

ALTER TABLE public.wb_financers_natures DROP CONSTRAINT financers_natures_pkey;
ALTER TABLE public.wb_financers_natures DROP CONSTRAINT financers_natures_ibfk_1;
ALTER TABLE public.wb_financers_natures DROP CONSTRAINT financers_natures_ibfk_2;
ALTER TABLE public.wb_financers_natures DROP CONSTRAINT financers_natures_ibfk_3;
ALTER TABLE public.financers_natures RENAME TO wb_financers_natures;

CREATE INDEX fn_code
    ON wb_financers_natures (financer_nature_code);

CREATE INDEX fo_code
    ON wb_financers_natures (fiscal_operation_code);