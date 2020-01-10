/*-- ?? SELECT * FROM [INFORMES3].[dbo].[INSTOCK_NUEVA_PLANILLA_RESUMEN_SEMANA]
 * Updated_by: Sebastian E Cornejo B
 * Updated_at: 2020/01/08
 * Cambios: 
 *	-> 2020/01/08 Se Agrega Instock EDLP
 */

INSERT INTO [INFORMES3].[dbo].[INSTOCK_NUEVA_PLANILLA_RESUMEN_SEMANA] (
	[SEMANA]
	,[COD_CLASIFICACION_SKU]
	,[ESTADO]
	,[TOP_2100]
	,[TOP_500]
	,[MMPP]
	,[INV_NEGATIVO]
	,[NOM_LOCAL]
	,[COD_LOCAL]
	,[DIVISION]
	,[DEPARTAMENTO]
	,[SUBDEP]
	,[METOD_ABAST]
	,[NUM_OH_VALORIZADO]
	,[NUM_VTA_SEM_X_PERFIL]
	,[VTA_PERDIDA_VP]
	,[COSTO_INV_DISP_HOY]
	,[MONTO_VTA]
	,[CANTIDAD_SKUS]
	,[DEMANDA_SEMANAL]
	,[SIS_REPOSICION]
	,[EDLP]
)

SELECT 
	I.[semana], 
	I.[nuevo_abc], 
	I.[estado], 
	I.[top_2100], 
	I.[top_500], 
	I.[mmpp], 
	I.[inv_negativo], 
	I.[nom_local], 
	I.[cod_local], 
	I.[division], 
	I.[departamento], 
	I.[subdep], 
	I.[metod_abast], 
	Sum(I.[num_oh_valorizado])    AS [NUM_OH_VALORIZADO], 
	Sum(I.[num_vta_sem_x_perfil]) AS [NUM_VTA_SEM_X_PERFIL], 
	Sum(I.[vta_perdida_vp])       AS [VTA_PERDIDA_VP], 
	Sum(I.[costo_inv_disp_hoy])   AS [COSTO_INV_DISP_HOY], 
	Sum(I.[monto_vta])            AS [MONTO_VTA], 
	Sum(I.[cantidad_skus])        AS [CANTIDAD_SKUS], 
	Sum(I.[demanda_semanal])      AS [DEMANDA_SEMANAL], 
	I.[sis_reposicion],
	EDLP.EDLP
--INTO   [INFORMES3].[dbo].[instock_nueva_planilla_resumen_semana] 
FROM [INFORMES3].[dbo].[instock_nueva_planilla_historia] I
LEFT JOIN [INSTOCK_OPT].dbo.SKU_EDLP EDLP
	ON EDLP.SKU = I.SKU
WHERE 
	semana IN (DATEPART(WW, GETDATE()) - 1 + DATEPART(yy, GETDATE())*100)
	AND (
		(I.[DIVISION] IN ('J01 - PGC COMESTIBLE', 'J02 - PGC NO COMESTIBLE', 'J05 - FLC') AND I.[SIS_REPOSICION] IN ('Reposicion x ASR', 'Informar a ASR'))
		OR (I.[DIVISION] IN ('J06 - PANADERIA Y PASTELERIA', 'J07 - PLATOS PREPARADOS') AND I.[SIS_REPOSICION] IN ('Reposicion x ASR'))
	)
GROUP BY 
	I.[semana], 
	I.[nuevo_abc], 
	I.[estado], 
	I.[top_2100], 
	I.[top_500], 
	I.[mmpp], 
	I.[inv_negativo], 
	I.[nom_local], 
	I.[cod_local], 
	I.[division], 
	I.[departamento], 
	I.[subdep], 
	I.[metod_abast], 
	I.[sis_reposicion],
	EDLP.EDLP