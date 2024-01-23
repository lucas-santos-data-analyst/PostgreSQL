SELECT DISTINCT
    it.id,
    a.responsible_id attendant_id,
    ai.protocol protocol,
    ai.beginning_checklist::JSON ->'4_'->>'value' value_checklist,
	a.created::DATE created_at,
	a.conclusion_date::DATE conclusion_at,
	CASE
		WHEN a.conclusion_date > a.final_date THEN 'sla in delay'
		ELSE 'sla on time'
    END "SLA",
	is2.title status,
	it.title type_request,
	sc.title context,
	sp.title problem,
	t.title origin_team,
	t2.title current_team,
	resp.name attendant,
	ac.city city
FROM assignments a
	LEFT JOIN people resp                             ON resp.id        = a.responsible_id -- responsible for the protocol
	LEFT JOIN assignment_incidents ai                 ON a.id           = ai.assignment_id
	LEFT JOIN incident_types it                       ON it.id          = ai.incident_type_id -- type of request
	LEFT JOIN incident_status is2                     ON is2.id         = ai.incident_status_id -- status
	LEFT JOIN solicitation_classifications sc         ON sc.id          = ai.solicitation_classification_id -- context
	LEFT JOIN solicitation_problems sp                ON sp.id          = ai.solicitation_problem_id -- problem
	LEFT JOIN contract_service_tags cst               ON cst.id         = ai.contract_service_tag_id -- tag
	LEFT JOIN teams t                                 ON t.id           = ai.origin_team_id -- origin team
	LEFT JOIN teams t2                                ON t2.id          = ai.team_id -- current team
	LEFT JOIN person_people_groups ppg                ON ppg.person_id  = resp.id
	LEFT JOIN people_groups pg                        ON pg.id          = ppg.people_group_id
	LEFT JOIN contracts c                             ON c.id           = cst.contract_id -- contract
	LEFT JOIN authentication_contracts ac             ON ac.contract_id = c.id -- point data (connection)
	WHERE is2.id NOT IN (8) --status filter
	  AND t.id = 1228 -- team filter
	  AND pg.id IN ('70') -- group filter
	  AND a.created::DATE >= now()::DATE - INTERVAL '18' MONTH --openings in the last 18 months