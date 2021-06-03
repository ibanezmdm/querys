-----------------------------------------------------------
-- CARGA TABLA VENTA FFVV DIARIA
-----------------------------------------------------------
TRUNCATE TABLE NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_VENTA_DIARIA
INSERT INTO NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_VENTA_DIARIA

	SELECT *
	FROM (
		-- TIENDAS NORMALES
		SELECT 
			[COD_LOCALFISICO] COD_LOCAL
			,[CUSTCOL_7] SKU
			,[ID_SEMANACANALISIS] SEMANA
			,ID_DIAANALISIS DIA
			,SUM([UN_VENTA]) VTA
		FROM (
			SELECT 
				[CUSTCOL_7]
				,VTA.[COD_LOCALFISICO]
				,[ID_SEMANACANALISIS]
				,VTA.[ID_DIAANALISIS]
				,CASE 
					WHEN (ISNULL([UN_VENTA], 0) - ISNULL(VTA_LL.UNIDADES, 0)) < 0 THEN 0
					ELSE (ISNULL([UN_VENTA], 0) - ISNULL(VTA_LL.UNIDADES, 0)) 
				END AS UN_VENTA
			FROM [SUGERIDO_COMPRA].[dbo].[FFYVV_VTA_SEMANAS] VTA 
			LEFT JOIN [NUEVO_SUGERIDO_FFVV].[dbo].[vw_sug_sem_vta_llave] VTA_LL 
				ON VTA_LL.SKU = VTA.CUSTCOL_7 
				AND VTA_LL.cod_local = VTA.COD_LOCALFISICO 
				AND CONVERT(DATE, VTA_LL.ID_DIAANALISIS) = CONVERT(DATE,VTA.ID_DIAANALISIS)
		) T
		WHERE ID_SEMANACANALISIS IN (
				SELECT DISTINCT TOP 4 ID_SEMANACANALISIS
				FROM [SUGERIDO_COMPRA].[dbo].[FFYVV_VTA_SEMANAS]
				where ID_SEMANACANALISIS NOT IN (datepart(year, getdate() + 1 - datepart(weekday, getdate())) * 100 + datepart(iso_week, getdate() + 1 - datepart(weekday, getdate())))
				ORDER BY ID_SEMANACANALISIS DESC
			)
			AND COD_LOCALFISICO NOT IN (115)
		GROUP BY 
			[COD_LOCALFISICO] 
			,[CUSTCOL_7]
			,[ID_SEMANACANALISIS]
			,ID_DIAANALISIS

		UNION ALL

		-- TIENDAS GRISES
		SELECT 
			A.[COD_LOCAL]
			,A.[SKU]
			,B.SEMANA
			,[ID_DIAANALISIS] DIA
			,sum([UNIDADES_VENTA]) VTA
		FROM [TIENDA_GRIS].[dbo].[VENTA_VNP_DIARIA] A 
		LEFT JOIN INFORMES3.dbo.DHW_MES_GC B 
			ON B.FECHA = A.ID_DIAANALISIS 
		LEFT JOIN RepNonFood.dbo.MAESTRA_SKU C 
			ON C.SKU = A.SKU
		WHERE B.SEMANA IN (
				SELECT DISTINCT TOP 4 SEMANA
				FROM [TIENDA_GRIS].[dbo].[VENTA_VNP_DIARIA] A 
				LEFT JOIN INFORMES3.dbo.DHW_MES_GC B 
					ON B.FECHA = A.ID_DIAANALISIS
				where SEMANA NOT IN (datepart(year, getdate() + 1 - datepart(weekday, getdate())) * 100 + datepart(iso_week, getdate() + 1 - datepart(weekday, getdate())))
				ORDER BY SEMANA DESC
			)
			and C.DIVISION LIKE 'J04%' 
			AND COD_LOCAL IN (138,147)
		GROUP BY A.[COD_LOCAL]
			,A.[SKU]
			,B.SEMANA
			,[ID_DIAANALISIS]

	) T


-----------------------------------------------------------
-- CARGA TABLA VENTA FFVV SEMANAL
-----------------------------------------------------------
TRUNCATE TABLE NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_VENTA_SEMANAL
INSERT INTO NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_VENTA_SEMANAL

	select 
		COD_LOCAL,
		SKU,
		SEMANA,
		sum(vta) vta
	from NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_VENTA_DIARIA
	group by 	
		COD_LOCAL,
		SKU,
		SEMANA


