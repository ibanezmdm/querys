USE [NUEVO_SUGERIDO_FFVV]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[vw_sug_sem_vta_llave]
AS

	/*	Author:				Sebastian Esteban Cornejo Berrios
	 *	Description:	Resumen de venta con llave por dia.
	 *	Created_at: 	2021/05/20
	 *	Updated_at:		----/--/--
	 *	Cambios:			
	 *	-- ?? SELECT * FROM [NUEVO_SUGERIDO_FFVV].[dbo].[vw_sug_sem_vta_llave]
	 */

	select 
		[cod_localfisico] cod_local
		,convert(date, [id_diaanalisis]) id_diaanalisis
		,[sku]
		,SUM(CONVERT(float, [UNIDADES])) unidades
	from [SUGERIDO_COMPRA].[dbo].[FFVV_VTA_LLAVE]
	GROUP BY 
		[cod_localfisico]
		,convert(date, [id_diaanalisis])
		,[sku]

GO


