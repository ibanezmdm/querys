	/* Declaracion tabla temporal para Semanas
	*/
DECLARE @temp_semana AS TABLE (
	N_SEMANA INT,
	SEMANA INT
)


/* Declaracion tabla temporal para Meses
*/
DECLARE @temp_mes AS TABLE (
	N_MES INT,
	MES INT
)


/* Llenado de semanas a consultar
*/
INSERT INTO @temp_semana
SELECT
	ROW_NUMBER() OVER(ORDER BY SEMANA DESC) - 1 N_SEMANA,
	SEMANA
FROM (
	SELECT distinct
		DATEPART(YY, DATEADD(day, 7 - DATEPART(DW, ID_DIAANALISIS), ID_DIAANALISIS)) * 100 + DATEPART(WK, DATEADD(day, 7 - DATEPART(DW, ID_DIAANALISIS), ID_DIAANALISIS)) SEMANA
	FROM [192.168.148.104].[RepNonFood].[dbo].[AA_PRECIO_VTA_2]
	WHERE ID_DIAANALISIS > CONVERT(DATE, GETDATE() - (7 * 9 /* dias de una semana * numero de semanas */ ))
) S


/* Llenado de meses a consultar
*/
INSERT INTO @temp_mes
SELECT
	ROW_NUMBER() OVER(ORDER BY MES DESC) - 1 N_MES,
	MES
FROM (
	SELECT distinct
		DATEPART(YEAR, ID_DIAANALISIS) * 100 + DATEPART(MONTH, ID_DIAANALISIS) MES
	FROM [192.168.148.104].[RepNonFood].[dbo].[AA_PRECIO_VTA_2]
	WHERE ID_DIAANALISIS > CONVERT(DATE, GETDATE() - (30 * 4 /* dias de un mes * numero de meses */ ))
) S


/* Consulta Princial
*/
-- DROP TABLE RepNonFood.dbo.NF_REPORTE_VENTA_MOVIL
TRUNCATE TABLE  RepNonFood.dbo.NF_REPORTE_VENTA_MOVIL
INSERT INTO  RepNonFood.dbo.NF_REPORTE_VENTA_MOVIL
SELECT 
	A.[SKU ID],
	A.[SKU Name],
	M.DIVISION,
	M.DEPARTAMENTO,
	M.SUBDEPARTAMENTO,
	M.CLASE,
	M.MARCA,
	M.PROCEDENCIA,
	M.RUT_PROV,
	M.NOM_PROV,
	SUM([Min Presentation Stock]) AS Minimo, 
	SUM([On Hand]) AS ON_HAND_TIENDA, 
	ISNULL(CD.ON_HAND_CD, 0) ON_HAND_CD,
	SUM([On Hand]) + ISNULL(CD.ON_HAND_CD,0) AS OH_TOTAL,
	ISNULL(vtaS.[vtaS-1], 0) [vtaS-1],
	ISNULL(vtaS.[vtaS-2], 0) [vtaS-2],
	ISNULL(vtaS.[vtaS-3], 0) [vtaS-3],
	ISNULL(vtaS.[vtaS-4], 0) [vtaS-4],
	ISNULL(vtaS.[vtaS-5], 0) [vtaS-5],
	ISNULL(vtaS.[vtaS-6], 0) [vtaS-6],
	ISNULL(vtaS.[vtaS-7], 0) [vtaS-7],
	ISNULL(vtaS.[vtaS-8], 0) [vtaS-8],
	ISNULL(vtaM.[vtaM-1], 0) [vtaM-1],
	ISNULL(vtaM.[vtaM-2], 0) [vtaM-2],
	ISNULL(vtaM.[vtaM-3], 0) [vtaM-3]
-- INTO  RepNonFood.dbo.NF_REPORTE_VENTA_MOVIL
FROM INSTOCK_OPT.dbo.INSTOCK_MIN_PRE A

LEFT JOIN RepNonFood.dbo.MAESTRA_SKU M
	ON A.[SKU ID] = M.SKU

