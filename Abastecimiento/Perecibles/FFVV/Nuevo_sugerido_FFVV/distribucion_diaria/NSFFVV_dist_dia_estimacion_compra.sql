
-- declare @dia_pedido date = (select MAX(fecha_hora) from NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_SUGERIDO_CALCULADO_F)
declare @dia_pedido date = '2021-05-05';
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


/** Calculo de cantidad a comprar para cada dia
	* Desc:		Query que calcula la cantidad a comprar para cada dia de la semana.
	* param:	@id_semana_pedido >> indeca la semana de pedido
	* param:	@dia >> indica el primer dia de despacho a cd
	* -- ?? select * from [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_estimacion_compra]
	**/
	--!! truncate table NUEVO_SUGERIDO_FFVV.dbo.[NSFFVV_dist_dia_estimacion_compra];

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
				isnull(fvi.lt_cd, 0) lt_cd_ini

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
			where sf.semana in (@id_semana_pedido)
				and case when sf.corregido is null then sf.SUGERIDO_CAJAS else sf.corregido end is not null
				-- and cf.dia_entrega_cd = 1
		)

		--!! insert into NUEVO_SUGERIDO_FFVV.dbo.[NSFFVV_dist_dia_estimacion_compra]

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
				when oh_teorico_inicial_semana < 0 then 
					case 
						when (ddb.order_cicle + ddb.stock_seguridad + ddb.min_pres) > ((ddb.compra_order_cicle) * ddb.factor_fr + ddb.trf_order_cicle + ddb.oh_teorico_inicial_n)
							then ceiling((ddb.order_cicle + ddb.stock_seguridad  + ddb.min_pres - ((ddb.compra_order_cicle) * ddb.factor_fr + ddb.trf_order_cicle + ddb.oh_teorico_inicial_n)) / casepack) * casepack
						else 0
					end 
				else 
					case 
						when ddb.order_cicle + ddb.stock_seguridad + ddb.min_pres > ((ddb.compra_order_cicle) * ddb.factor_fr + ddb.trf_order_cicle + ddb.oh_teorico_inicial)
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
			-- and sku = 5014038
			-- and cod_local = 104

		set @dia = @dia + 1

	end
