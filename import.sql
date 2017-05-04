# ver freguesia para cada initial_point
select caop.freguesia, taxi_services.initial_point from caop, taxi_services where st_contains(caop.geom, taxi_services.initial_point);

# select de todas as combinacoes de dia/hora/mes existentes nos taxi_services
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

#insert das combinacoes dia/hora/mes
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
