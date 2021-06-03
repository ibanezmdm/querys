
-- declare @dia_pedido date = (select MAX(fecha_hora) from NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_SUGERIDO_CALCULADO_F)
declare @dia_pedido date = getdate();
-- declare @dia_pedido date = '2021-04-30';
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



/** Calculo venta estimada lead time proveedor.
	* Desc:		Cantidad de venta desde hoy hasta la proxima llegada del proveedor al CD
	* param:	@id_semana_anterior >> indica la semana anterior al pedido
	* param:	@id_semana_pedido >> indeca la semana de pedido
	* -- ?? select * from [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_lt_proveedor]
	**/
	truncate table [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_lt_proveedor]
	insert into [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_lt_proveedor]

	SELECT
		sf.local,
		sf.sku,
		ms.SUBCLASE,
		lt.dia_entrega_cd,
		-- id_semana,
		--sf.[Fcst Semanal] fcst_semanal,
		round(sum(lt.lead_time_prov * sf.[Fcst Semanal]), 0) vta_lt_prov
	FROM [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_SUGERIDO_CALCULADO_F] sf
	left join RepNonFood.dbo.MAESTRA_SKU ms
		on ms.SKU = sf.sku
	left join NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_VAR_LEAD_TIME_PROV lt
		on lt.id_semana = sf.semana
		and lt.cod_local = sf.local
		--and lt.dia_entrega_cd = 1
		and lt.SUBCLASE = ms.SUBCLASE
	where id_semana in (@id_semana_anterior, @id_semana_pedido)
		and dia_entrega_cd is not null
		--and dia_entrega_cd = 1
		-- and cod_local = 104
	group by
		sf.local,
		sf.sku,
		ms.SUBCLASE,
		lt.dia_entrega_cd
		-- id_semana



/** Calculo venta estimada lead time del cd.
	* Desc:		Cantidad de venta desde que llega la mercaderia al cd hasta el dia de llegada al local
	* param:	@id_semana_pedido >> indeca la semana de pedido
	* -- ?? select * from [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_lt_cd]
	**/
	truncate table [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_lt_cd]
	insert into [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_lt_cd]

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



/** Calculo venta estimada  order cicle
	* Desc:		Cantidad de venta desde que llega la mercaderia a la tienda hasta la siguiente frecuencia.
	* param:	@id_semana_pedido >> indeca la semana de pedido
	* -- ?? select * from [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_order_cicle]
	**/
	truncate table [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_order_cicle]
	insert into [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_order_cicle]

	SELECT
		sf.local,
		sf.sku,
		ms.SUBCLASE,
		oc.dia_entrega_cd,
		--id_semana,
		--sf.[Fcst Semanal] fcst_semanal,
		round(sum(oc.order_cicle * sf.[Fcst Semanal]), 0) vta_lt_cd
	FROM [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_SUGERIDO_CALCULADO_F] sf
	left join RepNonFood.dbo.MAESTRA_SKU ms
		on ms.SKU = sf.sku
	left join NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_VAR_ORDER_CICLE_DIARIO oc
		on oc.id_semana = sf.semana
		and oc.cod_local = sf.local
		--and oc.dia_entrega_cd = 1
		and oc.SUBCLASE = ms.SUBCLASE
	where id_semana in (@id_semana_pedido)
		and dia_entrega_cd is not null
		--and dia_entrega_cd = 1
		--and cod_local = 104
	group by
		sf.local,
		sf.sku,
		ms.SUBCLASE,
		oc.dia_entrega_cd



