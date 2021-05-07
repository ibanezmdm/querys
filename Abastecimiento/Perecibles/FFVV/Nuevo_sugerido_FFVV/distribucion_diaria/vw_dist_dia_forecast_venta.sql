SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [dbo].[vw_dist_dia_forecast_venta]
AS

	/*	Author:				Sebastian Esteban Cornejo Berrios
	 *	Description:	Agrupa todos los tipos de transferencias en formato para utilizar en tabla de forecast
	 *	Created_at: 	2021/03/08
	 *	Updated_at:		----/--/--
	 *	Cambios:			
	 *	-- ?? SELECT * FROM [NUEVO_SUGERIDO_FFVV].[dbo].[vw_dist_dia_forecast_venta]
	 */

	with forecast as (

		select *, 'lt_cd' tipo
		from NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_dist_dia_lt_cd
		union 
		select *, 'lt_prov'
		from NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_dist_dia_lt_proveedor
		union 
		select *, 'order_cicle'
		from NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_dist_dia_order_cicle
		union 
		select *, 'stock_seguridad'
		from NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_dist_dia_stock_seguridad
	)

	select 
		[local] cod_local,
		sku,
		SUBCLASE,
		dia_entrega_cd,
		isnull(lt_cd, 0) lt_cd,
		isnull(lt_prov, 0) lt_prov,
		isnull(order_cicle, 0) order_cicle,
		isnull(stock_seguridad, 0) stock_seguridad
	from forecast
	pivot (
		sum(vta_lt_cd) for tipo in ([lt_cd], [lt_prov], [order_cicle], [stock_seguridad])
	) as pvt

GO
