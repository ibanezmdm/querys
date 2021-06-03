
-- declare @dia_pedido date = (select MAX(fecha_hora) from NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_SUGERIDO_CALCULADO_F)
declare @dia_pedido date = '2021-05-20';
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



/** Calculo compras en order clicle.
	* Desc:		Suma las cantidades en compras que se encuentran dentro del periodo de order cicle.
	* param:	@id_semana_pedido >> indica la semana de pedido
	* -- ?? select * from [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_oo_compras_order_cicle]
	**/
	--!! truncate table [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_oo_compras_order_cicle]
	--!! insert into [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_oo_compras_order_cicle]

	SELECT 
		c.SKU,
		c.SALA cod_local,
		cf.dia_entrega_cd,
		SUM(c.CAJAS * case when ms.CASEPACK = 0 then 1 else isnull(ms.CASEPACK, 1) end) on_order_order_cicle
		-- cf.dia_sala,
		-- c.[FECHA EN TIENDA],
		-- c.dia_sala,
		-- c.dia_entrega_cd,
		-- CAJAS
	from NUEVO_SUGERIDO_FFVV.dbo.vw_comprado c
	left join RepNonFood.dbo.MAESTRA_SKU ms
		on ms.SKU = c.SKU
	inner join [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_CICLO_DIA_FRECUENCIAS] cf
		on case when cf.dia_sala < cf.dia_entrega_cd then cf.dia_sala + 7 else cf.dia_sala end <= c.dia_sala
		and case when cf.dia_sala_sig < cf.sig_frecuencia then cf.dia_sala_sig + 7 else cf.dia_sala_sig end > c.dia_sala
		and cf.cod_local = c.SALA
		and cf.id_semana = c.id_semana
	where c.id_semana = @id_semana_pedido
		--and dia_entrega_cd is not null
		and c.SALA = 104
	group by
		c.SKU,
		c.SALA,
		cf.dia_entrega_cd
	-- order by c.sku, cf.dia_entrega_cd
