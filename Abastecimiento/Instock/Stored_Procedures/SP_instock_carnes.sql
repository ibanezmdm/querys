USE [INFORMES3]
GO
/****** Object:  StoredProcedure [dbo].[Sp_INSTOCK_CARNES]    Script Date: 21-11-2019 11:57:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:			Carlos Reyes L.
-- Create date: 26-04-2018
-- Description:	Procedimiento Instock Carnes
-- Updated_at: 	2019/11/21
-- Cambios: 		Se genera filtro de salas cerradas en base a la tabla TIENDAS_ASENTADAS
-- EXEC Sp_INSTOCK_CARNES
-- =============================================
ALTER PROCEDURE [dbo].[Sp_INSTOCK_CARNES]
AS
BEGIN
 --====PASO 0: FILTRA TABLAS DE VENTA Y STOCK SEGUN SURTIDO TIENDAS======

--==== TABLA VENTA SEMANAL FILTRADA =======================================================================
TRUNCATE TABLE [INFORMES3].dbo.[INSTOCK_CARNES_VTA_SEMANAL_VACUNO_FILTRADA]

INSERT INTO [INFORMES3].dbo.[INSTOCK_CARNES_VTA_SEMANAL_VACUNO_FILTRADA] (
	[DESC_SEMANACANALISIS]
	,[ID_SEMANACANALISIS]
	,[COD_LOCALFISICO]
	,[SKU]
	,[UN_VTA]
	,[COSTO_VTA]
	,[VTA_SI]
)

SELECT 
	A.[DESC_SEMANACANALISIS]
	,A.[ID_SEMANACANALISIS]
	,A.[COD_LOCALFISICO]
	,A.[SKU]
	,A.[UN_VTA]
	,A.[COSTO_VTA]
	,A.[VTA_SI]
--INTO [INFORMES3].dbo.[INSTOCK_CARNES_VTA_SEMANAL_VACUNO_FILTRADA]
FROM [INFORMES3].dbo.INSTOCK_CARNES_VTA_SEMANAL_VACUNO AS A 
INNER JOIN [INFORMES3].dbo.INSTOCK_CARNES_SURTIDO AS B 
	ON B.COD_LOCAL = A.COD_LOCALFISICO 
	AND B.SKU = A.SKU
WHERE A.COD_LOCALFISICO NOT IN (503,212)


--==== TABLA VENTA DIA SEMANA FILTRADA =======================================================================
TRUNCATE TABLE [INFORMES3].[dbo].[INSTOCK_CARNES_VTA_DIA_SEMANA_CARNES_FILTRADA]

INSERT INTO [INFORMES3].[dbo].[INSTOCK_CARNES_VTA_DIA_SEMANA_CARNES_FILTRADA] (
	[COD_LOCALFISICO]
	,[DESC_LOCALFISICO]
	,[SKU]
	,[DESC_SKU]
	,[DESC_DIA_SEMANA_ANALISIS]
	,[UN_VTA]
)

SELECT 
	A.[COD_LOCALFISICO]
	,A.[DESC_LOCALFISICO]
	,A.[SKU]
	,A.[DESC_SKU]
	,A.[DESC_DIA_SEMANA_ANALISIS]
	,A.[UN_VTA]
--INTO [INFORMES3].[dbo].[INSTOCK_CARNES_VTA_DIA_SEMANA_CARNES_FILTRADA]
FROM [INFORMES3].[dbo].[INSTOCK_CARNES_VTA_DIA_SEMANA_CARNES] AS A 
INNER JOIN [INFORMES3].dbo.INSTOCK_CARNES_SURTIDO AS B 
	ON B.COD_LOCAL = A.COD_LOCALFISICO 
	AND B.SKU = A.SKU
WHERE A.COD_LOCALFISICO NOT IN (503,212)


--======================TABLA STOCK FILTRADA ======================================
TRUNCATE TABLE [INFORMES3].[dbo].[INSTOCK_CARNES_STOCK_DISPONIBLE_VACUNO_FILTRADA]

INSERT INTO [INFORMES3].[dbo].[INSTOCK_CARNES_STOCK_DISPONIBLE_VACUNO_FILTRADA] (
	[ID_DIAANALISIS]
	,[COD_LOCAL]
	,[CLASE]
	,[SUBCLASE]
	,[SKU]
	,[UN_INV_DISP_HOY]
	,[UN_INV_CONTA_HOY]
)
SELECT 
	A.[ID_DIAANALISIS]
	,A.[COD_LOCAL]
	,A.[CLASE]
	,A.[SUBCLASE]
	,A.[SKU]
	,A.[UN_INV_DISP_HOY]
	,A.[UN_INV_CONTA_HOY]
	--INTO [INFORMES3].[dbo].[INSTOCK_CARNES_STOCK_DISPONIBLE_VACUNO_FILTRADA]
FROM [INFORMES3].[dbo].[INSTOCK_CARNES_STOCK_DISPONIBLE_VACUNO] AS A 
INNER JOIN [INFORMES3].dbo.INSTOCK_CARNES_SURTIDO AS B 
	ON B.COD_LOCAL = A.COD_LOCAL 
	AND B.SKU = A.SKU
WHERE A.COD_LOCAL NOT IN (503,212)


--======================HACE CERO STOCK NEGATIVO==============================

UPDATE [INFORMES3].[dbo].[INSTOCK_CARNES_STOCK_DISPONIBLE_VACUNO_FILTRADA]
SET UN_INV_CONTA_HOY=0
WHERE UN_INV_CONTA_HOY<0

UPDATE [INFORMES3].[dbo].[INSTOCK_CARNES_STOCK_DISPONIBLE_VACUNO_FILTRADA]
SET UN_INV_DISP_HOY=0
WHERE UN_INV_DISP_HOY<0

--===PASO 1: CREA TABLA PROM_VTA_X_LOCAL========================
/*TRUNCATE TABLE [INFORMES3].[dbo].[INSTOCK_CARNES_PROM_VTA_X_LOCAL]

INSERT INTO [INFORMES3].[dbo].[INSTOCK_CARNES_PROM_VTA_X_LOCAL]
           ([CORTE]
           ,[COD_LOCALFISICO]
           ,[VTA_PROM_SEM])
SELECT D.CORTE
       ,D.COD_LOCALFISICO
       ,AVG(D.UN_VTA) AS VTA_PROM_SEMANA
FROM (SELECT B.[ID_SEMANACANALISIS]
			,B.COD_LOCALFISICO
			,B.CORTE
			,SUM(B.UN_VTA) AS UN_VTA
	  FROM (SELECT V.[DESC_SEMANACANALISIS]
				  ,V.[ID_SEMANACANALISIS]
				  ,V.[COD_LOCALFISICO]
                  ,V.[SKU]
                  ,C.CORTE
                  ,V.[UN_VTA] as UN_VTA
			FROM  [INFORMES3].dbo.INSTOCK_CARNES_VTA_SEMANAL_VACUNO_FILTRADA AS V INNER JOIN
		   (SELECT SKU
                  ,CORTE 
            FROM [INFORMES3].dbo.[INSTOCK_CARNES_CORTES_SKU_CARNES_COMPLETO]
	        WHERE SUB_DEPARTAMENTO='J030101 - CARNES DE VACUNO') AS C ON C.SKU = V.SKU) AS B
      GROUP BY B.[ID_SEMANACANALISIS]
              ,B.COD_LOCALFISICO
              ,B.CORTE) AS D
GROUP BY D.COD_LOCALFISICO
        ,D.CORTE*/
        
