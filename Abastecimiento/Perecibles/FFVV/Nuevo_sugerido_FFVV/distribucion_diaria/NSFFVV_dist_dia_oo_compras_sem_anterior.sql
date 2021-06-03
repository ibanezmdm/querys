
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



/** Calculo compras semana anterior al pedido.
	* Desc:		Suma las cantidades en compras de la semana anterior a la fecha de despacho
	* param:	@id_semana_anterior >> indica la semana anterior a la semana de inicio de pedido
	* param:	@dia_pedido >> filtro para seleccionar las OCs desde el dia en que se corre el pedido en adelante
	* -- ?? select * from [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_oo_compras_sem_anterior]
	* -- !TODO: 
	**/
	--!! truncate table [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_oo_compras_sem_anterior]
	--!! insert into [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_oo_compras_sem_anterior]


	SELECT 
		c.SKU,
		c.SALA cod_local,
		cf.dia_entrega_cd,
		SUM(c.CAJAS * case when ms.CASEPACK = 0 then 1 else isnull(ms.CASEPACK, 1) end) on_order
	--into [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_oo_compras_sem_anterior]
	from [NUEVO_SUGERIDO_FFVV].[dbo].vw_comprado c
	left join RepNonFood.dbo.MAESTRA_SKU ms
		on ms.SKU = c.SKU
	left join [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_CICLO_DIA_FRECUENCIAS] cf
		on cf.cod_local = c.SALA
	where c.id_semana = @id_semana_anterior
		and cf.id_semana = @id_semana_pedido
		and c.fecha_entrega_cd >= @dia_pedido
		-- and cod_local = 104
	group by
		c.SKU,
		cf.dia_entrega_cd,
		c.SALA