--------------------------------------------------------
-- CALCULO_PROM_VTA_SEM_FFVV
--------------------------------------------------------
TRUNCATE TABLE NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_PROM_VTA_SEM
INSERT INTO NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_PROM_VTA_SEM

	SELECT 
		V.COD_LOCAL,
		V.SKU,
		M.SUBCLASE,
		M.ESTADO,
		CASE WHEN S.SKU IS NULL AND S.LOCAL IS NULL THEN 0 ELSE 1 END IND_SURTIDO,
		avg(VTA) PROM_SIMPLE,
		ISNULL(STDEV(VTA), 0) DESV_EST
	FROM NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_VENTA_SEMANAL V
	LEFT JOIN [10.195.254.201].RepNonFood.dbo.MAESTRA_SKU M
		ON V.SKU = M.SKU
	LEFT JOIN ( 
		SELECT 
			Codigo SKU, 
			Division DIVISION, 
			Surtido, 
			Sala LOCAL
		FROM [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_SURTIDO_TIENDA]
		WHERE Surtido = 1
	) S
		ON S.LOCAL = V.COD_LOCAL
		AND S.SKU = V.SKU
	WHERE M.DIVISION LIKE 'J04%'
	GROUP BY
		V.COD_LOCAL,
		V.SKU,
		M.SUBCLASE,
		M.ESTADO,
		CASE WHEN S.SKU IS NULL AND S.LOCAL IS NULL THEN 0 ELSE 1 END
	
-------------------------------------------------
--CALCULO_PROMEDIO_VENTA_SEMANAL_ACOTADO
-------------------------------------------------
TRUNCATE TABLE NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_PROM_SEMANAL_ACOTADO
INSERT INTO NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_PROM_SEMANAL_ACOTADO

	SELECT 
		VF.COD_LOCAL,
		VF.SKU,
		VF.SUBCLASE,
		VF.ESTADO,
		VF.IND_SURTIDO,
		AVG(VF.VTA) PROM_SEM_ACOTADO
	FROM (
		SELECT 
			V.COD_LOCAL,
			V.SKU,
			M.SUBCLASE,
			SEMANA,
			SUM(VTA) VTA,
			CASE WHEN S.SKU IS NULL AND S.LOCAL IS NULL THEN 0 ELSE 1 END IND_SURTIDO,
			M.ESTADO
		FROM NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_VENTA_SEMANAL V
		LEFT JOIN RepNonFood.dbo.MAESTRA_SKU M
			ON M.SKU = V.SKU
		LEFT JOIN 	 
		( 
			SELECT Codigo SKU, Division DIVISION, Surtido, Sala LOCAL
			FROM [10.195.254.201].[NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_SURTIDO_TIENDA]
			WHERE Surtido=1
		) S
			ON S.LOCAL = V.COD_LOCAL
			AND S.SKU = V.SKU
		GROUP BY 
			V.COD_LOCAL,
			V.SKU,
			M.SUBCLASE,
			SEMANA,
			CASE WHEN S.SKU IS NULL AND S.LOCAL IS NULL THEN 0 ELSE 1 END,
			M.ESTADO
	) VF
	LEFT JOIN NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_PROM_VTA_SEM PV
		ON PV.COD_LOCAL = VF.COD_LOCAL
		AND PV.SKU = VF.SKU
	WHERE VF.VTA <= (PV.PROM_SIMPLE + PV.DESV_EST)
		AND VF.VTA >= (PV.PROM_SIMPLE - PV.DESV_EST)
		-- AND VF.COD_LOCAL = 501
		-- AND VF.SUBCLASE LIKE '%PAPA'
	GROUP BY
		VF.COD_LOCAL,
		VF.SKU,
		VF.SUBCLASE,
		VF.ESTADO,
		VF.IND_SURTIDO
	
--------------------------------------------------
-- CALCULO_VTA_DIA_SEMANA_FFVV
--------------------------------------------------
TRUNCATE TABLE NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_VTA_DIA_SEMANA
INSERT INTO NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_VTA_DIA_SEMANA

	SELECT 
		V.[COD_LOCAL]
		,M.SUBCLASE
		,M.ESTADO
		,CASE WHEN S.SKU IS NULL AND S.LOCAL IS NULL THEN 0 ELSE 1 END IND_SURTIDO
		,SUM([VTA]) VTA
		,DATEPART(WEEKDAY, DIA) DIA_SEMANA
		,SEMANA
	--INTO NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_VTA_DIA_SEMANA
	FROM NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_VENTA_DIARIA V
	LEFT JOIN RepNonFood.dbo.MAESTRA_SKU M
		ON V.SKU = M.SKU
	LEFT JOIN (
			SELECT Codigo SKU, Division DIVISION, Surtido, Sala LOCAL
			FROM [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_SURTIDO_TIENDA]
			WHERE Surtido = 1
	) S
		ON S.LOCAL = V.COD_LOCAL
		AND S.SKU = V.SKU
	WHERE M.DIVISION LIKE 'J04%'
	GROUP BY 
		V.COD_LOCAL,
		M.SUBCLASE,
		DATEPART(WEEKDAY, DIA),
		SEMANA,
		M.ESTADO,
		CASE WHEN S.SKU IS NULL AND S.LOCAL IS NULL THEN 0 ELSE 1 END
	
	