/** Calculo venta estimada stock de seguridad
	* Desc:		Cantidad de venta desde la siguiente frecuencia hasta la cantidad de dias de stock de seguridad
	* param:	@id_semana_pedido >> indeca la semana de pedido
	* -- ?? select * from [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_stock_seguridad]
	**/
	truncate table [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_stock_seguridad]
	insert into [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_stock_seguridad]

	SELECT
		sf.local,
		sf.sku,
		ms.SUBCLASE,
		oc.dia_entrega_cd,
		--id_semana,
		--sf.[Fcst Semanal] fcst_semanal,
		round(sum(oc.stock_seguridad * sf.[Fcst Semanal]), 0) vta_lt_cd
	FROM [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_SUGERIDO_CALCULADO_F] sf
	left join RepNonFood.dbo.MAESTRA_SKU ms
		on ms.SKU = sf.sku
	left join NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_VAR_STOCK_SEGURIDAD_DIARIO oc
		on oc.id_semana = sf.semana
		and oc.cod_local = sf.local
		--and oc.dia_entrega_cd = 1
		and oc.SUBCLASE = ms.SUBCLASE
	where id_semana in (@id_semana_pedido)
		and dia_entrega_cd is not null
		--and dia_entrega_cd = 1
		--and cod_local = 104
	group by
		sf.local,
		sf.sku,
		ms.SUBCLASE,
		oc.dia_entrega_cd



/** Calculo on order semana anterior al pedido.
	* Desc:		Suma las cantidades compradas en ordenes de compra pre-distribuidas y estado on order de la semana anterior a la fecha de despacho
	* param:	@id_semana_anterior >> indica la semana anterior a la semana de inicio de pedido
	* param:	@dia_pedido >> filtro para seleccionar las OCs desde el dia en que se corre el pedido en adelante
	* -- ?? select * from [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_oo_oc_sem_anterior]
	**/
	truncate table [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_oo_oc_sem_anterior]
	insert into [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_oo_oc_sem_anterior]


	SELECT 
		oc.SKU,
		oc.LOCAL_RECIBO cod_local,
		cf.dia_entrega_cd,
		SUM(UNID_SOLIC) on_order
	--into [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_oo_oc_sem_anterior]
	from [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_COMPRA_PREDISTRIBUIDA] oc
	left join [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_CICLO_DIA_FRECUENCIAS] cf
		on cf.cod_local = oc.LOCAL_RECIBO
	where oc.id_semana = @id_semana_anterior
		and cf.id_semana = @id_semana_pedido
		and fecha_esp_recep_sala >= @dia_pedido
		and ESTADO_OC like '%On Order%'
		and LOCAL_ENVIO = 429
	group by
		oc.SKU,
		oc.LOCAL_RECIBO,
		cf.dia_entrega_cd



/** Calculo on order semana de pedido.
	* Desc:		Suma las cantidades compradas en ordenes de compra pre-distribuidas y estado on order de la semana de pedido, incluyendo el lead-time del cd
	* param:	@id_semana_pedido >> indica la semana de pedido
	* -- ?? select * from [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_oo_oc_sem_pedido]
	**/
	truncate table [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_oo_oc_sem_pedido]
	insert into [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_oo_oc_sem_pedido]

	SELECT 
		oc.SKU,
		oc.LOCAL_RECIBO cod_local,
		cf.dia_entrega_cd,
		SUM(UNID_SOLIC) on_order
		--oc.fecha_esp_recep_sala,
		--cf.dia_sala,
		--oc.dia_sala,
		--UNID_SOLIC 
	--into [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_oo_oc_sem_pedido]
	from [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_COMPRA_PREDISTRIBUIDA] oc
	left join [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_CICLO_DIA_FRECUENCIAS] cf
		on case when cf.dia_sala < cf.dia_entrega_cd then cf.dia_sala + 7 else cf.dia_sala end >= oc.dia_sala
		and cf.cod_local = oc.LOCAL_RECIBO
		and cf.id_semana = oc.id_semana
	where oc.id_semana = @id_semana_pedido
		and ESTADO_OC like '%On Order%'
		and LOCAL_ENVIO = 429
	group by
		oc.SKU,
		oc.LOCAL_RECIBO,
		cf.dia_entrega_cd