TRUNCATE TABLE [INFORMES3].[dbo].[INSTOCK_CARNES_CONSOLIDADO]

INSERT INTO [INFORMES3].[dbo].[INSTOCK_CARNES_CONSOLIDADO] (
	[ID_SEMANACANALISIS]
	,[COD_LOCALFISICO]
	,[CORTE]
	,[UN_VTA]
)

SELECT 
	B.[ID_SEMANACANALISIS]
	,B.COD_LOCALFISICO
	,B.CORTE
	,SUM(B.UN_VTA) AS UN_VTA
	-- INTO [INFORMES3].dbo.[INSTOCK_CARNES_CONSOLIDADO]
FROM (
	SELECT 
		V.[DESC_SEMANACANALISIS]
		,V.[ID_SEMANACANALISIS]
		,V.[COD_LOCALFISICO]
		,V.[SKU]
		,C.CORTE
		,V.[UN_VTA] as UN_VTA
	FROM [INFORMES3].dbo.INSTOCK_CARNES_VTA_SEMANAL_VACUNO_FILTRADA AS V 
	INNER JOIN (
		SELECT
			SKU
			,CORTE
		FROM [INFORMES3].dbo.[INSTOCK_CARNES_CORTES_SKU_CARNES_COMPLETO]
		WHERE SUB_DEPARTAMENTO='J030101 - CARNES DE VACUNO'
	) AS C
		ON C.SKU = V.SKU
) AS B
WHERE B.COD_LOCALFISICO NOT IN (503,212)
GROUP BY
	B.[ID_SEMANACANALISIS]
	,B.COD_LOCALFISICO
	,B.CORTE

---===