-------------------------------------------------
-- CALCULO_PERFIL_DIARIO_FFVV
-------------------------------------------------
TRUNCATE TABLE NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_PERFIL_DIARIO
INSERT INTO NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_PERFIL_DIARIO

	SELECT 
		B.COD_LOCAL,
		B.SUBCLASE,
		B.DIA_SEMANA,
		V.VTA,
		VT.VTA VTA_TOTAL,
		V.VTA / CASE WHEN VT.VTA = 0 THEN NULL ELSE VT.VTA END PERFIL_DIA
	FROM (
		SELECT * FROM
			(SELECT DISTINCT COD_LOCAL FROM NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_VTA_DIA_SEMANA) L,
			(SELECT DISTINCT DIA_SEMANA FROM NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_VTA_DIA_SEMANA) D,
			(SELECT DISTINCT SUBCLASE FROM RepNonFood.dbo.MAESTRA_SKU WHERE DIVISION LIKE 'J04%') S
	) B
	LEFT JOIN NUEVO_SUGERIDO_FFVV.dbo.vw_sug_sem_vta_promedio_dia V -- VENTA TOTAL DIA
		ON V.COD_LOCAL = B.COD_LOCAL
		AND V.SUBCLASE = B.SUBCLASE
		AND V.DIA_SEMANA = B.DIA_SEMANA
	LEFT JOIN (
		SELECT 
			COD_LOCAL
			,SUBCLASE
			,SUM(VTA) VTA
		FROM NUEVO_SUGERIDO_FFVV.dbo.vw_sug_sem_vta_promedio_dia VT
		GROUP BY
			COD_LOCAL
			,SUBCLASE
	) VT -- VENTA TOTAL SEMANAL
		ON VT.COD_LOCAL = B.COD_LOCAL
		AND VT.SUBCLASE = B.SUBCLASE
	WHERE B.COD_LOCAL NOT IN (115)


---------------------------------------------------
-- UPDATE PERFILES INCOMPLETOS
---------------------------------------------------
UPDATE NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_PERFIL_DIARIO
	SET VTA = 1, VTA_TOTAL = 7, PERFIL_DIA = 1.0 / 7.0
	FROM NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_PERFIL_DIARIO P
	INNER JOIN (
		SELECT DISTINCT COD_LOCAL, SUBCLASE
		FROM NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_PERFIL_DIARIO
		WHERE PERFIL_DIA IS NULL
	) F
		ON F.COD_LOCAL = P.COD_LOCAL
		AND F.SUBCLASE = P.SUBCLASE
	


----------------------------------------------------
-- CALCULA FORECAST DIARIO
----------------------------------------------------
delete from NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_FORECAST_DIARIO
	where semana = (datepart(year, GETDATE() + 8 - datepart(weekday, getdate())) * 100 + datepart(iso_week, GETDATE() + 8 - datepart(weekday, getdate())))
		or semana <= (datepart(year, GETDATE() + 1 - 7 * 4 - datepart(weekday, getdate())) * 100 + datepart(iso_week, GETDATE() + 1 - 7 * 4 - datepart(weekday, getdate())));

	with forecast as (
		SELECT 
			(datepart(year, GETDATE() + 8 - datepart(weekday, getdate())) * 100 + datepart(iso_week, GETDATE() + 8 - datepart(weekday, getdate()))) SEMANA,
			A.COD_LOCAL,
			A.SKU,
			A.SUBCLASE,
			B.DIA_SEMANA,
			B.PERFIL_DIA,
			A.PROM_SEM_ACOTADO * B.PERFIL_DIA FORECAST_DIA
		FROM NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_PROM_SEMANAL_ACOTADO A 
		LEFT JOIN NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_PERFIL_DIARIO B 
			ON B.COD_LOCAL = A.COD_LOCAL 
			AND B.SUBCLASE = A.SUBCLASE
	)

	INSERT INTO NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_FORECAST_DIARIO
	--?? select distinct semana from  NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_FORECAST_DIARIO order by semana desc

	SELECT 
		AA.SEMANA,
		AA.COD_LOCAL,
		AA.SKU,
		AA.SUBCLASE,
		AA.DIA_SEMANA,
		BB.FECHA,
		AA.PERFIL_DIA,
		AA.FORECAST_DIA
	FROM forecast AA 
	LEFT JOIN (
		SELECT 
			SEMANA, 
			FECHA, 
			DATEPART(weekday, FECHA) DIA 
		FROM INFORMES3.dbo.DHW_MES_GC
 	) BB 
		ON BB.SEMANA = AA.SEMANA 
		AND BB.DIA = AA.DIA_SEMANA
	ORDER BY 
		AA.COD_LOCAL,
		AA.SKU,
		AA.SUBCLASE,
		AA.DIA_SEMANA