/** Calculo on order en order clicle.
	* Desc:		Suma las cantidades compradas en ordenes de compra pre-distribuidas y estado on order que se encuentran dentro del order cicle.
	* param:	@id_semana_pedido >> indica la semana de pedido
	* -- ?? select * from [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_oo_oc_order_cicle]
	**/
	truncate table [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_oo_oc_order_cicle]
	insert into [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_oo_oc_order_cicle]

	SELECT 
		oc.SKU,
		oc.LOCAL_RECIBO cod_local,
		cf.dia_entrega_cd,
		SUM(UNID_SOLIC) on_order_order_cicle
		--oc.fecha_esp_recep_sala,
		--cf.dia_sala,
		--oc.dia_sala,
		--UNID_SOLIC 
	--into [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_oo_oc_order_cicle]
	from [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_COMPRA_PREDISTRIBUIDA] oc
	inner join [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_CICLO_DIA_FRECUENCIAS] cf
		on case when cf.dia_sala < cf.dia_entrega_cd then cf.dia_sala + 7 else cf.dia_sala end < oc.dia_sala
		and case when cf.dia_sala_sig < cf.sig_frecuencia then cf.dia_sala_sig + 7 else cf.dia_sala_sig end >= oc.dia_sala
		and cf.cod_local = oc.LOCAL_RECIBO
		and cf.id_semana = oc.id_semana
	where oc.id_semana = @id_semana_pedido
		and ESTADO_OC like '%On Order%'
		and LOCAL_ENVIO = 429
		--and dia_entrega_cd is not null
	group by
		oc.SKU,
		oc.LOCAL_RECIBO,
		cf.dia_entrega_cd


/** Calculo compras semana anterior al pedido.
	* Desc:		Suma las cantidades en compras de la semana anterior a la fecha de despacho
	* param:	@id_semana_anterior >> indica la semana anterior a la semana de inicio de pedido
	* param:	@dia_pedido >> filtro para seleccionar las OCs desde el dia en que se corre el pedido en adelante
	* -- ?? select * from [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_oo_compras_sem_anterior]
	* -- !TODO: 
	**/
	truncate table [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_oo_compras_sem_anterior]
	insert into [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_oo_compras_sem_anterior]


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


/** Calculo compras semana de pedido.
	* Desc:		Suma las cantidades en compras de la semana de pedido, incluyendo el lead-time del cd
	* param:	@id_semana_pedido >> indica la semana de pedido
	* -- ?? select * from [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_oo_compras_sem_pedido]
	**/
	truncate table [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_oo_compras_sem_pedido]
	insert into [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_oo_compras_sem_pedido]

	SELECT 
		c.SKU,
		c.SALA cod_local,
		cf.dia_entrega_cd,
		SUM(c.CAJAS * case when ms.CASEPACK = 0 then 1 else isnull(ms.CASEPACK, 1) end) on_order
		--c.fecha_esp_recep_sala,
		--cf.dia_sala,
		--c.dia_sala,
		--UNID_SOLIC 
	from [NUEVO_SUGERIDO_FFVV].[dbo].[vw_comprado] c
	left join RepNonFood.dbo.MAESTRA_SKU ms
		on ms.SKU = c.SKU
	left join [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_CICLO_DIA_FRECUENCIAS] cf
		on case when cf.dia_sala < cf.dia_entrega_cd then cf.dia_sala + 7 else cf.dia_sala end > c.dia_sala
		and cf.cod_local = c.SALA
		and cf.id_semana = c.id_semana
	where c.id_semana = @id_semana_pedido
	group by
		c.SKU,
		c.SALA,
		cf.dia_entrega_cd


/** Calculo compras en order clicle.
	* Desc:		Suma las cantidades en compras que se encuentran dentro del periodo de order cicle.
	* param:	@id_semana_pedido >> indica la semana de pedido
	* -- ?? select * from [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_oo_compras_order_cicle]
	**/
	truncate table [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_oo_compras_order_cicle]
	insert into [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_oo_compras_order_cicle]

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