-- STOCK CD
LEFT JOIN (
	SELECT 
		CONVERT(FLOAT, ITEM_NAME) SKU,
		CONVERT(FLOAT, ON_HAND_CD) ON_HAND_CD 
	FROM OPENQUERY (MANHATAN,
		'SELECT 
			IT.ITEM_NAME,
			SUM(I.ON_HAND_QTY) AS On_Hand_CD
		FROM WM_INVENTORY I 
		INNER JOIN LOCN_HDR L 
			ON L.LOCN_ID = I.location_id
		INNER JOIN ITEM_CBO IT 
			ON IT.ITEM_ID = I.ITEM_ID
		WHERE 
			I.ON_HAND_QTY > 0 
			AND L.WHSE =''417''
		GROUP BY IT.ITEM_NAME'
	) S
) AS CD 
	ON CD.SKU = A.[SKU ID]

/* SubConsulta venta por semanas
*/
LEFT JOIN (
	SELECT
		SKU,[vtaS-1],[vtaS-2],[vtaS-3],[vtaS-4],[vtaS-5],[vtaS-6],[vtaS-7],[vtaS-8]
	FROM (
		SELECT
			CASE 
				WHEN T.N_SEMANA = 0 THEN 'SEM_ACTUAL'
				ELSE 'vtaS-' + CONVERT(VARCHAR(2), T.N_SEMANA)
			END TIPO_SEMANA,
			CUSTCOL_7 SKU,
			SUM(WJXBFS3) VENTA_UN
		FROM [192.168.148.104].[RepNonFood].[dbo].[AA_PRECIO_VTA_2] V
		LEFT JOIN @temp_semana T
			ON T.SEMANA = DATEPART(YY, DATEADD(day, 7 - DATEPART(DW, ID_DIAANALISIS), ID_DIAANALISIS)) * 100 + DATEPART(WK, DATEADD(day, 7 - DATEPART(DW, ID_DIAANALISIS), ID_DIAANALISIS))
		WHERE ID_DIAANALISIS > CONVERT(DATE, GETDATE() - (7 * 9))
		GROUP BY 
			CUSTCOL_7,
			T.N_SEMANA,
			T.SEMANA
	) vtaS
	PIVOT (
		SUM(VENTA_UN) FOR TIPO_SEMANA IN (
			[vtaS-1],[vtaS-2],[vtaS-3],[vtaS-4],[vtaS-5],[vtaS-6],[vtaS-7],[vtaS-8]
		)
	) pvt
) vtaS
	ON vtaS.SKU = A.[SKU ID]

/* SubConsulta venta por meses
*/
LEFT JOIN (
	SELECT
		SKU,[vtaM-1],[vtaM-2],[vtaM-3]
	FROM (
		SELECT
			CASE 
				WHEN T.N_MES = 0 THEN 'MES_ACTUAL'
				ELSE 'vtaM-' + CONVERT(VARCHAR(2), T.N_MES)
			END TIPO_SEMANA,
			CUSTCOL_7 SKU,
			SUM(WJXBFS3) VENTA_UN
		FROM [192.168.148.104].[RepNonFood].[dbo].[AA_PRECIO_VTA_2] V
		LEFT JOIN @temp_mes T
			ON T.mes = DATEPART(YEAR, ID_DIAANALISIS) * 100 + DATEPART(MONTH, ID_DIAANALISIS)
		WHERE ID_DIAANALISIS > CONVERT(DATE, GETDATE() - (30 * 4))
		GROUP BY 
			CUSTCOL_7,
			T.N_MES,
			T.MES
	) vtaS
	PIVOT (
		SUM(VENTA_UN) FOR TIPO_SEMANA IN (
			[vtaM-1],[vtaM-2],[vtaM-3]
		)
	) pvt
) vtaM
	ON vtaM.SKU = a.[SKU ID]
WHERE [Store ID] NOT LIKE '4%' AND A.[SKU Group 1] IN ('J08', 'J09', 'J10', 'J11')
GROUP BY 
	A.[SKU ID],
	A.[SKU Name],
	M.DIVISION,
	M.DEPARTAMENTO,
	M.SUBDEPARTAMENTO,
	M.CLASE,
	M.MARCA,
	M.PROCEDENCIA,
	M.RUT_PROV,
	M.NOM_PROV,
	CD.ON_HAND_CD,
	vtaS.[vtaS-1],
	vtaS.[vtaS-2],
	vtaS.[vtaS-3],
	vtaS.[vtaS-4],
	vtaS.[vtaS-5],
	vtaS.[vtaS-6],
	vtaS.[vtaS-7],
	vtaS.[vtaS-8],
	vtaM.[vtaM-1],
	vtaM.[vtaM-2],
	vtaM.[vtaM-3]
