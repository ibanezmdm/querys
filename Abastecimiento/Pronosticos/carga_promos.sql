
SELECT DISTINCT ID_CATALOGO, NOM_CATALOGO, F_I, F_F
FROM PronosticosVentas.dbo.Promociones_SAP
WHERE NOM_CATALOGO LIKE '%DIA DEL PADRE LIQUIDOS%'
	--and ID_CATALOGO = 3836
order by NOM_CATALOGO, F_I




-- Registra catalogo en tabla promociones
INSERT INTO PronosticosVentas.dbo.Promociones

SELECT distinct *
FROM PronosticosVentas.dbo.Promociones_SAP
WHERE ID_CATALOGO = 4198
	--and ID_PROMOCION = 189151
	--AND SKU_J IN (20259389, 20351068)



SELECT distinct id_catalogo, NOM_CATALOGO, F_I, F_F
FROM PronosticosVentas.dbo.Promociones
--where ID_CATALOGO not in (
--		SELECT distinct [ID_CATALOGO]
--		FROM [PronosticosVentas].[dbo].[PRONOSTICO_RESUMEN_RESPALDO_2]
--	)
where NOM_CATALOGO like '%FFPP%'
order by F_I asc


SELECT ID_CATALOGO, ID_PROMOCION, SKU_J, COUNT(*)
FROM PronosticosVentas.dbo.Promociones_SAP
WHERE ID_CATALOGO = 3827
group by ID_CATALOGO, ID_PROMOCION, SKU_J
having COUNT(*) > 1
