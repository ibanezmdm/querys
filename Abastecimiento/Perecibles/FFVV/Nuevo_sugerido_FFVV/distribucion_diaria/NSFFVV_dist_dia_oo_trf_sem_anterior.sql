
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


/** Calculo on order por trf de la semana anterior al pedido.
	* Desc:		Suma las cantidades compradas en trfs de la semana anterior al pedido, incluyendo el lead-time del cd
	* param:	@id_semana_pedido >> indica la semana de pedido
	* -- ?? select * from [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_oo_trf_sem_anterior]
	**/
	--!! truncate table [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_oo_trf_sem_anterior];

	with trfs as (
		select 
			sku,
			cod_local,
			cantidad on_order,
			dia_entrega_cd,
			id_semana
		from [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_trfs]
		where id_semana = @id_semana_anterior
	)

	--!! insert into [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_oo_trf_sem_anterior]

	SELECT 
		trfs.SKU,
		trfs.cod_local cod_local,
		cf.dia_entrega_cd,
		SUM(trfs.on_order) on_order_trf
	from trfs
	left join [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_CICLO_DIA_FRECUENCIAS] cf
		on  cf.cod_local = trfs.cod_local
		and cf.id_semana = @id_semana_pedido
	where trfs.cod_local = 104
	group by
		trfs.SKU,
		trfs.cod_local,
		cf.dia_entrega_cd