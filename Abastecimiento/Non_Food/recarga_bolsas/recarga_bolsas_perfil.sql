truncate table repnonfood.dbo.recarga_bolsas_perfil;

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


insert into repnonfood.dbo.recarga_bolsas_perfil

select
	v.cod_local,
	v.sku,
	avg(un_vta) prom_acotado
from vta v
left join repnonfood.dbo.recarga_bolsas_promedio_semanal ps
	on v.sku = ps.sku
	and v.cod_local = ps.cod_local
where un_vta <= ps.prom_un_vta + ds_un_vta
	and un_vta >= ps.prom_un_vta - ds_un_vta
	and ps.cta >= 5
group by v.cod_local, v.sku

union

select
	v.cod_local,
	v.sku,
	avg(un_vta) prom_acotado
from vta v
left join repnonfood.dbo.recarga_bolsas_promedio_semanal ps
	on v.sku = ps.sku
	and v.cod_local = ps.cod_local
where ps.cta < 5
group by v.cod_local, v.sku