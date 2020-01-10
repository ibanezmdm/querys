/*-- ?? SELECT * FROM [INFORMES3].[dbo].[View_NUEVO_INSTOCK_TABLA_DIA_v2]
 * Updated_by: Sebastian E Cornejo B
 * Updated_at: 2020/01/08
 * Cambios: 
 *	-> Se cruza con tabla TIENDAS_ASENTADAS para filtrar por tiendas cerradas
 *	-> Se genera una nueva vista con una sola consutla
 *	-> Se actualizan filtros de J02 y J05
 *	-> 2020/01/08 Se Agrega Instock EDLP
 */

SELECT 
	[FECHA_ACTUALIZ],
	[CUADRO_RESUMEN],
	(SUM([NUM_OH_VALORIZADO])/SUM([NUM_VTA_SEM_X_PERFIL])) * 100 AS INSTOCK

FROM (

	SELECT 
		[FECHA_ACTUALIZ],
		[NUM_OH_VALORIZADO],
		[NUM_VTA_SEM_X_PERFIL],
		[CUADRO_RESUMEN],
		[FILTRO]

	FROM (

		SELECT
			CONVERT(DATE, I.[FECHA_ACTUALIZ]) AS [FECHA_ACTUALIZ], 
			SUM(I.[NUM_OH_VALORIZADO]) [NUM_OH_VALORIZADO],
			SUM(I.[NUM_VTA_SEM_X_PERFIL]) [NUM_VTA_SEM_X_PERFIL],

			-- Filtro Instock Compañia
			CASE
				WHEN (
					I.[DIVISION] IN ('J01 - PGC COMESTIBLE', 'J02 - PGC NO COMESTIBLE', 'J05 - FLC')
					AND I.[SIS_REPOSICION] IN ('Reposicion x ASR', 'Informar a ASR')
					)
					OR (
						I.[DIVISION] IN ('J06 - PANADERIA Y PASTELERIA', 'J07 - PLATOS PREPARADOS')
						AND I.[SIS_REPOSICION] IN ('Reposicion x ASR')
					) THEN 1
			END [COMPAÑIA],

			-- Filtro Instock TOP500
			CASE WHEN I.[TOP_500] IS NOT NULL THEN 1 END [TOP500],

			-- Filtro Instock TOP2100
			CASE WHEN I.[TOP_2100] IS NOT NULL THEN 1 END [TOP2100],

			-- Filtro Instock PGC
			CASE
				WHEN (
					I.[DIVISION] IN ('J01 - PGC COMESTIBLE', 'J02 - PGC NO COMESTIBLE')
					AND I.[SIS_REPOSICION] IN ('Reposicion x ASR', 'Informar a ASR')
				) THEN 1
			END [PGC],

			-- Filtro Instock Perecibles
			CASE
				WHEN (
					I.[DIVISION] IN ('J05 - FLC') 
					AND I.[SIS_REPOSICION] IN ('Reposicion x ASR', 'Informar a ASR')
				)
				OR (
					I.[DIVISION] IN ('J06 - PANADERIA Y PASTELERIA', 'J07 - PLATOS PREPARADOS')
					AND I.[SIS_REPOSICION] IN ('Reposicion x ASR')
				) THEN 1
			END [PERECIBLES],

			-- Filtro Instock MMPP
			CASE WHEN I.[MMPP] IS NOT NULL THEN 1 END [MMPP],

			-- Filtro Instock Importado
			CASE WHEN I.[PROCEDENCIA] = 'IMPORTADO' THEN 1 END [IMPORTADO],

			-- Filtro Instock EDLP
			CASE WHEN EDLP.[EDLP] = 'X' THEN 1 END [EDLP]

		FROM [INFORMES3].[dbo].[INSTOCK_NUEVA_PLANILLA] I
		LEFT JOIN [INFORMES3].[dbo].[TIENDAS_ASENTADAS] T
			ON I.[COD_LOCAL] = T.[COD_LOCAL]
		LEFT JOIN INSTOCK_OPT.dbo.SKU_EDLP EDLP
			ON EDLP.SKU = I.SKU

		WHERE T.[COD_LOCAL] IS NULL
		GROUP BY 
			CONVERT(DATE, I.[FECHA_ACTUALIZ]),
			I.[DIVISION],
			I.[SIS_REPOSICION],
			I.[TOP_500],
			I.[TOP_2100],
			I.[MMPP],
			I.[PROCEDENCIA],
			EDLP.[EDLP]

	) AS I
	UNPIVOT (
		[FILTRO] FOR [CUADRO_RESUMEN] IN (
			[COMPAÑIA],
			[TOP500],
			[TOP2100],
			[PGC],
			[PERECIBLES],
			[MMPP],
			[IMPORTADO],
			[EDLP]
		)
	) upvtable
) AS I

GROUP BY
	[FECHA_ACTUALIZ],
	[CUADRO_RESUMEN]
