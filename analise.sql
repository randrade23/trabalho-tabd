-- quantos servicos partem do aeroporto
SELECT SUM(Se.Nr_Viagens)
FROM Services Se, Location L, Stand St
WHERE 	Se.LocalI_ID = L.Local_ID 
	AND	L.Stand_ID = St.Stand_ID
	AND St.Nome LIKE 'Sá Carneiro';

-- quantos servicos partem de cada stand
SELECT St.Nome, SUM(Se.Nr_Viagens)
FROM Services Se, Location L, Stand St
WHERE 	Se.LocalI_ID = L.Local_ID 
	AND	L.Stand_ID = St.Stand_ID
GROUP BY 1
ORDER BY 2 DESC;

-- quantos servicos partem de cada freguesia & concelho
SELECT L.Concelho, L.Freguesia, SUM(Se.Nr_Viagens)
FROM Services Se, Location L
WHERE 	Se.LocalI_ID = L.Local_ID 
GROUP BY 1,2
ORDER BY 1,2 ASC;

-- quantos servicos partem de cada freguesia & concelho & stand
SELECT L.Concelho, L.Freguesia, St.Nome, SUM(Se.Nr_Viagens)
FROM Services Se, Location L, Stand St
WHERE 	Se.LocalI_ID = L.Local_ID 
	AND (St.Stand_ID IS NULL OR L.Stand_ID = St.Stand_ID)
GROUP BY 1,2,3
ORDER BY 1,2 ASC;

-- quantos servicos comecam stands
SELECT SUM(Se.Nr_Viagens)
FROM Services Se, Location L, Stand St
WHERE 	Se.LocalI_ID = L.Local_ID 
	AND	L.Stand_ID = St.Stand_ID
	AND St.Stansd_ID IS NOT NULL;

-- quantos servicos nao comecam em stands
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

-- quantos servicos por mes
SELECT T.Mes, SUM(Se.Nr_Viagens)
FROM Services Se, Tempo T
WHERE	Se.TempoI_ID = T.Tempo_ID
GROUP BY 1
ORDER BY 1 ASC;

-- quantos servicos por hora
SELECT T.Hora, SUM(Se.Nr_Viagens)
FROM Services Se, Tempo T
WHERE	Se.TempoI_ID = T.Tempo_ID
GROUP BY 1
ORDER BY 1 ASC;

-- top 10 rotas preferidas (ids, gostaria de mudar isto para freguesias/concelhos)
SELECT Se.LocalI_ID, Se.LocalF_ID, Sum(Se.Nr_Viagens)
FROM Services Se
GROUP BY 1,2
ORDER BY 3 DESC LIMIT 10;
