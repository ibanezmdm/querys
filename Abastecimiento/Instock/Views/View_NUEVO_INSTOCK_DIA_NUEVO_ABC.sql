/* View_NUEVO_INSTOCK_TABLA_DIA
 * Updated_by: Sebastian E Cornejo B
 * Updated_at: 2019/11/20
 * Cambios: Se cruza con tabla Tiendas_Asentadas, dejando el filtro de dependiendo de los valores almacenados en esta
 */

SELECT
	CONVERT(DATE, I.fecha_actualiz) AS FECHA_ACTUALIZ,
	-- 'NUEVA CLASE C' AS [Cuadro Resumen],
	'NUEVA CLASE ' + I.abc_2018 [Cuadro Resumen],
	CONVERT(NUMERIC(12, 1), SUM(I.[num_oh_valorizado]) / NULLIF (SUM(I.[num_vta_sem_x_perfil]), 0) * 100) AS INSTOCK
FROM [INFORMES3].[dbo].[instock_nueva_planilla] I
LEFT JOIN [INFORMES3].[dbo].[TIENDAS_ASENTADAS] T
	ON I.COD_LOCAL = T.COD_LOCAL
WHERE 
	(
		(
			I.division IN ('J01 - PGC COMESTIBLE')
			AND I.sis_reposicion IN ('Reposicion x ASR', 'Informar a ASR') 
		) 
		OR (
			I.division IN ('J02 - PGC NO COMESTIBLE', 'J05 - FLC', 'J06 - PANADERIA Y PASTELERIA', 'J07 - PLATOS PREPARADOS')
			AND I.sis_reposicion IN ('Reposicion x ASR')
		) 
	)
	AND T.COD_LOCAL IS NULL
	AND i.abc_2018 IS NOT NULL
GROUP BY
	CONVERT(DATE, fecha_actualiz),
	I.abc_2018