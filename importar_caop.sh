shp2pgsql -W "latin1" -s 27493:4326 -g geom -I caop/Cont_Freg_V5.shp public.caop | psql