/** Calculo on order por trf de la semana anterior al pedido.
	* Desc:		Suma las cantidades compradas en trfs de la semana anterior al pedido, incluyendo el lead-time del cd
	* param:	@id_semana_pedido >> indica la semana de pedido
	* param:	@dia_pedido >> el dia del que se tomaran las trfs
	* -- ?? select * from [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_oo_trf_sem_anterior]
	**/
	truncate table [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_oo_trf_sem_anterior];

	with trfs as (
		select 
			sku,
			cod_local,
			cantidad on_order,
			dia_entrega_cd,
			id_semana
		from [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_trfs]
		where id_semana = @id_semana_anterior
			and fecha_sala >= @dia_pedido
	)


	--select * from trfs

	insert into [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_oo_trf_sem_anterior]

	SELECT 
		trfs.SKU,
		trfs.cod_local cod_local,
		cf.dia_entrega_cd,
		SUM(trfs.on_order) on_order_trf
	from trfs
	left join [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_CICLO_DIA_FRECUENCIAS] cf
		on  cf.cod_local = trfs.cod_local
		and cf.id_semana = @id_semana_pedido
	-- where trfs.cod_local = 104
	group by
		trfs.SKU,
		trfs.cod_local,
		cf.dia_entrega_cd


/** Calculo on order por trf semana de pedido.
	* Desc:		Suma las cantidades compradas en trfs de la semana de pedido, incluyendo el lead-time del cd
	* param:	@id_semana_pedido >> indica la semana de pedido
	* -- ?? select * from [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_oo_trf_sem_pedido]
	**/
	truncate table [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_oo_trf_sem_pedido];

	with trfs as (
		select 
			sku,
			cod_local,
			cantidad on_order,
			dia_entrega_cd,
			id_semana
		from [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_trfs]
		where id_semana = @id_semana_pedido
	)

	insert into [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_oo_trf_sem_pedido]

	SELECT 
		trfs.SKU,
		trfs.cod_local,
		cf.dia_entrega_cd,
		SUM(trfs.on_order) on_order_trf
	from trfs
	left join [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_CICLO_DIA_FRECUENCIAS] cf
		on trfs.dia_entrega_cd <= cf.dia_entrega_cd
		and cf.cod_local = trfs.cod_local
		and cf.id_semana = trfs.id_semana
	where trfs.id_semana = @id_semana_pedido
	group by
		trfs.SKU,
		trfs.cod_local,
		cf.dia_entrega_cd




/** Calculo on order por trf en order cicle.
	* Desc:		Suma las cantidades compradas en trfs que se encuentren dentro del order cicle.
	* param:	@id_semana_pedido >> indica la semana de pedido
	* -- ?? select * from [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_oo_trf_order_cicle]
	**/
	truncate table [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_oo_trf_order_cicle];

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

	insert into [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_oo_trf_order_cicle]

	SELECT 
		trfs.SKU,
		trfs.cod_local,
		cf.dia_entrega_cd,
		SUM(trfs.on_order) on_order_trf
	from trfs
	inner join [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_CICLO_DIA_FRECUENCIAS] cf
		on case when cf.dia_sala < cf.dia_entrega_cd then cf.dia_sala + 7 else cf.dia_sala end <= trfs.dia_sala
		and case when cf.dia_sala_sig < cf.sig_frecuencia then cf.dia_sala_sig + 7 else cf.dia_sala_sig end > trfs.dia_sala
		and cf.cod_local = trfs.cod_local
		and cf.id_semana = trfs.id_semana
	where trfs.id_semana = @id_semana_pedido
	group by
		trfs.SKU,
		trfs.cod_local,
		cf.dia_entrega_cd



