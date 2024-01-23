WITH service_to_contracts AS (
    SELECT DISTINCT
        ci.contract_id,
        ci.description service,
        'Composite' service_type
    FROM contract_items ci
             LEFT JOIN service_products sp on sp.id = ci.service_product_id
    WHERE ci.deleted = FALSE
      AND ci.origin_contract_item_id IS NOT NULL
      AND ci.is_composition = TRUE
    UNION
    SELECT DISTINCT
        ci.contract_id,
        ci.description service,
        'loose' service_type
    FROM contract_items ci
             LEFT JOIN service_products sp on sp.id = ci.service_product_id
    WHERE ci.deleted = FALSE
      AND ci.origin_contract_item_id IS NULL)
SELECT
    stc.service,
    stc.service_type,
    c.contract_number,
    c.v_status,
    c.v_stage,
    c.description
FROM service_to_contracts stc
         LEFT JOIN contracts c ON c.id = stc.contract_id
WHERE c.deleted = FALSE
  AND c.stage   = 3
  AND c.status  NOT IN (4,9)