-- calcular dia da semana dado ano/mes/dia - regra de Zeller
CREATE OR REPLACE FUNCTION weekDay (year integer, month integer, day integer)
RETURNS integer AS $dow$
declare
	dow integer;
	adjustment integer;
	mm integer;
	yy integer;
BEGIN
   SELECT (14 - month) / 12 into adjustment;
   SELECT month + 12 * adjustment - 2 into mm;
   SELECT year - adjustment into yy;
   SELECT (((day + (13 * mm - 1) / 5 + yy + yy / 4 - yy / 100 + yy / 400)-1) % 7) + 1 into dow;
   RETURN dow;
END;
$dow$ LANGUAGE plpgsql;

-- calcular periodo (0-6) madrugada (6-12) manha (12-18) tarde (18-23) noite
CREATE OR REPLACE FUNCTION period (hora integer)
RETURNS text AS $per$
declare
	per text;
BEGIN
   SELECT 	CASE 	WHEN hora > 0 	AND hora <= 6 	THEN 'madrugada'
   					WHEN hora > 6 	AND hora <= 12	THEN 'manha'
   					WHEN hora > 12  AND hora <= 18	THEN 'tarde'
   					ELSE 'noite'
   			END
   		into per;
   	RETURN per;
END;
$per$ LANGUAGE plpgsql;

-- quantos Services partem de Campanha
SELECT SUM(Se.Nr_Viagens)
FROM Services Se, Location L, Stand St
WHERE 	Se.LocalI_ID = L.Local_ID 
	AND	L.Stand_ID = St.Stand_ID
	AND St.Nome LIKE 'Campanhã';
-- well...

-- quantos Services partem de cada stand
SELECT St.Nome, SUM(Se.Nr_Viagens)
FROM Services Se, Location L, Stand St
WHERE 	Se.LocalI_ID = L.Local_ID 
	AND	L.Stand_ID = St.Stand_ID
GROUP BY 1
ORDER BY 2 DESC LIMIT 10;

-- quantos servicos por mes, dia em Campanhã
SELECT Mes, Dia, SUM(Se.Nr_Viagens)
FROM Services Se, Location L, Stand St, Tempo T
WHERE 	Se.TempoI_ID = T.Tempo_ID
	AND	Se.LocalI_ID = L.Local_ID 
	AND	L.Stand_ID = St.Stand_ID
	AND St.Nome LIKE 'Campanhã'
GROUP BY ROLLUP (Mes, Dia)
ORDER BY 1,2;

-- quantos Services partem de cada freguesia & concelho
SELECT L.Concelho, L.Freguesia, SUM(Se.Nr_Viagens)
FROM Services Se, Location L
WHERE 	Se.LocalI_ID = L.Local_ID 
GROUP BY ROLLUP(Concelho, Freguesia)
ORDER BY 1,2 ASC;

-- quantos Services partem de cada freguesia & concelho & stand
SELECT St.Nome, L.Freguesia, L.Concelho, SUM(Se.Nr_Viagens)
FROM Services Se, Location L, Stand St
WHERE 	Se.LocalI_ID = L.Local_ID 
	AND (St.Stand_ID IS NULL OR L.Stand_ID = St.Stand_ID)
GROUP BY 1,2,3
ORDER BY 4 DESC LIMIT 10;

-- quantos Services comecam stands
SELECT SUM(Se.Nr_Viagens)
FROM Services Se, Location L, Stand St
WHERE 	Se.LocalI_ID = L.Local_ID 
	AND	L.Stand_ID = St.Stand_ID
	AND St.Stands_ID IS NOT NULL;

-- quantos Services nao comecam em stands
SELECT SUM(Se.Nr_Viagens)
FROM Services Se, Location L
WHERE 	Se.LocalI_ID = L.Local_ID 
	AND	L.Stand_ID IS NULL;
-- isto devia dar (?) mas podemos smp ver a diferenca
SELECT SUM(Se.Nr_Viagens) - Nr_Viagens_Stands FROM 
Services Se,(SELECT SUM(Se.Nr_Viagens) AS Nr_Viagens_Stands
FROM Services Se, Location L, Stand St
WHERE 	Se.LocalI_ID = L.Local_ID 
	AND	L.Stand_ID = St.Stand_ID
	AND St.Stand_ID IS NOT NULL) AS S
GROUP BY Nr_Viagens_Stands;

-- quantos Services por mes
SELECT T.Mes, SUM(Se.Nr_Viagens)
FROM Services Se, Tempo T
WHERE	Se.TempoI_ID = T.Tempo_ID
GROUP BY 1
ORDER BY 1 ASC;

-- quantos Services por hora
SELECT T.Hora, SUM(Se.Nr_Viagens)
FROM Services Se, Tempo T
WHERE	Se.TempoI_ID = T.Tempo_ID
GROUP BY 1
ORDER BY 1 ASC;