TRUNCATE TABLE [INFORMES3].[dbo].[INSTOCK_CARNES_PROM_VTA_X_LOCAL]

INSERT INTO [INFORMES3].[dbo].[INSTOCK_CARNES_PROM_VTA_X_LOCAL] (
	[CORTE]
	,[COD_LOCALFISICO]
	,[VTA_PROM_SEM]
)

SELECT 
	D.CORTE
	,D.COD_LOCALFISICO
	,AVG(D.UN_VTA) AS VTA_PROM_SEMANA
FROM (
	SELECT * FROM [INFORMES3].dbo.[INSTOCK_CARNES_CONSOLIDADO]
) AS D
WHERE D.COD_LOCALFISICO NOT IN (503,212)
GROUP BY 
	D.COD_LOCALFISICO
	,D.CORTE


--====PASO 2: CREA TABLA VTA_PROM_X_CORTE=========================================

TRUNCATE TABLE [INFORMES3].[dbo].[INSTOCK_CARNES_VTA_PROM_X_CORTE]

INSERT INTO [INFORMES3].[dbo].[INSTOCK_CARNES_VTA_PROM_X_CORTE] (
	CORTE
	,VTA_PROM_CIA_SEM
)

SELECT
	CORTE
	,AVG(VTA_ACUM_CORTE) AS VTA_PROM_CIA_SEM
--INTO [INFORMES3].[dbo].[INSTOCK_CARNES_VTA_PROM_X_CORTE]
FROM (
	SELECT 
		DESC_SEMANACANALISIS
		,CORTE
		,SUM(UN_VTA) AS VTA_ACUM_CORTE
	FROM (
		SELECT 
			V.DESC_SEMANACANALISIS
			,V.ID_SEMANACANALISIS
			,V.COD_LOCALFISICO
			,V.SKU
			,C.CORTE
			,V.UN_VTA
			,V.COSTO_VTA
			,V.VTA_SI
		FROM [INFORMES3].dbo.INSTOCK_CARNES_VTA_SEMANAL_VACUNO_FILTRADA AS V 
		INNER JOIN (
			SELECT 
				SKU
				,CORTE 
			FROM [INFORMES3].dbo.[INSTOCK_CARNES_CORTES_SKU_CARNES_COMPLETO]
			WHERE SUB_DEPARTAMENTO='J030101 - CARNES DE VACUNO'
		) AS C 
			ON C.SKU = V.SKU
	) AS T
	GROUP BY 
		DESC_SEMANACANALISIS
		,CORTE
) AS TT
GROUP BY CORTE


--====PASO 3: CREA TABLA SUMA_VTA_DIARIA_LOCAL======================================

TRUNCATE TABLE [INFORMES3].[dbo].[INSTOCK_CARNES_SUMA_VTA_DIARIA_LOCAL]

INSERT INTO [INFORMES3].[dbo].[INSTOCK_CARNES_SUMA_VTA_DIARIA_LOCAL] (
	COD_LOCALFISICO
	,CORTE
	,DESC_DIA_SEMANA_ANALISIS
	,SUM_VTA
)
SELECT 
	COD_LOCALFISICO
	,CORTE
	,DESC_DIA_SEMANA_ANALISIS
	,SUM(UN_VTA) AS SUM_VTA
--INTO [INFORMES3].[dbo].[INSTOCK_CARNES_SUMA_VTA_DIARIA_LOCAL]
FROM (
	SELECT 
		V.COD_LOCALFISICO
		,V.DESC_LOCALFISICO
		,V.SKU
		,C.CORTE
		,V.DESC_SKU
		,V.DESC_DIA_SEMANA_ANALISIS
		,V.UN_VTA
	FROM [INFORMES3].dbo.INSTOCK_CARNES_VTA_DIA_SEMANA_CARNES_FILTRADA AS V 
	INNER JOIN (
		SELECT 
			SKU
			,CORTE 
		FROM [INFORMES3].dbo.[INSTOCK_CARNES_CORTES_SKU_CARNES_COMPLETO]
		WHERE SUB_DEPARTAMENTO='J030101 - CARNES DE VACUNO'
	) AS C 
		ON C.SKU = V.SKU
) AS T
WHERE COD_LOCALFISICO NOT IN (503,212)
GROUP BY 
	COD_LOCALFISICO
	,CORTE
	,DESC_DIA_SEMANA_ANALISIS


--====PASO 4: CREA TABLA SUMA_VTA_SEMANA_LOCAL=======================================

TRUNCATE TABLE [INFORMES3].[dbo].[INSTOCK_CARNES_SUMA_VTA_SEMANA_LOCAL]

