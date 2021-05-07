
-- declare @dia_pedido date = (select MAX(fecha_hora) from NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_SUGERIDO_CALCULADO_F)
declare @dia_pedido date = getdate();
declare @dia_inicio_compra date = dateadd(day, 8 - datepart(weekday, @dia_pedido), @dia_pedido);
declare @id_semana_pedido int = datepart(year, @dia_inicio_compra) * 100 + datepart(iso_week, @dia_inicio_compra);
declare @id_semana_anterior int = datepart(year, dateadd(day, -7, @dia_inicio_compra)) * 100 + datepart(iso_week, dateadd(day, -7, @dia_inicio_compra));
declare @dia as smallint = datepart(weekday, @dia_inicio_compra);
declare @desviaciones as int;
declare @iteracion as int = 1;

set @desviaciones = (select count(*) from [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_desviacion_compra])

-- select @desviaciones

	-- Añade una caja a compras menores al los pedidos
	-- update sf
	-- set compra_cajas = sf.compra_cajas + 1
	select *
	from [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_compra_final] sf
	inner join (
		select 
			sf.cod_local,
			sf.sku,
			sf.dia_entrega_cd,
			sf.compra_cajas,
			ds.sugerido_cajas,
			ds.compra_cajas compra_cajas_total,
			sf.compra_estimada,
			sf.casepack,
			sf.compra_cajas * casepack - sf.compra_estimada difencia,
			ROW_NUMBER() over(partition by sf.cod_local, sf.sku order by sf.compra_cajas * casepack - sf.compra_estimada asc) as row_number
		from [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_compra_final] sf
		inner join [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_desviacion_compra] ds
			on ds.cod_local = sf.cod_local
			and ds.SKU = sf.SKU
		where ds.sugerido_cajas > ds.compra_cajas
			and sf.SKU = 5014038
			and sf.cod_local = 104
	) filtro
		on sf.cod_local = filtro.cod_local
		and sf.SKU = filtro.SKU
		and sf.dia_entrega_cd = filtro.dia_entrega_cd
	where row_number = 1
