insert into services (taxi_id, tempoi_id, locali_id, localf_id, nr_viagens, tempo_total)
  SELECT
    taxi_id,
    T.tempo_id,
    (select localI_ID from ((select location.local_id as localI_ID, caop.freguesia as freguesiaI, caop.concelho as concelhoI
          FROM taxi_stands, caop, Location
          WHERE (st_contains(caop.geom, initial_point) 
              AND st_distancesphere(initial_point,taxi_stands.location)<=100
              AND Location.Stand_ID=taxi_stands.ID
              AND location.freguesia=caop.freguesia
              AND location.concelho=caop.concelho))
    UNION ALL
              (select location.local_id as localI_ID, caop.freguesia as freguesiaI, caop.concelho as concelhoI
          FROM taxi_stands, caop, Location
          WHERE (st_contains(caop.geom, initial_point) 
              AND st_distancesphere(initial_point,taxi_stands.location)>100
              AND Location.Stand_ID=taxi_stands.ID
              AND location.freguesia=caop.freguesia
              AND location.concelho=caop.concelho)) ORDER BY 1 DESC NULLS LAST LIMIT 1) AS S),
    (select localF_ID from ((select location.local_id as localF_ID, caop.freguesia as freguesiaF, caop.concelho as concelhoF
          FROM taxi_stands, caop, Location
          WHERE (st_contains(caop.geom, final_point) 
              AND st_distancesphere(final_point,taxi_stands.location)<=100
              AND Location.Stand_ID=taxi_stands.ID
              AND location.freguesia=caop.freguesia
              AND location.concelho=caop.concelho))
    UNION ALL
              (select location.local_id as localF_ID, caop.freguesia as freguesiaF, caop.concelho as concelhoF
          FROM taxi_stands, caop, Location
          WHERE (st_contains(caop.geom, final_point) 
              AND st_distancesphere(final_point,taxi_stands.location)>100
              AND Location.Stand_ID=taxi_stands.ID
              AND location.freguesia=caop.freguesia
              AND location.concelho=caop.concelho)) ORDER BY 1 DESC NULLS LAST LIMIT 1) AS A),
    COUNT(*) as Nr_Viagens,
    SUM(final_ts - initial_ts) as Tempo_Total
  FROM taxi_services
  INNER JOIN tempo as T ON
    date_part('hour', to_timestamp(initial_ts)) = T.hora AND
    date_part('day', to_timestamp(initial_ts)) = T.dia AND
    date_part('month', to_timestamp(initial_ts)) = T.mes
  GROUP BY 1,2,3,4;


  ---

  (select localF_ID from (select location.local_id as localF_ID, caop.freguesia as freguesiaF, caop.concelho as concelhoF
          FROM taxi_stands, caop, Location
          WHERE (st_contains(caop.geom, final_point) 
              AND st_distancesphere(final_point,taxi_stands.location)<=100
              AND Location.Stand_ID=taxi_stands.ID
              AND location.freguesia=caop.freguesia
              AND location.concelho=caop.concelho)
              OR (st_contains(caop.geom, final_point) 
              AND st_distancesphere(final_point,taxi_stands.location)>100
              AND Location.Stand_ID IS null
              AND Location.freguesia=caop.freguesia
              AND Location.concelho=caop.concelho) ORDER BY 1 DESC NULLS LAST) AS A)