INSERT INTO [INFORMES3].[dbo].[INSTOCK_CARNES_SUMA_VTA_SEMANA_LOCAL] (
	COD_LOCALFISICO
	,CORTE
	,SUM_VTA_SEMANA_LOCAL
)

SELECT
	COD_LOCALFISICO
	,CORTE
	,SUM(SUM_VTA) AS SUM_VTA_SEMANA_LOCAL
--INTO [INFORMES3].[dbo].[INSTOCK_CARNES_SUMA_VTA_SEMANA_LOCAL]
FROM (
	SELECT 
		COD_LOCALFISICO
		,CORTE
		,DESC_DIA_SEMANA_ANALISIS
		,SUM(UN_VTA) AS SUM_VTA
	FROM (
		SELECT 
			V.COD_LOCALFISICO
			,V.DESC_LOCALFISICO
			,V.SKU
			,C.CORTE
			,V.DESC_SKU
			,V.DESC_DIA_SEMANA_ANALISIS
			,V.UN_VTA
		FROM [INFORMES3].dbo.INSTOCK_CARNES_VTA_DIA_SEMANA_CARNES_FILTRADA AS V 
		INNER JOIN (
			SELECT 
				SKU
				,CORTE 
			FROM [INFORMES3].dbo.[INSTOCK_CARNES_CORTES_SKU_CARNES_COMPLETO]
			WHERE SUB_DEPARTAMENTO='J030101 - CARNES DE VACUNO'
		) AS C 
			ON C.SKU = V.SKU
	) AS T
	GROUP BY 
		COD_LOCALFISICO
		,CORTE
		,DESC_DIA_SEMANA_ANALISIS
) AS TT
WHERE COD_LOCALFISICO NOT IN (503,212)
GROUP BY 
	COD_LOCALFISICO, 
	CORTE


--===PASO 5: CREA TABLA STOCK_X_LOCAL===================================================

TRUNCATE TABLE [INFORMES3].[dbo].[INSTOCK_CARNES_STOCK_X_LOCAL]

INSERT INTO [INFORMES3].[dbo].[INSTOCK_CARNES_STOCK_X_LOCAL] (
	COD_LOCAL
	,CORTE
	,STOCK_HOY
)

SELECT
	COD_LOCAL
	,CORTE
	,SUM(UN_INV_CONTA_HOY) AS STOCK_HOY
--INTO [INFORMES3].[dbo].[INSTOCK_CARNES_STOCK_X_LOCAL]
FROM (
	SELECT  
		S.ID_DIAANALISIS
		,S.COD_LOCAL
		,S.CLASE
		,S.SUBCLASE
		,S.SKU
		,C.CORTE
		,S.UN_INV_CONTA_HOY
	FROM [INFORMES3].dbo.INSTOCK_CARNES_STOCK_DISPONIBLE_VACUNO_FILTRADA AS S 
	INNER JOIN (
		SELECT 
			SKU
			,CORTE
		FROM [INFORMES3].dbo.[INSTOCK_CARNES_CORTES_SKU_CARNES_COMPLETO]
		WHERE SUB_DEPARTAMENTO='J030101 - CARNES DE VACUNO'
	) AS C 
		ON C.SKU = S.SKU
) AS T
WHERE COD_LOCAL NOT IN (503,212)
GROUP BY 
	COD_LOCAL,
	CORTE

--===PASO 6: CREA TABLA FRACCION_X_LOCAL=============================================

TRUNCATE TABLE [INFORMES3].[dbo].[INSTOCK_CARNES_FRACCION_X_LOCAL]

INSERT INTO [INFORMES3].[dbo].[INSTOCK_CARNES_FRACCION_X_LOCAL] (
	COD_LOCALFISICO
	,CORTE
	,DIA
	,FRACCION
)

SELECT 
	A.COD_LOCALFISICO
	,A.CORTE
	,A.DESC_DIA_SEMANA_ANALISIS AS DIA
	,CASE 
		WHEN B.SUM_VTA_SEMANA_LOCAL = 0 THEN 0 
		ELSE (A.SUM_VTA / B.SUM_VTA_SEMANA_LOCAL) 
	END AS FRACCION
--INTO [INFORMES3].[dbo].[INSTOCK_CARNES_FRACCION_X_LOCAL]
FROM [INFORMES3].dbo.INSTOCK_CARNES_SUMA_VTA_DIARIA_LOCAL AS A 
INNER JOIN [INFORMES3].dbo.INSTOCK_CARNES_SUMA_VTA_SEMANA_LOCAL AS B 
	ON B.CORTE = A.CORTE 
	AND B.COD_LOCALFISICO = A.COD_LOCALFISICO
WHERE A.COD_LOCALFISICO NOT IN (503,212)

