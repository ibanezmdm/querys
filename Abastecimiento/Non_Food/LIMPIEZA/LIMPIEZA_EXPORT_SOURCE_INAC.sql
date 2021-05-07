
TRUNCATE TABLE RepNonFood.dbo.LIMPIEZA_EXPORT_SOURCE_INAC
INSERT INTO RepNonFood.dbo.LIMPIEZA_EXPORT_SOURCE_INAC

SELECT 
	CONVERT(DATE, [Birth Date], 101) [Birth Date]
	,CONVERT(DATE, [Deactivate Until], 101) [Deactivate Until]
	,[DC ID]
	,[Source ID]
	,[View]
	,[Store ID]
	,[Sub Source ID]
	,[Source Name]
	,[Super Source ID]
	,[Number of Active SKUs]
FROM [RepNonFood].[dbo].[LIMPIEZA_EXPORT_SOURCE_INAC_TEMP]