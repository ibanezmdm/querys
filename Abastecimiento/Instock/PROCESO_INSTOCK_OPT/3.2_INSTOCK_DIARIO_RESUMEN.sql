/* Updated_at: 2019/11/20
 * Updated_by: Sebastian Cornejo
 * Detalle: Filtro de salas cerradas se hace en la vista
 */

-- INSERT INTO [INFORMES3].[dbo].[INSTOCK_DIARIO_RESUMEN] (
-- 	[COMPAÑIA]
-- 	,[TOP500]
-- 	,[TOP2100]
-- 	,[PGC]
-- 	,[PERECIBLES]
-- 	,[MMPP]
-- 	,[IMPORTADOS]
-- 	,[FECHA]
-- )

SELECT 
	[COMPAÑÍA]
	,[TOP500]
	,[TOP2100]
	,[PGC]
	,[PERECIBLES]
	,[MMPP]
	,[IMPORTADOS]
	,[FECHA_ACTUALIZ] AS [FECHA]
FROM [INFORMES3].[dbo].[View_NUEVO_INSTOCK_TABLA_DIA] I
PIVOT (
	SUM(I.[INSTOCK])
	FOR [Cuadro Resumen] IN ([COMPAÑÍA], [TOP500], [TOP2100], [PGC], [PERECIBLES], [MMPP], [IMPORTADOS])
) AS pvtable