--====PASO 7: CREA TABLA FRACCION_VTA_HOY=======================================

TRUNCATE TABLE [INFORMES3].[dbo].[INSTOCK_CARNES_FRACCION_VTA_HOY]

INSERT INTO [INFORMES3].[dbo].[INSTOCK_CARNES_FRACCION_VTA_HOY] (
	COD_LOCALFISICO
	,CORTE
	,DIA
	,FRACCION
)

SELECT
	COD_LOCALFISICO
	,CORTE
	,DIA
	,FRACCION
--INTO [INFORMES3].[dbo].[INSTOCK_CARNES_FRACCION_VTA_HOY]
FROM [INFORMES3].dbo.INSTOCK_CARNES_FRACCION_X_LOCAL
WHERE 
	(
		DIA = (
			SELECT
				CASE DATEPART(DW, (CONVERT(VARCHAR(10), GETDATE(), 112)))
					WHEN '1' THEN 'LUNES' 
					WHEN '2' THEN 'MARTES' 
					WHEN '3' THEN 'MIERCOLES' 
					WHEN '4' THEN 'JUEVES' 
					WHEN '5' THEN 'VIERNES' 
					WHEN '6' THEN 'SABADO' 
					WHEN '7' THEN 'DOMINGO' 
				END AS Expr1
		)
	)
	AND COD_LOCALFISICO NOT IN (503,212)


 --===PASO 8: CREA TABLA VTA_HOY_ESTIMADA_X_LOCAL=====================================

TRUNCATE TABLE [INFORMES3].[dbo].[INSTOCK_CARNES_VTA_HOY_ESTIMADA_X_LOCAL]

INSERT INTO [INFORMES3].[dbo].[INSTOCK_CARNES_VTA_HOY_ESTIMADA_X_LOCAL] (
	P.CORTE
	,P.COD_LOCALFISICO
	,VTA_HOY
)

SELECT
	P.CORTE
	,P.COD_LOCALFISICO
	,P.VTA_PROM_SEM * F.FRACCION AS VTA_HOY
--INTO [INFORMES3].[dbo].[INSTOCK_CARNES_VTA_HOY_ESTIMADA_X_LOCAL]
FROM [INFORMES3].dbo.INSTOCK_CARNES_PROM_VTA_X_LOCAL AS P 
INNER JOIN [INFORMES3].dbo.INSTOCK_CARNES_FRACCION_VTA_HOY AS F 
	ON F.COD_LOCALFISICO = P.COD_LOCALFISICO 
	AND F.CORTE = P.CORTE
WHERE 
	F.CORTE NOT IN (' AUTOSERVICIO') 
	AND P.COD_LOCALFISICO NOT IN (503,212)


--===PASO 9: CREA TABLA INSTOCK_CARNES_RESUMEN_VACUNO_LOCAL===========================
TRUNCATE TABLE [INFORMES3].[dbo].[INSTOCK_CARNES_RESUMEN_VACUNO_LOCAL]

INSERT INTO [INFORMES3].[dbo].[INSTOCK_CARNES_RESUMEN_VACUNO_LOCAL] (
	[CORTE]
	,[COD_LOCALFISICO]
	,[VTA_HOY]
	,STOCK_HOY
) 

SELECT 
	A.[CORTE]
	,A.[COD_LOCALFISICO]
	,A.[VTA_HOY]
	,CASE 
		WHEN (B.STOCK_HOY > A.VTA_HOY) THEN CONVERT(NUMERIC(18,6),A.VTA_HOY)
		WHEN (B.STOCK_HOY <= A.VTA_HOY) AND B.STOCK_HOY>0 THEN CONVERT(NUMERIC(18,6),B.STOCK_HOY)
		WHEN B.STOCK_HOY<0 THEN 0 
	END AS STOCK_HOY
	-- ,CASE 
	-- 	WHEN A.VTA_HOY<= B.STOCK_HOY  THEN 100
  --   WHEN A.VTA_HOY=0 AND B.STOCK_HOY=0 THEN 0
	-- 	WHEN A.VTA_HOY>0 AND (A.VTA_HOY > B.STOCK_HOY) THEN CONVERT(NUMERIC(18,3),(B.STOCK_HOY/A.VTA_HOY)*100) 
	-- END AS INSTOCK
--INTO [INFORMES3].[dbo].[INSTOCK_CARNES_RESUMEN_VACUNO_LOCAL]
FROM [INFORMES3].[dbo].[INSTOCK_CARNES_VTA_HOY_ESTIMADA_X_LOCAL] as A 
JOIN [INFORMES3].dbo.INSTOCK_CARNES_STOCK_X_LOCAL AS B 
	ON B.COD_LOCAL = A.COD_LOCALFISICO 
	AND B.CORTE = A.CORTE
