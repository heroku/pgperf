with analysis as (
	SELECT *
FROM crosstab(
  $$SELECT 
    plan,
    clients,
    round(max(tps)) as TPS
    FROM tests, testset, databases
    WHERE 
      tests.set=testset.set AND 
      testset.database_uuid = databases.uuid AND
      test_type='select' AND
      plan not like '%baku%' AND
      plan not like '%ika%' AND
      plan not like '%mecha%' AND
      current_timestamp - databases.created_at < '240 hours'
      -- current_timestamp - databases.created_at < '240 hours'
    GROUP BY clients, plan
    ORDER BY plan, clients asc
    $$,
    $$SELECT unnest(ARRAY['1','100','200','300','400','500'])$$
) as ct(plan varchar, "1" int, "100" int, "200" int, "300" int,"400" int, "500" int)
)

select * from analysis order by "500" asc;