-- top 10 rotas preferidas 
SELECT L1.Freguesia, L1.Concelho, L2.Freguesia, L2.Concelho, Sum(Se.Nr_Viagens)
FROM Services Se, Location L1, Location L2
WHERE Se.LocalI_ID = L1.Local_ID
AND Se.LocalF_ID = L2.Local_ID
GROUP BY 1,2,3,4
ORDER BY 5 DESC LIMIT 10;

-- nr de viagens do aeroporto dividido por mês
SELECT 
  Zone,
  State,
  COUNT(Sponsored),
  COUNT(Enrolled),
  COUNT(PickedUp)
FROM MasterData
GROUP BY Zone, StateName
  WITH ROLLUP=
SELECT SUM(Se.Nr_Viagens)
FROM Services Se, Location L, Stand St
WHERE 	Se.LocalI_ID = L.Local_ID 
	AND	L.Stand_ID = St.Stand_ID
	AND St.Nome LIKE 'Campanhã';

select stand.nome as stand, tempo.mes as mes, tempo.dia, sum(nr_viagens) as viagens 
from stand, location, tempo
where location.local_id in (select localf_id from services where locali_id=36)
AND location.stand_id=stand.stand_id
AND stand.stand_id=taxi_stands.id
GROUP BY CUBE stand, mes, dia;


--Os percursos com mais viagens por mês
select services.locali_id as locali, services.localf_id as localf, tempo.mes, count(services.nr_viagens) as viagens
from services, tempo
where services.tempoi_id=tempo.tempo_id
group by 1,2,3
order by 4 desc;

select count (*) from (select services.locali_id, services.localf_id, tempo.mes
from services, tempo
group by 1,2,3) as s;


select l1.freguesia as FreguesiaInicial, l1.concelho as ConcelhoInicial, l2.freguesia as FreguesiaFinal, l2.concelho as ConcelhoFinal, tempo.mes as Mes
from services, (select services.locali_id from location where )
where services.locali_id=location.local_id
AND 




-- SUPER ROLLUP
SELECT location.concelho, location.freguesia as Freguesia, sum(services.nr_viagens),  CAST(AVG(tempo_total) AS INTEGER) AS AVG_Tempo
FROM services, location
where services.locali_id=location.local_id
GROUP BY ROLLUP(concelho, freguesia);


select l1.concelho, l1.freguesia, l2.concelho, l2.freguesia, mes
from



select services.locali_id as locali, services.localf_id as localf, tempo.mes as mes, count(services.nr_viagens) as viagens
from services, tempo
where services.tempoi_id=tempo.tempo_id
group by 1,2,3
order by 4 desc;


-- sumario de Services por mes/dia/hora
SELECT mes, dia, hora, Sum(Nr_Viagens) as viagens, SUM(tempo_total) as tempo_total, CAST(AVG(tempo_total) AS INTEGER) AS tempo_medio
FROM Services, Tempo
Where Services.TempoI_ID = Tempo.Tempo_ID
GROUP By ROLLUP(mes, dia, hora)

-- quantos servicos por mes & dia de semana
SELECT Tempo.Mes, weekDay(2015, Tempo.Mes, Tempo.Dia) as day_of_week, SUM(Nr_Viagens) as viagens
FROM Services, Tempo
WHERE Services.TempoI_ID = Tempo.Tempo_ID
GROUP BY ROLLUP(Mes, day_of_week)
ORDER BY 1,2 ASC;

-- quantos servicos por dia de semana & hora
SELECT weekDay(2015, Tempo.Mes, Tempo.Dia) as day_of_week, period(Tempo.Hora) as periodo, SUM(Nr_Viagens) as viagens
FROM Services, Tempo
WHERE Services.TempoI_ID = Tempo.Tempo_ID
GROUP BY ROLLUP(day_of_week, periodo)
ORDER BY 1, CASE WHEN period(Tempo.Hora) LIKE 'madrugada' THEN 1
 				 WHEN period(Tempo.Hora) LIKE 'manha' THEN 2
 				 WHEN period(Tempo.Hora) LIKE 'tarde' THEN 3
 				 WHEN period(Tempo.Hora) LIKE 'noite' THEN 4
 				 ELSE 5 END ASC;

SELECT weekDay(2015, Tempo.Mes, Tempo.Dia) as day_of_week, Tempo.Hora as hora, MAX(SUM(Nr_Viagens)) as viagens
FROM Services, Tempo
WHERE Services.TempoI_ID = Tempo.Tempo_ID
GROUP BY 1,2
ORDER BY 1,2 ASC;

-- vanda truques

SELECT 
l1.freguesia, l1.concelho, l2.freguesia, l2.concelho, 
period(tempo.hora), SUM(services.nr_viagens) AS ViagensPeriodo 
from services, location l1, location l2, tempo 
where services.locali_id = l1.local_id 
and services.tempoi_id = tempo.tempo_id 
and services.localf_id = l2.local_id
group by cube(1,2,3,4,5) 
order by 5,6, 
case WHEN period(tempo.hora) like 'madrugada' then 1 
when period(tempo.hora) like 'manha' then 2 
when period(tempo.hora) like 'tarde' then 3 
when period(tempo.hora) like 'noite' then 4 
else 5 end asc;
