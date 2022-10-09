SELECT
    COUNT(DISTINCT sq.st_id) as count_diligent_students
FROM 
(
    SELECT 
        st_id,
        timest,
        COUNT(timest) OVER w AS peas_per_hour_preceding
    FROM peas
    WHERE correct = 1
        AND timest BETWEEN '2020-03-01' AND '2020-03-31' 
    WINDOW w AS (
        PARTITION BY st_id
        ORDER BY timest ASC
        RANGE BETWEEN '1 hour' PRECEDING AND CURRENT ROW
    )
) AS sq
WHERE sq.peas_per_hour_preceding >= 20
