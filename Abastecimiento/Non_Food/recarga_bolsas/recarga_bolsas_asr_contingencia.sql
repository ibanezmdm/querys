truncate table [repnonfood].[dbo].[recarga_bolsas_asr_contingencia]
insert into [repnonfood].[dbo].[recarga_bolsas_asr_contingencia]

select *
--into [repnonfood].[dbo].[recarga_bolsas_asr_contingencia]
from [INFORMES3].[dbo].[DATA_ASR_CONTINGENCIA]
where IITEM in (select sku from [RepNonFood].[dbo].[recarga_bolsas_skus])