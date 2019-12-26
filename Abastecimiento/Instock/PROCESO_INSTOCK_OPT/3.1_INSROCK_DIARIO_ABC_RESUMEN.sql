/* Updated_at: 2019/11/20
 * Updated_by: Sebastian Cornejo
 * Detalle: Filtro de salas cerradas se hace en la vista
 */


-- INSERT INTO [INFORMES3].[dbo].[INSTOCK_DIARIO_ABC_RESUMEN] (
-- 	[CLASE_A]
-- 	,[CLASE_B]
-- 	,[CLASE_C]
-- 	,[NUEVA_CLASE_A]
-- 	,[NUEVA_CLASE_B]
-- 	,[NUEVA_CLASE_C]
-- 	,[FECHA]
-- )

SELECT 
	0 AS CLASE_A,
	0 AS CLASE_B,
	0 AS CLASE_C,
	[NUEVA CLASE A] AS [NUEVA_CLASE_A],
	[NUEVA CLASE B] AS [NUEVA_CLASE_B],
	[NUEVA CLASE C] AS [NUEVA_CLASE_C],
	FECHA
FROM (
	SELECT INSTOCK,	CONVERT(DATE,FECHA_ACTUALIZ) AS FECHA, [Cuadro Resumen]
	FROM dbo.View_NUEVO_INSTOCK_DIA_NUEVO_ABC
) AS T
PIVOT (
	SUM(T.INSTOCK)
	FOR [Cuadro Resumen] IN ([NUEVA CLASE A], [NUEVA CLASE B], [NUEVA CLASE C])
) AS pvtable

