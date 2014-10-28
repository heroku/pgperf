with analysis as (
	SELECT *
FROM crosstab(
  'SELECT 
    plan,
    clients,
    round(median(tps)) as TPS
    FROM tests, testset, databases
    WHERE 
      tests.set=testset.set AND 
      testset.database_uuid = databases.uuid AND
      test_type=''select'' AND
      plan not like ''%baku%'' AND
      plan not like ''%ika%'' AND
      plan not like ''%mecha%'' 
    GROUP BY clients, plan
    ORDER BY plan, clients asc',
    'SELECT unnest(ARRAY[''1'',''5'',''10'',''25'',''50'',''100'',''150'',''200'',''250'',''300''])'
) as ct(plan varchar, "1" int, "5" int, "10" int, "25" int, "50" int, "100" int, "150" int, "200" int, "250" int, "300" int)
)

select * from analysis order by "200" asc;