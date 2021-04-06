truncate table repnonfood.dbo.recarga_bolsas_promedio_semanal;

with vta as (
	select 
		cod_local,
		case when sku_secundario is not null then sku_principal else sku end sku,
		semana,
		sum(un_vta) un_vta
	from [10.195.254.203].[PronosticosVentas].[dbo].[RepNF_venta_bolsas] v
	left join repnonfood.dbo.recarga_bolsas_skus_principal sp
		on v.sku = sp.sku_secundario
	where cod_local <> 115
	group by 
		cod_local,
		case when sku_secundario is not null then sku_principal else sku end,
		semana
)


insert into repnonfood.dbo.recarga_bolsas_promedio_semanal

select 
	cod_local,
	sku,
	count(*) cta,
	avg(un_vta) prom_un_vta,
	STDEV(un_vta) ds_un_vta
from vta
group by cod_local, sku