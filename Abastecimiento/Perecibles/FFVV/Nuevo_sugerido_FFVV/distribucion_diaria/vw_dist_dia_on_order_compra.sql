
USE [NUEVO_SUGERIDO_FFVV]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [dbo].[vw_dist_dia_on_order_compra]
AS

	/*	Author:				Sebastian Esteban Cornejo Berrios
	 *	Description:	Agrupa todos los tipos de ordenes de compra en formato para utilizar en tabla de forecast
	 *	Created_at: 	2021/03/08
	 *	Updated_at:		----/--/--
	 *	Cambios:			
	 *	-- ?? SELECT * FROM [NUEVO_SUGERIDO_FFVV].[dbo].[vw_dist_dia_on_order_compra]
	 */

	with on_order as (

		select *
		from NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_dist_dia_oo_compras_sem_pedido oc
		union 
		select *
		from NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_dist_dia_oo_compras_sem_anterior oca
	)

	select 
		oc.cod_local,
		oc.SKU,
		oc.dia_entrega_cd,
		sum(oc.on_order) on_order
	from on_order oc
	group by 
		oc.cod_local,
		oc.SKU,
		oc.dia_entrega_cd

GO
