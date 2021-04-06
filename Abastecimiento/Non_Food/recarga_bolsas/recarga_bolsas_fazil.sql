TRUNCATE TABLE [RepNonFood].[dbo].[recarga_bolsas_fazil] 
INSERT INTO [RepNonFood].[dbo].[recarga_bolsas_fazil]


SELECT cod_local, carga
FROM OPENROWSET(
	'Microsoft.ACE.OLEDB.12.0',
	'Excel 12.0 Xml;HDR=YES;Database=C:\Instock_Quiebre\CESAR_ESTAY\BOLSAS\bolsas_skus.xlsx',
	'SELECT * FROM [fazil$]'
)
