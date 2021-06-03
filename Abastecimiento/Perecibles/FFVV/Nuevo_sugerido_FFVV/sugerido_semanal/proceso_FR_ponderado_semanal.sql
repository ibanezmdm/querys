-------------------------------------------------
-- FILLRATE SEMANAL
-------------------------------------------------
TRUNCATE TABLE NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_FILLRATE_SEMANAL
INSERT INTO NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_FILLRATE_SEMANAL

	SELECT 
		[SEMANA]
		,SUBCLASE
		,SUM(CAJAS_SOLICITADAS) CAJAS_SOLICITADAS
		,SUM(CAJAS_RECIBIDAS) CAJAS_RECIBIDAS
		,100 * CONVERT(NUMERIC(18,4), CONVERT(NUMERIC(18,2), SUM(CAJAS_RECIBIDAS)) / CONVERT(NUMERIC(18, 2), SUM(CAJAS_SOLICITADAS))) FILLRATE
	FROM (
		SELECT 
			[SEMANA]
			,[DESC_PROV]
			,B.SUBCLASE
			,A.[SKU]      
			,ISNULL(CONVERT(INTEGER, NULLIF([UN_SOLICI], 0) / NULLIF(A.CASE_PACK, 0)), 0) AS CAJAS_SOLICITADAS
			,ISNULL(CONVERT(INTEGER, NULLIF([UN_RECIBI], 0) / NULLIF(A.CASE_PACK, 0)), 0) AS CAJAS_RECIBIDAS
		FROM [INFORMES3].[dbo].[DHW_FILLRATE] A 
		LEFT JOIN [RepNonFood].dbo.MAESTRA_SKU B 
			ON B.SKU = A.SKU
		WHERE B.SUBCLASE LIKE 'J04%'
			AND SEMANA BETWEEN (SELECT DISTINCT SEMANA FROM [INFORMES3].[dbo].[DHW_MES_GC] WHERE FECHA = CONVERT(DATE, GETDATE() - 28))
				AND (SELECT DISTINCT SEMANA FROM [INFORMES3].[dbo].[DHW_MES_GC] WHERE FECHA = CONVERT(DATE, GETDATE() - 7))
	) T
	GROUP BY [SEMANA], SUBCLASE
	    
-------------------------------------------------
-- FILLRATE ULTIMAS 4 SEMANAS
-------------------------------------------------
TRUNCATE TABLE NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_FILLRATE_SEMANAL_PONDERADO;
	--?? select * from NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_FILLRATE_SEMANAL_PONDERADO

	with numero_semana as (
		select
			SEMANA,
			row_number() over (order by semana desc) n_semana
		from NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_FILLRATE_SEMANAL
		group by semana
	)

	INSERT INTO NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_FILLRATE_SEMANAL_PONDERADO

	select 
		subclase,
		isnull([4], 0) FR_SEM4,
		isnull([3], 0) FR_SEM3,
		isnull([2], 0) FR_SEM2,
		isnull([1], 0) FR_SEM1,
		isnull([1], 0) * 0.4 + isnull([2], 0) * 0.3 + isnull([3], 0) * 0.2 + isnull([4], 0) * 0.1 FR_PONDERADO
	from (
		select 
			subclase,
			FILLRATE,
			n_semana
		from NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_FILLRATE_SEMANAL fs
		inner join numero_semana ns
			on fs.SEMANA = ns.SEMANA
	) f
	pivot (sum(FILLRATE) for n_semana in ([1], [2], [3], [4])) as pvt
	