WHERE 
	A.CORTE IN (
		SELECT CORTE FROM [INFORMES3].dbo.INSTOCK_CARNES_CORTES_USADOS_VACUNO
	)
	AND A.COD_LOCALFISICO NOT IN (503,212)


--====PASO 10: CREA TABLA INSTOCK_CARNES_VACUNO_LOCAL==================================

TRUNCATE TABLE [INFORMES3].[dbo].[INSTOCK_CARNES_VACUNO_LOCAL]

INSERT INTO [INFORMES3].[dbo].[INSTOCK_CARNES_VACUNO_LOCAL] (
	[COD_LOCALFISICO]
	,[NOM_LOCAL]
	,STOCK_HOY
	,[VTA_HOY]
	,INSTOCK
	,INSTOCK_NUM
)

SELECT 
	A.[COD_LOCALFISICO]
	,B.Nombre AS NOM_LOCAL
	,CONVERT(NUMERIC(18,6),SUM(A.STOCK_HOY)) AS STOCK_HOY
	,SUM(A.VTA_HOY) AS VTA_HOY
	,CASE 
		WHEN (SUM(A.VTA_HOY)<=SUM(A.STOCK_HOY) AND SUM(A.VTA_HOY)>0) THEN '100%'
		WHEN SUM(A.VTA_HOY)=0 THEN '100%'
		WHEN SUM(A.STOCK_HOY)<0 THEN '0%'
		WHEN SUM(A.VTA_HOY)>SUM(A.STOCK_HOY)
			THEN ''+CONVERT(NVARCHAR(MAX),CONVERT(NUMERIC(18,2),(SUM(A.STOCK_HOY)/SUM(A.VTA_HOY))*100))+'%' 
	END AS INSTOCK
	,CASE 
		WHEN SUM(A.VTA_HOY)<=SUM(A.STOCK_HOY) AND  SUM(A.VTA_HOY)>0 THEN 100
		WHEN SUM(A.VTA_HOY)=0 THEN 100
		WHEN SUM(A.STOCK_HOY)<0 THEN 0
		WHEN SUM(A.VTA_HOY)>SUM(A.STOCK_HOY)
			THEN CONVERT(NUMERIC(18,2),(SUM(A.STOCK_HOY)/SUM(A.VTA_HOY))*100) 
	END AS INSTOCK_NUM
--INTO [INFORMES3].[dbo].[INSTOCK_CARNES_VACUNO_LOCAL]
FROM [INFORMES3].[dbo].[INSTOCK_CARNES_RESUMEN_VACUNO_LOCAL] AS A 
LEFT JOIN [192.168.148.177].[RepNonFood].[dbo].Maestro_Tiendas AS B 
	ON B.Localfisico=A.COD_LOCALFISICO
WHERE COD_LOCALFISICO <> 115 AND A.COD_LOCALFISICO NOT IN (503,212)
GROUP BY 
	A.COD_LOCALFISICO,
	B.Nombre
ORDER BY INSTOCK_NUM ASC


 --====PASO 11: CREA TABLA INSTOCK_CARNES_VACUNO_CORTES==================================

TRUNCATE TABLE [INFORMES3].[dbo].[INSTOCK_CARNES_VACUNO_POR_CORTE]

INSERT INTO [INFORMES3].[dbo].[INSTOCK_CARNES_VACUNO_POR_CORTE] (
	[CORTE]
	,STOCK_HOY
	,[VTA_HOY]
	,INSTOCK
	,INSTOCK_NUM
) 

SELECT 
	[CORTE]
	,CONVERT(NUMERIC(18,6),SUM(STOCK_HOY)) AS STOCK_HOY
	,SUM(VTA_HOY) AS VTA_HOY
	,CASE 
		WHEN SUM(VTA_HOY)<=SUM(STOCK_HOY) AND  SUM(VTA_HOY)>0 THEN '100%'
		WHEN SUM(VTA_HOY)=0 THEN '100%'
		WHEN SUM(STOCK_HOY)<0 THEN '0%'
		WHEN SUM(VTA_HOY)>SUM(STOCK_HOY) 
			THEN ''+CONVERT(NVARCHAR(MAX),CONVERT(NUMERIC(18,2),(SUM(STOCK_HOY)/SUM(VTA_HOY))*100))+'%' 
	END AS INSTOCK
	,CASE 
		WHEN SUM(VTA_HOY)<=SUM(STOCK_HOY) AND  SUM(VTA_HOY)>0 THEN 100
		WHEN SUM(VTA_HOY)=0 THEN 100
		WHEN SUM(STOCK_HOY)<0 THEN 0
		WHEN SUM(VTA_HOY)>SUM(STOCK_HOY) 
			THEN CONVERT(NUMERIC(18,2),(SUM(STOCK_HOY)/SUM(VTA_HOY))*100) 
	END AS INSTOCK_NUM
