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

-- preenchimento da tabela temporaria (expandida)

insert into Temp (ID, Taxi_ID, localI_ID, freguesiaI, concelhoI, TempoI_ID, Initial_TS, HoraI, DiaI, MesI, localF_ID, freguesiaF, concelhoF, TempoF_ID, Final_TS, HoraF, DiaF, MesF)
select ID1, Taxi_ID, localI_ID, freguesiaI, concelhoI, TempoI_ID, Initial_TS, HoraI, DiaI, MesI, localF_ID, freguesiaF, concelhoF, TempoF_ID, Final_TS, HoraF, DiaF, MesF

FROM(
    (((((select ID as ID1, initial_ts, date_part('hour', to_timestamp(taxi_services.initial_ts) ) as HoraI, date_part('day', to_timestamp(taxi_services.initial_ts) ) as DiaI, date_part('month', to_timestamp(taxi_services.initial_ts)) as MesI, tempo.tempo_ID AS tempoI_ID 
     from taxi_services, tempo
        where tempo.hora=date_part('hour', to_timestamp(taxi_services.initial_ts) ) AND tempo.dia=date_part('day', to_timestamp(taxi_services.initial_ts) ) AND tempo.mes=date_part('month', to_timestamp(taxi_services.initial_ts))) AS TIMEI

    
    INNER JOIN

    
    (select ID as ID2, final_ts, date_part('hour', to_timestamp(taxi_services.final_ts) ) as HoraF, date_part('day', to_timestamp(taxi_services.final_ts) ) as DiaF, date_part('month', to_timestamp(taxi_services.final_ts)) as MesF, tempo.tempo_ID AS tempoF_ID 
     from taxi_services, tempo
        where tempo.hora=date_part('hour', to_timestamp(taxi_services.final_ts) ) AND tempo.dia=date_part('day', to_timestamp(taxi_services.final_ts) ) AND tempo.mes=date_part('month', to_timestamp(taxi_services.final_ts))) AS TIMEF ON  ID1=ID2) 

    
    INNER JOIN


    (select ID as ID3, taxi_id from taxi_services) AS TAXID ON ID1=ID3)

    
    INNER JOIN
    

    (select distinct localI_ID, ID4, freguesiaI, concelhoI
     FROM
        ((select distinct location.local_id as localI_ID, taxi_services.id as ID4, caop.freguesia as freguesiaI, caop.concelho as concelhoI
        FROM taxi_services, taxi_stands, caop, Location
          WHERE st_contains(caop.geom, taxi_services.initial_point) 
            AND st_distancesphere(taxi_services.initial_point,taxi_stands.location)<=100
            AND Location.Stand_ID=taxi_stands.ID
            AND location.freguesia=caop.freguesia
            AND location.concelho=caop.concelho)

        UNION ALL
     
        (select distinct location.local_id as localI_ID, taxi_services.id as ID4, caop.freguesia as freguesiaI, caop.concelho as concelhoI
        FROM taxi_services, taxi_stands, caop, Location
         WHERE st_contains(caop.geom, taxi_services.initial_point) 
            AND st_distancesphere(taxi_services.initial_point,taxi_stands.location)>100
            AND Location.Stand_ID IS null
            AND Location.freguesia=caop.freguesia
            AND Location.concelho=caop.concelho)
     
        ) AS STANDS) AS LOCALI ON ID1= ID4)

    
    INNER JOIN
    
    
    (select distinct ID5, localF_ID, freguesiaF, concelhoF
     FROM
        ((select distinct location.local_id as localF_ID, taxi_services.id as ID5, caop.freguesia as freguesiaF, caop.concelho as concelhoF
        FROM taxi_services, taxi_stands, caop, Location
        WHERE st_contains(caop.geom, taxi_services.final_point) 
            AND st_distancesphere(taxi_services.final_point,taxi_stands.location)<=100
            AND Location.Stand_ID=taxi_stands.ID
            AND location.freguesia=caop.freguesia
            AND location.concelho=caop.concelho)

        UNION ALL

        (select distinct location.local_id as localF_ID, taxi_services.id as ID5, caop.freguesia as freguesiaF, caop.concelho as concelhoF
        FROM taxi_services, taxi_stands, caop, Location
        WHERE st_contains(caop.geom, taxi_services.final_point) 
            AND st_distancesphere(taxi_services.final_point,taxi_stands.location)>100
            AND Location.Stand_ID IS null
            AND Location.freguesia=caop.freguesia
            AND Location.concelho=caop.concelho)
     
        ) AS STANDS) AS LOCALF ON ID1=ID5)
) AS SUPER
;

-- limpar serviços com tempo < 180 segs (3 min)
delete from temp where EXTRACT(EPOCH FROM(to_timestamp(final_ts) - to_timestamp(initial_ts)))<180;

-- limpar serviços com tempo > 8h
delete from temp where id in
(select id from temp 
 where EXTRACT(EPOCH FROM(to_timestamp(final_ts) - to_timestamp(initial_ts)))>28800);

-- limpar serviços começados fora do Porto
delete from temp where concelhoI not like '%PORTO%';

-- preenchimento da tabela services (tabela de factos)

insert into services (taxi_id, tempoi_id, locali_id, localf_id, nr_viagens, tempo_total) 
	select taxi_id, tempoi_id, locali_id, localf_id, count(*) as nr_viagens, sum(EXTRACT(EPOCH FROM(to_timestamp(final_ts) - to_timestamp(initial_ts)))) as tempo_total 
	from 
		(select distinct on(id) taxi_id, tempoi_id, locali_id, localf_id, final_ts, initial_ts 
		from 
		temp) as S 
	group by 1,2,3,4;
