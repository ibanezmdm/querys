USE [NUEVO_SUGERIDO_FFVV]
GO

/****** Object:  View [dbo].[vw_dist_dia_transito]    Script Date: 22/04/2021 15:55:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [dbo].[vw_dist_dia_transito]
AS

	/*	Author:				Sebastian Esteban Cornejo Berrios
	 *	Description:	Agrupa todos los tipos de transferencias en formato para utilizar en tabla de forecast
	 *	Created_at: 	2021/03/08
	 *	Updated_at:		----/--/--
	 *	Cambios:			
	 *	-- ?? SELECT * FROM [NUEVO_SUGERIDO_FFVV].[dbo].[vw_dist_dia_transito] where cod_local = 104 and sku = 5014004
	 */

	with forecast as (
		select 
			cod_local,
			sku,
			dia_entrega_cd,
			on_order transito,
			'compra_order_cicle' tipo
		from NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_dist_dia_oo_compras_order_cicle
		union 
		select *, 'on_order_compra'
		from NUEVO_SUGERIDO_FFVV.dbo.vw_dist_dia_on_order_compra
		union 
		select *, 'on_order_trf'
		from NUEVO_SUGERIDO_FFVV.dbo.vw_dist_dia_on_order_trf
		union 
		select *, 'trf_order_cicle'
		from NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_dist_dia_oo_trf_order_cicle
		union 
		select 
			ec.cod_local,
			ec.SKU,
			cf.dia_entrega_cd,
			sum(ec.compra) compra,
			'compra' tipo
		from NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_dist_dia_estimacion_compra ec
		left join NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_CICLO_DIA_FRECUENCIAS cf
			on ec.cod_local = cf.cod_local
			and ec.dia_entrega_cd <= cf.dia_entrega_cd
			and ec.id_semana = cf.id_semana
		-- where ec.cod_local = 104 
		-- 	and SKU = 5014038
		group by 
			ec.cod_local,
			ec.SKU,
			cf.dia_entrega_cd
	)

	select 
		cod_local,
		sku,
		dia_entrega_cd,
		isnull(on_order_compra, 0) on_order_compra,
		isnull(on_order_trf, 0) on_order_trf,
		isnull(compra_order_cicle, 0) compra_order_cicle,
		isnull(trf_order_cicle, 0) trf_order_cicle,
		isnull(compra, 0) compra
	from forecast
	pivot (
		sum(transito) for tipo in ([compra_order_cicle], [on_order_compra], [on_order_trf], [trf_order_cicle], [compra])
	) as pvt

GO