--INTO [INFORMES3].[dbo].[INSTOCK_CARNES_VACUNO_POR_CORTE]
FROM [INFORMES3].[dbo].[INSTOCK_CARNES_RESUMEN_VACUNO_LOCAL] I
LEFT JOIN [INFORMES3].[dbo].[TIENDAS_ASENTADAS] T
	ON I.COD_LOCALFISICO = T.COD_LOCAL
WHERE
	COD_LOCALFISICO <> 115 
	AND COD_LOCALFISICO NOT IN (503,212) 
	AND COD_LOCAL IS NULL
GROUP BY CORTE
ORDER BY INSTOCK_NUM ASC


 --====PASO 12: CREA TABLA INSTOCK_CARNES_VACUNO_LOCAL_CORTE_1==================================

TRUNCATE TABLE [INFORMES3].[dbo].[INSTOCK_CARNES_VACUNO_LOCAL_CORTE_1]

INSERT INTO [INFORMES3].[dbo].[INSTOCK_CARNES_VACUNO_LOCAL_CORTE_1]
     (COD_LOCALFISICO
     ,[NOM_LOCAL]
     ,[ ABASTERO]
     ,[ ASIENTO]
     ,[ CARNICERO]
     ,[ CHOCLILLO]
     ,[ FILETE]
     ,[ GANSO]
     ,[ HUACHALOMO]
     ,[ LOMO LISO]
     ,[ LOMO VETADO]) 

SELECT 
	COD_LOCALFISICO,
	NOM_LOCAL,
	[ ABASTERO],
	[ ASIENTO],
	[ CARNICERO],
	[ CHOCLILLO],
	[ FILETE],
	[ GANSO],
	[ HUACHALOMO],
	[ LOMO LISO],
	[ LOMO VETADO]
--INTO [INFORMES3].[dbo].[INSTOCK_CARNES_VACUNO_LOCAL_CORTE_1]
FROM (
	SELECT 
		A.[CORTE]
		,A.[COD_LOCALFISICO]
		,B.Nombre AS NOM_LOCAL
		,CASE 
			WHEN SUM(A.VTA_HOY)<=SUM(A.STOCK_HOY) AND  SUM(A.VTA_HOY)>0 THEN '100%'
			WHEN SUM(A.VTA_HOY)=0 THEN '100%'
			WHEN SUM(A.STOCK_HOY)<0 THEN '0%'
			WHEN SUM(A.VTA_HOY)>SUM(A.STOCK_HOY) 
				THEN ''+CONVERT(NVARCHAR(MAX),CONVERT(NUMERIC(18,2),(SUM(A.STOCK_HOY)/SUM(A.VTA_HOY))*100))+'%' 
		END AS INSTOCK
	FROM [INFORMES3].[dbo].[INSTOCK_CARNES_RESUMEN_VACUNO_LOCAL] AS A 
	LEFT JOIN [192.168.148.177].[RepNonFood].[dbo].[Maestro_Tiendas] as B 
		ON B.Localfisico = A.COD_LOCALFISICO
	WHERE 
		COD_LOCALFISICO <> 115 
		AND COD_LOCALFISICO NOT IN (503,212)
	GROUP BY 
		A.CORTE, 
		A.COD_LOCALFISICO, 
		B.Nombre
) AS sourcetable
PIVOT ( 
	MAX([INSTOCK])
	FOR [CORTE] IN (
		[ ABASTERO],
		[ ASIENTO],
		[ CARNICERO],
		[ CHOCLILLO],
		[ FILETE],
		[ GANSO],
		[ HUACHALOMO],
		[ LOMO LISO],
		[ LOMO VETADO]
	)
) AS pivottable 
ORDER BY COD_LOCALFISICO;


 --====PASO 12: CREA TABLA INSTOCK_CARNES_VACUNO_LOCAL_CORTE_2==================================

TRUNCATE TABLE [INFORMES3].[dbo].[INSTOCK_CARNES_VACUNO_LOCAL_CORTE_2]

INSERT INTO [INFORMES3].[dbo].[INSTOCK_CARNES_VACUNO_LOCAL_CORTE_2]
   (COD_LOCALFISICO
   ,[NOM_LOCAL]
   ,[ PLATEADA]
   ,[ POLLO GANSO]
   ,[ POSTA NEGRA]
   ,[ POSTA PALETA/CENTRO PALETA]
   ,[ POSTA ROSADA]
   ,[ GANSO]
   ,[ PUNTA PALETA]
   ,[ PUNTA PICANA]
   ,[ SOBRECOSTILLA]
   ,[ TAPAPECHO])

