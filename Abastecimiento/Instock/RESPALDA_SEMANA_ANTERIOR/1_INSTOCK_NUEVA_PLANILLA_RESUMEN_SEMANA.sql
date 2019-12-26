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
)

SELECT 
	[semana], 
	[nuevo_abc], 
	[estado], 
	[top_2100], 
	[top_500], 
	[mmpp], 
	[inv_negativo], 
	[nom_local], 
	[cod_local], 
	[division], 
	[departamento], 
	[subdep], 
	[metod_abast], 
	Sum([num_oh_valorizado])    AS [NUM_OH_VALORIZADO], 
	Sum([num_vta_sem_x_perfil]) AS [NUM_VTA_SEM_X_PERFIL], 
	Sum([vta_perdida_vp])       AS [VTA_PERDIDA_VP], 
	Sum([costo_inv_disp_hoy])   AS [COSTO_INV_DISP_HOY], 
	Sum([monto_vta])            AS [MONTO_VTA], 
	Sum([cantidad_skus])        AS [CANTIDAD_SKUS], 
	Sum([demanda_semanal])      AS [DEMANDA_SEMANAL], 
	[sis_reposicion] 
--INTO   [INFORMES3].[dbo].[instock_nueva_planilla_resumen_semana] 
FROM [INFORMES3].[dbo].[instock_nueva_planilla_historia]
WHERE 
	semana IN (DATEPART(WW, GETDATE()) - 1 + DATEPART(yy, GETDATE())*100)
	and (
		DIVISION like 'J01%' 
		or DIVISION  like 'J02%' 
		or DIVISION  like 'J05%'
	)
GROUP BY 
	[semana], 
	[nuevo_abc], 
	[estado], 
	[top_2100], 
	[top_500], 
	[mmpp], 
	[inv_negativo], 
	[nom_local], 
	[cod_local], 
	[division], 
	[departamento], 
	[subdep], 
	[metod_abast], 
	[sis_reposicion]