SELECT 
    sq.test_grp,
    sq.income::float / NULLIF(sq.users, 0) AS ARPU,
    sq.income::float / NULLIF(sq.active_count, 0) AS ARPAU,
    sq.buyers::float / NULLIF(sq.users, 0) AS CR,
    sq.buyers::float /  NULLIF(sq.active_count, 0) AS CR_active,
    sq.math_buyers_count::float / NULLIF(sq.math_active_count, 0) AS CR_active_math
FROM (
    SELECT 
        sq.test_grp,
        COUNT(DISTINCT sq.st_id_users) AS users,
        SUM(sq.buyer) AS buyers,
        SUM(sq.money) AS income,
        SUM(sq.math_active) AS math_active_count,
        SUM(sq.math_buyer) AS math_buyers_count,
        SUM(sq.active_user) AS active_count
    FROM (  
        SELECT 
            sq.st_id_users,
            sq.test_grp,
            SUM(sq.money) as money,
            MAX(sq.buyer) as buyer,
            MAX(sq.math_active) as math_active,
            MAX(sq.math_buyer) as math_buyer,
            MAX(sq.active_user) as active_user
        FROM (
            SELECT *,
                CASE WHEN m.st_id_checks != '' THEN 1 ELSE 0 END AS buyer,
                CASE WHEN l.subject = 'math' AND sum_correct > 30 THEN 1 ELSE 0 END AS math_active, -- choosing criteria of active
                CASE WHEN m.subj_money = 'math' THEN 1 ELSE 0 END AS math_buyer,
                CASE WHEN l.sum_correct > 30 THEN 1 ELSE 0 END AS active_user 
            FROM (
                (
                SELECT st_id AS st_id_users, subject, date_trunc('day', timest), SUM(correct) AS sum_correct, COUNT(correct) AS count_peas
                FROM peas
                GROUP BY st_id, subject, date_trunc('day', timest)
                HAVING SUM(correct) > -1
                ) AS l
                LEFT OUTER JOIN (SELECT money, st_id AS st_id_checks, subject AS subj_money FROM checks) AS m ON l.st_id_users = m.st_id_checks AND l.subject = m.subj_money
                LEFT OUTER JOIN (SELECT * FROM studs) AS r ON l.st_id_users = r.st_id
            )
        ) AS sq
        GROUP BY sq.test_grp, sq.st_id_users
    ) AS sq
    GROUP BY sq.test_grp
) AS sq
WHERE test_grp != ''