/** Calculo de cantidad a comprar para cada dia
	* Desc:		Query que calcula la cantidad a comprar para cada dia de la semana.
	* param:	@id_semana_pedido >> indeca la semana de pedido
	* param:	@dia >> indica el primer dia de despacho a cd
	* -- ?? select * from [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_estimacion_compra]
	**/
	truncate table NUEVO_SUGERIDO_FFVV.dbo.[NSFFVV_dist_dia_estimacion_compra];

	while @dia <= 6
	begin

		with dist_dia_base as (
			SELECT
				sf.local cod_local,
				sf.sku,
				sf.semana,
				cf.dia_entrega_cd,
				ms.CLASE,
				ms.SUBCLASE,
				sf.casepack,
				sf.[Fillrate Ponderado],
				efr.PFR efecto_fr,
				(1 - (ISNULL(sf.[Fillrate Ponderado], 0) / 100)) * (1 - EFR.PFR) + (ISNULL(sf.[Fillrate Ponderado], 0) / 100) factor_fr,
				case when sf.corregido is null then sf.SUGERIDO_CAJAS else sf.corregido end sugerido_cajas,
				case when oh.UNIDINVDISPOHOY is null or oh.UNIDINVDISPOHOY < 0 then 0 else round(oh.UNIDINVDISPOHOY, 0) end on_hand,
				isnull(tr.on_order_compra, 0) on_order_compra,
				isnull(tr.compra_order_cicle, 0) compra_order_cicle,
				isnull(tr.on_order_trf, 0) on_order_trf,
				isnull(tr.trf_order_cicle, 0) trf_order_cicle,
				isnull(tr.compra, 0) compra,
				isnull(fv.lt_prov, 0) lt_prov,
				isnull(fv.lt_cd, 0) lt_cd,
				isnull(fv.order_cicle, 0) order_cicle,
				isnull(fv.stock_seguridad, 0) stock_seguridad,
				isnull(mp.min, 1) * sf.casepack min_pres,
				isnull(fvi.lt_prov, 0) lt_prov_ini,
				isnull(fvi.lt_cd, 0) lt_cd_ini,
				isnull(cm.criterio_merma, 0) criterio_merma

			FROM [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_SUGERIDO_CALCULADO_F] sf
			left join RepNonFood.dbo.MAESTRA_SKU ms
				on ms.SKU = sf.sku
			LEFT JOIN [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_EFECTO_FILLRATE] EFR 
				ON EFR.SUBCLASE = ms.SUBCLASE
			left join NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_CICLO_DIA_FRECUENCIAS cf
				on cf.id_semana = sf.semana
				and cf.cod_local = sf.local
			left join SUGERIDO_COMPRA.dbo.FFYVV_ONHAND oh
				on oh.COD_LOCALFISICO = sf.local
				and oh.CUSTCOL_7 = sf.sku
			left join NUEVO_SUGERIDO_FFVV.dbo.vw_dist_dia_transito tr
				on tr.cod_local = sf.[local]
				and tr.SKU = sf.sku
				and tr.dia_entrega_cd = cf.dia_entrega_cd
			left join NUEVO_SUGERIDO_FFVV.dbo.vw_dist_dia_forecast_venta fv
				on fv.cod_local = sf.[local]
				and fv.sku = sf.sku
				and fv.dia_entrega_cd = cf.dia_entrega_cd
			left join NUEVO_SUGERIDO_FFVV.dbo.vw_dist_dia_forecast_venta fvi
				on fvi.cod_local = sf.[local]
				and fvi.sku = sf.sku
				and fvi.dia_entrega_cd = 1
			left join [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_MIN_PRES] mp
				ON MP.SKU = sf.SKU
				AND MP.COD_LOCAL = sf.LOCAL
			left join NUEVO_SUGERIDO_FFVV.dbo.vw_criterio_merma cm
				on cm.cod_local = sf.[local]
				and cm.sku = sf.sku
			where sf.semana in (@id_semana_pedido)
				and case when sf.corregido is null then sf.SUGERIDO_CAJAS else sf.corregido end is not null
				-- and cf.dia_entrega_cd = 1
		)

		insert into NUEVO_SUGERIDO_FFVV.dbo.[NSFFVV_dist_dia_estimacion_compra]

		select 
			-- ddb.*,
			ddb.cod_local,
			ddb.sku,
			ddb.dia_entrega_cd,
			-- ddb.oh_teorico_inicial,
			-- ddb.min_pres,
			ddb.semana,
			ddb.sugerido_cajas,
			case 
				-- Si criterio_merma = 1 solo se comprara para mantener stock_seguridad + min_pres
				when criterio_merma = 1 then 
					case 
						-- si el oh_teorico_inicial es menor que 0 entonces mantedremos solo el stock inicial durante todo el proceso
						when oh_teorico_inicial_semana < 0 then 
							case 
								when (ddb.stock_seguridad + ddb.min_pres) > ((ddb.compra_order_cicle) * ddb.factor_fr + ddb.trf_order_cicle + ddb.oh_teorico_inicial_n)
									then ceiling((ddb.stock_seguridad  + ddb.min_pres - ((ddb.compra_order_cicle) * ddb.factor_fr + ddb.trf_order_cicle + ddb.oh_teorico_inicial_n)) / casepack) * casepack
								else 0
							end 
						else 
							case 
								when (ddb.stock_seguridad + ddb.min_pres) > ((ddb.compra_order_cicle) * ddb.factor_fr + ddb.trf_order_cicle + ddb.oh_teorico_inicial)
									then ceiling((ddb.stock_seguridad + ddb.min_pres - ((ddb.compra_order_cicle) * ddb.factor_fr + ddb.trf_order_cicle + ddb.oh_teorico_inicial)) / casepack) * casepack
								else 0 
							end
					end
				when oh_teorico_inicial_semana < 0 then 
					case 
						when (ddb.order_cicle + ddb.stock_seguridad + ddb.min_pres) > ((ddb.compra_order_cicle) * ddb.factor_fr + ddb.trf_order_cicle + ddb.oh_teorico_inicial_n)
							then ceiling((ddb.order_cicle + ddb.stock_seguridad  + ddb.min_pres - ((ddb.compra_order_cicle) * ddb.factor_fr + ddb.trf_order_cicle + ddb.oh_teorico_inicial_n)) / casepack) * casepack
						else 0
					end 
				else 
					case 
						when (ddb.order_cicle + ddb.stock_seguridad + ddb.min_pres) > ((ddb.compra_order_cicle) * ddb.factor_fr + ddb.trf_order_cicle + ddb.oh_teorico_inicial)
							then ceiling((ddb.order_cicle + ddb.stock_seguridad + ddb.min_pres - ((ddb.compra_order_cicle) * ddb.factor_fr + ddb.trf_order_cicle + ddb.oh_teorico_inicial)) / casepack) * casepack
						else 0 
					end
			end compra
		from (
			select 
				*,
				on_hand + (on_order_compra + compra) * factor_fr + on_order_trf - (lt_cd + lt_prov) oh_teorico_inicial,
				compra * factor_fr - (lt_cd + lt_prov) + (lt_cd_ini + lt_prov_ini) oh_teorico_inicial_n,
				on_hand + (on_order_compra) * factor_fr + on_order_trf - (lt_cd_ini + lt_prov_ini) oh_teorico_inicial_semana
			from dist_dia_base
		) ddb
		where dia_entrega_cd = @dia

		set @dia = @dia + 1

	end


