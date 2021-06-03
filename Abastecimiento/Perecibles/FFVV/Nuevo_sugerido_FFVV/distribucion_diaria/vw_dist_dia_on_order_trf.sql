
USE [NUEVO_SUGERIDO_FFVV]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER VIEW [dbo].[vw_dist_dia_on_order_trf]
AS

	/*	Author:				Sebastian Esteban Cornejo Berrios
	 *	Description:	Agrupa todos los tipos de transferencias en formato para utilizar en tabla de forecast
	 *	Created_at: 	2021/03/08
	 *	Updated_at:		----/--/--
	 *	Cambios:			
	 *	-- ?? SELECT * FROM [NUEVO_SUGERIDO_FFVV].[dbo].[vw_dist_dia_on_order_trf]
	 */

	with trf as (
		select *
		from NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_dist_dia_oo_trf_sem_pedido oc
		union 
		select *
		from NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_dist_dia_oo_trf_sem_anterior oca
	)

	select 
		trf.cod_local,
		trf.SKU,
		trf.dia_entrega_cd,
		sum(trf.on_order_trf) on_order_trf
	from trf
	group by 
		trf.cod_local,
		trf.SKU,
		trf.dia_entrega_cd

GO


