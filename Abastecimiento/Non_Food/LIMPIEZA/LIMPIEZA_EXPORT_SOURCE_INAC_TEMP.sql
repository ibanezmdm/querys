/*--	Formato de Archivo: CSV
 *--	Primera Fila: 2
 *--	Separado por: ';'
 */

TRUNCATE TABLE RepNonFood.dbo.LIMPIEZA_EXPORT_SOURCE_INAC_TEMP

BULK INSERT RepNonFood.dbo.LIMPIEZA_EXPORT_SOURCE_INAC_TEMP
FROM 'C:\Instock_Quiebre\CESAR_ESTAY\REPORTE_LIMPIEZA\source_inac.csv'
WITH (
	FIRSTROW = 2,
	ROWTERMINATOR = '\n',
	FIELDTERMINATOR = ';'
)