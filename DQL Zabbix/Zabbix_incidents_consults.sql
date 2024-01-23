-- ZABBIX CONSULTA
WITH incidentes as (
    SELECT
        (to_timestamp(e.clock)) AT TIME ZONE 'America/Sao_Paulo' dthr_incidente,
        CASE
            WHEN e.severity = 0 then 'Não classificada'
            WHEN e.severity = 1 then 'Informação'
            WHEN e.severity = 2 then 'Atenção'
            WHEN e.severity = 3 then 'Média'
            WHEN e.severity = 4 then 'Alta'
            WHEN e.severity = 5 then 'Desastre'
            END severity,
        to_timestamp(e1.clock) AT TIME ZONE 'America/Sao_Paulo' dthr_recuperação,
        CASE
            WHEN e1.eventid is null then 'Não resolvido'
            ELSE 'Resolvido'
            END "Status",
        e.name inicidente
    FROM events e
             LEFT JOIN triggers t on t.triggerid = e.objectid
             LEFT JOIN problem p on p.eventid = e.eventid
             LEFT JOIN event_recovery er on er.eventid = e.eventid
             LEFT JOIN events e1 on e1.eventid = er.r_eventid
    WHERE t.description ilike '%MPLS-SW%'
    AND e.name NOT ILIKE '%Interface Eth-Trunk%'
    AND e.severity not in (0,1)
order by e.clock desc)
SELECT DISTINCT
    *
FROM incidentes inn
where inn.dthr_incidente::DATE >= '2023-06-01'
