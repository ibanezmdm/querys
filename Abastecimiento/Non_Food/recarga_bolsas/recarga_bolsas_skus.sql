TRUNCATE TABLE [RepNonFood].[dbo].[recarga_bolsas_skus] 
INSERT INTO [RepNonFood].[dbo].[recarga_bolsas_skus] 


SELECT sku, sku_espejo, factor_espejo, semanas, estiba_plltz, camada_plltz
FROM OPENROWSET(
	'Microsoft.ACE.OLEDB.12.0',
	'Excel 12.0 Xml;HDR=YES;Database=C:\Instock_Quiebre\CESAR_ESTAY\BOLSAS\bolsas_skus.xlsx',
	'SELECT * FROM [sku$]'
)
