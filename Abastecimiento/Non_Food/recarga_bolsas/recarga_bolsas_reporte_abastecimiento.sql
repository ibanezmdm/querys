truncate table [repnonfood].[dbo].[recarga_bolsas_reporte_abastecimiento]
insert into [repnonfood].[dbo].[recarga_bolsas_reporte_abastecimiento]

select *
from [10.195.254.180].[DATOS_MAESTROS].[dbo].[REPORTE_ABASTECIMIENTO]
where sku in (select sku from [RepNonFood].[dbo].[recarga_bolsas_skus])