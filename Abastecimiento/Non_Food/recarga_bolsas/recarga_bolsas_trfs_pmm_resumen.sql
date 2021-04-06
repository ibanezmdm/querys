truncate table repnonfood.dbo.recarga_bolsas_trfs_pmm_resumen;

with trfs as (
	SELECT 
		sku,
		Tienda_recibo cod_local,
		case 
			when UN_Recibida is not null then UN_Enviada - UN_Recibida
			when UN_Enviada is null and UN_Asignada is null then UN_Requerida
			when UN_Enviada is null then UN_Asignada
			else UN_Requerida
		end trfs
	FROM [RepNonFood].[dbo].[recarga_bolsas_trfs_pmm]
	where sku in (select sku from [RepNonFood].[dbo].[recarga_bolsas_skus])
		--and desc_sku like '%kra%'
		and (ESTADO_LINEA not in ('Recep Completa')
			or f_recepcion = CONVERT(date, getdate())
			or f_envio = CONVERT(date, getdate())
		)
)


insert into repnonfood.dbo.recarga_bolsas_trfs_pmm_resumen

select sku, cod_local, sum(trfs) trfs
from trfs
group BY sku, cod_local