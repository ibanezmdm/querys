
/* Corre en 203 */
truncate table [PronosticosVentas].[dbo].RepNF_seguimientoj09_cto_vta_X
insert into [PronosticosVentas].[dbo].RepNF_seguimientoj09_cto_vta_X


SELECT 
	COD_LOCAL,
	vta.SKU,
	AVG(cto_vta) cto_vta_X
FROM [PronosticosVentas].[dbo].[VTA_CARLOS_REYES_2_RESPALDADA_2_I] vta
inner join PronosticosVentas.dbo.MAESTRA_SKU ms
	on vta.SKU = ms.SKU
where ms.DIVISION like 'J09%'
	and SEMANA in (
	SELECT distinct top 4 semana
	FROM [PronosticosVentas].[dbo].vta_carlos_reyes_2_resumen_semanas
	order by semana desc
)
group by 
	COD_LOCAL,
	vta.SKU