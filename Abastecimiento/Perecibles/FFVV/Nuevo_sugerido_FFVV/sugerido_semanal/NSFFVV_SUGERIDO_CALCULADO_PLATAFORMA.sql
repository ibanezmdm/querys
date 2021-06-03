
-- TRUNCATE TABLE NUEVO_SUGERIDO_FFVV.[dbo].[NSFFVV_SUGERIDO_CALCULADO_PLATAFORMA]
-- INSERT INTO NUEVO_SUGERIDO_FFVV.[dbo].[NSFFVV_SUGERIDO_CALCULADO_PLATAFORMA]
	--?? select * from NUEVO_SUGERIDO_FFVV.[dbo].[NSFFVV_SUGERIDO_CALCULADO_PLATAFORMA] where local = 104

	SELECT 
		DISTINCT --[id], -- M
			A.[local], --M
			A.[sku], --M
			A.NOM_SKU [desc_sku], --M
			A.[casepack], --M
			ISNULL(B.[lun],0) [lun],--M
			ISNULL(B.[mar],0) [mar],--M
			isnull(B.[mie],0) [mie],--M
			isnull(B.[jue],0) [jue],--M
			isnull(B.[vie],0) [vie],--M
			isnull(B.[sab],0) [sab],--M
			isnull(B.[dom],0) [dom],--M
			convert(numeric(18,2),isnull(A.FORECAST_SEM_T,0)) [Fcst Semanal],-- CAMBIA POR FORECAST SEMANAL
			ceiling(A.MIN_PRES_SS/ISNULL(A.[casepack],1)) [Min + SS],-- SE MOSTRARÁ MIN PRES+ SS
			A.FR_PONDERADO [Fillrate Ponderado], -- SE MOSTRARA FILLRATE PONDERADO ULTIMAS 4 SEMANAS SUBCLASE
			A.[merma_sEM_ANT] [Merma], --M
			A.OH_INICIAL [on_hand], -- M (OH INICIAL)
			A.TRANSITO_CD+COMPRAS_SEMANA_ACTUAL*FACTOR_FR [transito], -- TRANSITO CD + COMPRAS SEMANA ACTUAL*EFECTO FR
			A.[SUGERIDO_CAJAS],--M
			NULL [corregido],--M
			'' [comentario],--M
			'AUTOMATICO '[ESTADO],--M
			NULL [id_promocion],--SE LLENA CON CERO INICIALMENTE
			M.[DIVISION], --M
			A.SEMANA
	FROM NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_SUGERIDO_SEMANAL_CALCULADO A 
	LEFT JOIN NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_FORECAST_SEMANA_T_PIVOT B 
		ON B.SKU = A.SKU 
		AND B.COD_LOCAL = A.LOCAL 
	LEFT JOIN RepNonFood.dbo.MAESTRA_SKU M 
		ON M.SKU = A.SKU
	where local = 104
	ORDER BY 
		LOCAL, 
		SKU