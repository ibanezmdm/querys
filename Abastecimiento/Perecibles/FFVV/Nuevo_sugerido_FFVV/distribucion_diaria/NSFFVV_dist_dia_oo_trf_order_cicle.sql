
-- declare @dia_pedido date = (select MAX(fecha_hora) from NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_SUGERIDO_CALCULADO_F)
declare @dia_pedido date = '2021-04-30';
-- declare @dia_pedido date = getdate();
declare @dia_inicio_compra date = dateadd(day, 8 - datepart(weekday, @dia_pedido), @dia_pedido);
declare @id_semana_pedido int = datepart(year, @dia_inicio_compra) * 100 + datepart(iso_week, @dia_inicio_compra);
declare @id_semana_anterior int = datepart(year, dateadd(day, -7, @dia_inicio_compra)) * 100 + datepart(iso_week, dateadd(day, -7, @dia_inicio_compra));
declare @dia as smallint = datepart(weekday, @dia_inicio_compra);
declare @desviaciones as int;
declare @iteracion as int = 1;
-- select 
-- 	@dia_pedido dia_pedido,
-- 	@dia_inicio_compra dia_inicio_compra,
-- 	@id_semana_pedido id_semana_pedido,
-- 	@id_semana_anterior id_semana_anterior,
-- 	@dia dia,
-- 	@desviaciones desviaciones,
-- 	@iteracion iteracion


/** Calculo on order por trf en order cicle.
	* Desc:		Suma las cantidades compradas en trfs que se encuentren dentro del order cicle.
	* param:	@id_semana_pedido >> indica la semana de pedido
	* -- ?? select * from [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_oo_trf_order_cicle]
	**/
	--!! truncate table [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_oo_trf_order_cicle];

	with trfs as (
		select 
			trf.sku,
			trf.cod_local,
			trf.cantidad on_order,
			trf.dia_entrega_cd,
			trf.id_semana,
			cf.dia_sala
		from [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_trfs] trf
		left join [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_CICLO_DIA_FRECUENCIAS] cf
			on cf.id_semana = trf.id_semana
			and cf.dia_entrega_cd = trf.dia_entrega_cd
			and cf.cod_local = trf.cod_local
		where trf.id_semana = @id_semana_pedido
	)

	--!! insert into [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_oo_trf_order_cicle]

	SELECT 
		trfs.SKU,
		trfs.cod_local,
		cf.dia_entrega_cd,
		SUM(trfs.on_order) on_order_trf
	from trfs
	inner join [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_CICLO_DIA_FRECUENCIAS] cf
		on case when cf.dia_sala < cf.dia_entrega_cd then cf.dia_sala + 7 else cf.dia_sala end < trfs.dia_sala
		and case when cf.dia_sala_sig < cf.sig_frecuencia then cf.dia_sala_sig + 7 else cf.dia_sala_sig end >= trfs.dia_sala
		and cf.cod_local = trfs.cod_local
		and cf.id_semana = trfs.id_semana
	where trfs.id_semana = @id_semana_pedido
	group by
		trfs.SKU,
		trfs.cod_local,
		cf.dia_entrega_cd
