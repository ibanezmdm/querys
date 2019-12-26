/* Updated_at: 2019/11/21
 * Updated_by: Sebastian Cornejo
 * Detalle: Filtro de salas cerradas se hace cruzando con tabla TIENDAS_ASENTADAS
 */

-- TRUNCATE TABLE [INFORMES3].[dbo].[INSTOCK_CARNES_POLLO_TOTAL_AUTOSERVICIO]

-- INSERT INTO [INFORMES3].[dbo].[INSTOCK_CARNES_POLLO_TOTAL_AUTOSERVICIO] (
-- 	[RESUMEN]
-- 	,[INSTOCK]
-- )

-- SELECT --SUBDEP
--       'TOTAL POLLO AUTOSERVICIO' AS RESUMEN
--       , CASE WHEN (SUM([NUM_VTA_SEM_X_PERFIL]) IS NULL OR SUM([NUM_VTA_SEM_X_PERFIL])<=0) THEN 0
--            ELSE CONVERT(NUMERIC(18,2),(SUM([NUM_OH_VALORIZADO])/SUM([NUM_VTA_SEM_X_PERFIL]))*100) END AS INSTOCK
--   FROM (select A.* 
-- from [INFORMES3].[dbo].[CE_INSTOCK] AS A INNER JOIN
--      (SELECT NOM_LOCAL
--       ,COD_LOCAL
--       ,A.NOM_SKU
--       ,A.SKU
--       ,B.DIVISION
--       ,B.DEPARTAMENTO
--       ,B.SUBDEPARTAMENTO
--       ,IND_SURTIDO  
-- FROM [INFORMES3].[dbo].[MAESTRA_PRODUCTOS_SURTIDOS] AS A LEFT JOIN
--      [RepNonFood].dbo.MAESTRA_SKU AS B ON B.SKU=A.SKU
-- where B.SUBDEPARTAMENTO LIKE '%CERDO%' OR B.SUBDEPARTAMENTO LIKE '%POLLO%' OR B.SUBDEPARTAMENTO LIKE '%PAVO%') AS B ON B.COD_LOCAL=A.COD_LOCAL AND B.SKU=A.SKU
-- where A.COD_LOCAL not in (209,203,205,202,206,105,129,107,207)
-- ) AS T
--   WHERE (SUBDEP LIKE '%POLLO%') AND SUBCLASE LIKE '%AUTOSERVICIO%'
--   GROUP BY SUBDEP


SELECT
	'TOTAL POLLO AUTOSERVICIO' AS RESUMEN
	,CASE 
		WHEN (SUM([NUM_VTA_SEM_X_PERFIL]) IS NULL OR SUM([NUM_VTA_SEM_X_PERFIL])<=0) THEN 0
		ELSE CONVERT(NUMERIC(18,2),(SUM([NUM_OH_VALORIZADO])/SUM([NUM_VTA_SEM_X_PERFIL]))*100) 
	END AS INSTOCK
FROM (
	SELECT A.* 
	FROM [INFORMES3].[dbo].[CE_INSTOCK] AS A 
	INNER JOIN (
		SELECT 
			NOM_LOCAL
			,COD_LOCAL
			,A.NOM_SKU
			,A.SKU
			,B.DIVISION
			,B.DEPARTAMENTO
			,B.SUBDEPARTAMENTO
			,IND_SURTIDO  
		FROM [INFORMES3].[dbo].[MAESTRA_PRODUCTOS_SURTIDOS] AS A 
		LEFT JOIN [RepNonFood].dbo.MAESTRA_SKU AS B 
			ON B.SKU = A.SKU
		WHERE 
			B.SUBDEPARTAMENTO LIKE '%CERDO%' 
			OR B.SUBDEPARTAMENTO LIKE '%POLLO%' 
			OR B.SUBDEPARTAMENTO LIKE '%PAVO%'
	) AS B 
		ON B.COD_LOCAL = A.COD_LOCAL
		AND B.SKU = A.SKU
	LEFT JOIN [INFORMES3].[dbo].[TIENDAS_ASENTADAS] T
		ON A.COD_LOCAL = T.COD_LOCAL
	WHERE T.COD_LOCAL IS NULL
) AS T
WHERE 
	SUBDEP LIKE '%POLLO%'
	AND SUBCLASE LIKE '%AUTOSERVICIO%'
GROUP BY SUBDEP