/** Calculo de cantidad exacta a comprar en cajas para cada dia
	* Desc:		Query que calcula la cantidad exacta a comprar en cajas para cada dia, tomando en cuenta que se tienen que comprar las mismas cantidades sugeridas o corregidas.
	* param:	@id_semana_pedido >> indeca la semana de pedido
	* param:	@dia >> indica el primer dia de despacho a cd
	* -- ?? select * from [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_compra_final]
	**/

	-- llena la tabla final con las cantidades por dia redondeadas a cajas
	truncate table [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_compra_final]
	insert into [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_compra_final]

	select 
		ec.cod_local,
		ec.SKU,
		case when ms.CASEPACK is null or ms.CASEPACK = 0 then 1 else ms.CASEPACK end casepack,
		ec.dia_entrega_cd,
		ec.id_semana,
		ec.sugerido_cajas,
		ec.compra,
		round(ec.compra / case when ms.CASEPACK is null or ms.CASEPACK = 0 then 1 else ms.CASEPACK end, 0) * case when ms.CASEPACK is null or ms.CASEPACK = 0 then 1 else ms.CASEPACK end compra_unidades,
		round(ec.compra / case when ms.CASEPACK is null or ms.CASEPACK = 0 then 1 else ms.CASEPACK end, 0) compra_cajas
	from NUEVO_SUGERIDO_FFVV.dbo.[NSFFVV_dist_dia_estimacion_compra] ec
	left join RepNonFood.dbo.MAESTRA_SKU ms
		on ms.sku = ec.SKU
	where ec.sugerido_cajas is not null


	-- se llena una tabla con los skus que tienen desviaciones entre las cantidades compradas y sugerido o corregido
	truncate table [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_desviacion_compra]
	insert into [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_desviacion_compra]

	select *
	from (
		select 
			sf.cod_local,
			sf.SKU,
			sf.sugerido_cajas,
			sum(sf.compra_cajas) compra_cajas
		from [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_compra_final] sf
		group by 
			sf.cod_local,
			sf.SKU,
			sf.sugerido_cajas
	) sf
	where sf.compra_cajas <> sf.sugerido_cajas

	-- se cuentan las desviaciones envontradas
	set @desviaciones = (select count(*) from [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_desviacion_compra])


	-- se genera un ciclo while el cual va corrigiendo las cantidades hasta que las cajas a comprar sean iguales a las cajas sugeridas o corregidas (test: tope 50 iteraciones)
	while @desviaciones <> 0 --or @iteracion = 50
	begin

		-- Añade una caja a compras menores al los pedidos
		update sf
		set compra_cajas = sf.compra_cajas + 1
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
				-- and sf.SKU = 5014004
				-- and sf.cod_local = 104
		) filtro
			on sf.cod_local = filtro.cod_local
			and sf.SKU = filtro.SKU
			and sf.dia_entrega_cd = filtro.dia_entrega_cd
		where row_number = 1


		-- Quita una caja a compras mayores al pedido
		update sf
		set compra_cajas = sf.compra_cajas - 1
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
				sf.compra_cajas * casepack - sf.compra_estimada diferencia,
				ROW_NUMBER() over(partition by sf.cod_local, sf.sku order by sf.compra_cajas * casepack - sf.compra_estimada desc) as row_number
			from [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_compra_final] sf
			inner join [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_desviacion_compra] ds
				on ds.cod_local = sf.cod_local
				and ds.SKU = sf.SKU
			where ds.sugerido_cajas < ds.compra_cajas
				and sf.compra_cajas > 0
				-- and sf.SKU = 5014010
				-- and sf.cod_local = 104
		) filtro
			on sf.cod_local = filtro.cod_local
			and sf.SKU = filtro.SKU
			and sf.dia_entrega_cd = filtro.dia_entrega_cd
		where row_number = 1


		-- se vuelve a evaluar la cantidad de desviaciones entre cantidades a comprar y sugeridas o corregidas
		truncate table [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_desviacion_compra]
		insert into [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_desviacion_compra]

		select *
		from (
			select 
				sf.cod_local,
				sf.SKU,
				sf.sugerido_cajas,
				sum(sf.compra_cajas) compra_cajas
			from [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_compra_final] sf
			group by 
				sf.cod_local,
				sf.SKU,
				sf.sugerido_cajas
		) sf
		where sf.compra_cajas <> sf.sugerido_cajas

		-- se vuelve a evaluar cuantas desviaciones tenemos, en caso de tener 0 se termina el ciclo while.
		set @desviaciones = (select count(*) from [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_desviacion_compra])
		set @iteracion = @iteracion + 1

	end