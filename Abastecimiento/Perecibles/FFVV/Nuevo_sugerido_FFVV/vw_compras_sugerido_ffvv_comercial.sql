USE [NUEVO_SUGERIDO_FFVV]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [dbo].[vw_compras_sugerido_ffvv_comercial]
AS

	/*	Author:				Sebastian Esteban Cornejo Berrios
	 *	Description:	Consulta que compara el contenido dentro de la descripcion de un producto contra el contenido de la subclase asociada
	 *	Created_at: 	2021/03/03
	 *	Updated_at: 	----/--/--
	 *	Cambios:			
	 *	-- ?? SELECT * FROM NUEVO_SUGERIDO_FFVV.[dbo].[vw_compras_sugerido_ffvv_comercial]
	 */

	with compras as (
		select
			id_semana,
			sku,
			[sugerido_cajas],
			[1],
			[2],
			[3],
			[4],
			[5],
			[6]
		from (
			select
				id_semana,
				sku,
				sum(compra_cajas) compra_cajas,
				dia_entrega_cd,
				sum(cf.sugerido_cajas) sugerido_cajas
			from [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_compra_final] cf
			group by 		
				id_semana,
				sku,
				dia_entrega_cd
		) cf
		pivot(
			sum(cf.compra_cajas) for dia_entrega_cd in ([1], [2], [3], [4], [5], [6])
		) as pvt
	)

	select 
		id_semana,
		c.sku,
		ms.NOM_SKU,
		ms.subdepartamento,
		ms.clase,
		case when ms.CASEPACK is null or ms.CASEPACK = 0 then 1 else ms.CASEPACK end casepack,
		c.sugerido_cajas sugerido_total,
		[1] lunes,
		[2] martes,
		[3] miercoles,
		[4] jueves,
		[5] viernes,
		[6] sabado
	from compras c
	left join [10.195.254.201].RepNonFood.dbo.MAESTRA_SKU ms
		on ms.SKU = c.sku


GO