SELECT
	COD_LOCALFISICO,
	NOM_LOCAL,
	[ PLATEADA],
	[ POLLO GANSO],
	[ POSTA NEGRA],
	[ POSTA PALETA/CENTRO PALETA],
	[ POSTA ROSADA],
	[ GANSO],
	[ PUNTA PALETA],
	[ PUNTA PICANA],
	[ SOBRECOSTILLA],
	[ TAPAPECHO]
--INTO [INFORMES3].[dbo].[INSTOCK_CARNES_VACUNO_LOCAL_CORTE_2]
FROM (
	SELECT 
		A.[CORTE]
		,A.[COD_LOCALFISICO]
		,B.Nombre AS NOM_LOCAL
		,CASE 
			WHEN SUM(A.VTA_HOY)<=SUM(A.STOCK_HOY) AND SUM(A.VTA_HOY)>0 THEN '100%'
			WHEN SUM(A.VTA_HOY)=0 THEN '100%'
			WHEN SUM(A.STOCK_HOY)<0 THEN '0%'
			WHEN SUM(A.VTA_HOY)>SUM(A.STOCK_HOY) 
				THEN ''+CONVERT(NVARCHAR(MAX),CONVERT(NUMERIC(18,2),(SUM(A.STOCK_HOY)/SUM(A.VTA_HOY))*100))+'%' 
		END AS INSTOCK
	FROM [INFORMES3].[dbo].[INSTOCK_CARNES_RESUMEN_VACUNO_LOCAL] AS A 
	LEFT JOIN [192.168.148.177].[RepNonFood].[dbo].[Maestro_Tiendas] AS B 
		ON B.Localfisico = A.COD_LOCALFISICO
	WHERE 
		COD_LOCALFISICO <> 115 
		AND COD_LOCALFISICO NOT IN (503,212)
	GROUP BY A.CORTE, A.COD_LOCALFISICO, B.Nombre
) AS sourcetable 
PIVOT (
	MAX([INSTOCK]) 
	FOR [CORTE] IN (
		[ PLATEADA],
		[ POLLO GANSO],
		[ POSTA NEGRA],
		[ POSTA PALETA/CENTRO PALETA],
		[ POSTA ROSADA],
		[ GANSO],
		[ PUNTA PALETA],
		[ PUNTA PICANA],
		[ SOBRECOSTILLA],
		[ TAPAPECHO]
	)
) AS pivottable 
ORDER BY COD_LOCALFISICO;


--============= PASO 13: CREA TABLA CON INSTOCK CARNES VACUNO TOTAL=================================
TRUNCATE TABLE [INFORMES3].[dbo].[INSTOCK_CARNES_VACUNO_TOTAL]

INSERT INTO [INFORMES3].[dbo].[INSTOCK_CARNES_VACUNO_TOTAL]
	(RESUMEN, INSTOCK)

SELECT
	'INSTOCK_CARNES_VACUNO' AS RESUMEN
	,CASE
		WHEN SUM(A.VTA_HOY)<=SUM(A.STOCK_HOY) AND  SUM(A.VTA_HOY)>0 THEN '100%'
		WHEN SUM(A.VTA_HOY)=0 THEN '100%'
		WHEN SUM(A.STOCK_HOY)<0 THEN '0%'
		WHEN SUM(A.VTA_HOY)>SUM(A.STOCK_HOY)
			THEN ''+CONVERT(NVARCHAR(MAX),CONVERT(NUMERIC(18,2),(SUM(A.STOCK_HOY)/SUM(A.VTA_HOY))*100))+'%'
	END AS INSTOCK
--INTO [INFORMES3].[dbo].[INSTOCK_CARNES_VACUNO_TOTAL]
FROM [INFORMES3].[dbo].[INSTOCK_CARNES_RESUMEN_VACUNO_LOCAL] AS A
LEFT JOIN [192.168.148.177].[RepNonFood].[dbo].[Maestro_Tiendas] AS B
	ON B.Localfisico = A.COD_LOCALFISICO
LEFT JOIN [INFORMES3].[dbo].[TIENDAS_ASENTADAS] T
	ON A.COD_LOCALFISICO = T.COD_LOCAL
WHERE
	A.COD_LOCALFISICO <> 115
	AND T.COD_LOCAL IS NULL
	AND COD_LOCALFISICO NOT LIKE '4%'
--GROUP BY A.CORTE, A.COD_LOCALFISICO, B.Nombre


END
