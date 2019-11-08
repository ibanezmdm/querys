-- ** Ejecutar en Servidor [10.195.254.201]

DECLARE @semana NUMERIC(12,0)
	SET DATEFIRST 1;
	SET @semana = (DATEPART(yy, GETDATE())*100) + (DATEPART(wk,GETDATE())-1)

SELECT TOP 1 * FROM [R200].[dbo].[DHW_HT_CHILE_INV_SEM] 
WHERE ID_SEMANA = @semana --Semana anterior a la actual

SELECT TOP 1 * FROM [R200].[dbo].[DHW_HT_CHILE_TRXS_SEM]
WHERE ID_SEMANA = @semana --Semana anterior a la actual


SELECT TOP 1 * FROM [R200].[dbo].[DHW_R200_CHILE_SEM] 
WHERE ID_SEMANA = @semana --Semana anterior a la actual


SELECT TOP 1 * FROM [R200].[dbo].[DHW_MAESTRA_SUBDEP_SEM] 
WHERE ID_SEMANA = @semana --Semana anterior a la actual


SELECT TOP 1 * FROM [R200].[dbo].[DHW_CUOTA_SEMANAL] 
WHERE SEMANA = @semana --Semana anterior a la actual
