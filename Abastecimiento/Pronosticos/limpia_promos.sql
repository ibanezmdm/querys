
--Muestra los registros duplicados (se le envia a javier)
SELECT *
FROM PronosticosVentas.dbo.Promociones
WHERE ID_CATALOGO in (4198)
	AND SKU_J IN (
		SELECT SKU_J
		FROM [PronosticosVentas].[dbo].[Promociones]
		WHERE ID_CATALOGO in (4198)
		GROUP BY SKU_J
		HAVING COUNT(*) > 1
	)
	-- AND ID_PROMOCION = 164125
ORDER BY SKU_J, ID_PROMOCION, PRECIO_CAT_2, PRECIO_CAT_CMR


--muestra base SAP (se le envia a Javier)
SELECT P.*, ms.DIVISION, ms.DEPARTAMENTO, ms.SUBDEPARTAMENTO, MS.ESTADO
FROM PronosticosVentas.dbo.Promociones P
LEFT JOIN PronosticosVentas.dbo.MAESTRA_SKU MS
	ON P.SKU_J = MS.SKU
WHERE ID_CATALOGO in (4198)


--Elimina Promos

SELECT *
DELETE 
FROM PronosticosVentas.dbo.Promociones
WHERE ID_CATALOGO = 4131
	-- AND ID_PROMOCION =
	--AND SKU_J IN (20504618, 20504619)





SELECT SKU_J
FROM [PronosticosVentas].[dbo].[Promociones]
WHERE ID_CATALOGO = 3745
GROUP BY SKU_J
HAVING COUNT(*) > 1


select *
from [PronosticosVentas].[dbo].[Promociones] 
WHERE ID_CATALOGO = 3745
	AND PRECIO_CAT_2 is null
ORDER BY SKU_J


SELECT 
	[ID_CATALOGO]
	,[NOM_CATALOGO]
	,F_I
	,F_F
	,COUNT(*) SKUs
FROM [PronosticosVentas].[dbo].[Promociones]
-- where NOM_CATALOGO like '%MMPP%' AND ID_CATALOGO = 3585
-- where SKU_J = 00100013
GROUP BY 
	[ID_CATALOGO]
	,[NOM_CATALOGO]
	,F_I
	,F_F
ORDER BY F_I 



SELECT 
	V.sku,
	DESCRIPCION DESC_SKU,
	SUM(un_vta) un_vta,
	NOM_CATALOGO,
	NOM_PROMOCION,
	DETALLE_PROMOCION,
	F_I,
	F_F,
	SEMANA_I,
	SEMANA_F
FROM [PronosticosVentas].[dbo].[VentaSkusPromocion] V
INNER JOIN [PronosticosVentas].[dbo].[Promociones] C
	ON CONVERT(INT, V.sku) = CONVERT(INT, C.SKU_J)
WHERE F_I <= V.fecha
	AND F_F >= V.fecha
	AND ID_CATALOGO = 3516
	-- AND V.sku = 20431876
GROUP BY 
	V.sku,
	DESCRIPCION,
	NOM_CATALOGO,
	NOM_PROMOCION,
	DETALLE_PROMOCION,
	F_I,
	F_F,
	SEMANA_I,
	SEMANA_F



update PronosticosVentas.dbo.Promociones
set F_I = '2021-05-28',
	F_F = '2021-06-20'
where ID_CATALOGO = 4198
	and (F_I <> '2021-05-28'
		or F_F <> '2021-06-20'
	)