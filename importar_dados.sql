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

-- insert das combinacoes dia/hora/mes
insert into tempo (hora, dia, mes)
	select 
		date_part('hour', timestamp) as Hora, 
		date_part('day', timestamp) as Dia, 
		date_part('month', timestamp) as Mes 
	from 
		(select 
			to_timestamp(taxi_services.initial_ts) as timestamp 
		from 
			taxi_services) as S 
group by hora,dia,mes;

-- insert das pracas de taxis
insert into stand (stand_id, nome, lotacao) select id, name, 1 from taxi_stands;

-- insert dos taxis
insert into taxi(taxi_id, num_licenca) select distinct(taxi_id), 1 from taxi_services;


    
-- insert das locations ligadas com as stands

insert into location (stand_id, freguesia, concelho)
	select 
		stand_id, 
		caop.freguesia, 
		caop.concelho 
	from 
		(select 
			stand.stand_id as stand_id, 
			stand.nome, 
			taxi_stands.location as location 
		from 
			stand, 
			taxi_stands 
		where 
			stand.stand_id = taxi_stands.id) as S, 
		caop 
	where 
		st_contains(caop.geom, location);

-- insert das locations sem stands

/*insert into location (stand_id, freguesia, concelho)
	select 
		null, 
		freguesia, 
		concelho 
	from 
		caop 
	where 
		distrito like '%PORTO%';*/

insert into location (stand_id, freguesia, concelho)
	select
		null,
		freguesia,
		concelho
	from (
		select 
			initial_point, 
			caop.freguesia as freguesia, 
			caop.concelho as concelho
		from 
			taxi_services, 
			caop 
		where 
			st_contains(caop.geom, initial_point)) as S
	group by freguesia, concelho;

insert into location (stand_id, freguesia, concelho)
	select
		null,
		freguesia,
		concelho
	from (
		select 
			final_point, 
			caop.freguesia as freguesia, 
			caop.concelho as concelho
		from 
			taxi_services, 
			caop 
		where 
			st_contains(caop.geom, final_point)) as S
	where not exists (select null, freguesia, concelho from location)
	group by freguesia, concelho;

select location.local_id from location, taxi_stands, taxi_services, stand
where st_distance(taxi_services.initial_point, taxi_stands.location) < 100
and taxi_stands.id = stand.stand_id;