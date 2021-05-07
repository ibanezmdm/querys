
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



/** Calculo venta estimada lead time del cd.
	* Desc:		Cantidad de venta desde que llega la mercaderia al cd hasta el dia de llegada al local
	* param:	@id_semana_pedido >> indeca la semana de pedido
	* -- ?? select * from [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_lt_cd]
	**/
	--!! truncate table [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_lt_cd]
	--!! insert into [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_lt_cd]

	SELECT
		sf.local,
		sf.sku,
		ms.SUBCLASE,
		lt.dia_entrega_cd,
		--id_semana,
		--sf.[Fcst Semanal] fcst_semanal,
		round(sum(lt.lead_time_cd * sf.[Fcst Semanal]), 0) vta_lt_cd
	FROM [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_SUGERIDO_CALCULADO_F] sf
	left join RepNonFood.dbo.MAESTRA_SKU ms
		on ms.SKU = sf.sku
	left join NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_VAR_LEAD_TIME_CD_DIARIO lt
		on lt.id_semana = sf.semana
		and lt.cod_local = sf.local
		--and lt.dia_entrega_cd = 1
		and lt.SUBCLASE = ms.SUBCLASE
	where id_semana in (@id_semana_pedido)
		and dia_entrega_cd is not null
		--and dia_entrega_cd = 1
		--and cod_local = 104
	group by
		sf.local,
		sf.sku,
		ms.SUBCLASE,
		lt.dia_entrega_cd
