
/*--	Formato de Archivo: CSV
 *--	Primera Fila: 2
 *--	Separado por: ';'
 */

TRUNCATE TABLE RepNonFood.dbo.LIMPIEZA_EXPORT_SOURCE

BULK INSERT RepNonFood.dbo.LIMPIEZA_EXPORT_SOURCE
FROM 'C:\Instock_Quiebre\CESAR_ESTAY\REPORTE_LIMPIEZA\export_source.csv'
WITH (
	FIRSTROW = 2,
	ROWTERMINATOR = '\n',
	FIELDTERMINATOR = ';'
)