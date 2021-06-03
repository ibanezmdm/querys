USE [NUEVO_SUGERIDO_FFVV]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_sug_sem_vta_promedio_dia]
AS

	/*	Author:				Sebastian Esteban Cornejo Berrios
	 *	Description:	Calcula venta promedio diaria.
	 *	Created_at: 	2021/05/20
	 *	Updated_at:		----/--/--
	 *	Cambios:			
	 *	-- ?? SELECT * FROM [NUEVO_SUGERIDO_FFVV].[dbo].[vw_sug_sem_vta_promedio_dia]
	 */

	with venta_subclase_dia as (
		select
			COD_LOCAL
			,[SUBCLASE]
			,SUM([VTA]) VTA
			,[DIA_SEMANA]
		from NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_VTA_DIA_SEMANA
		--WHERE ESTADO = 'Activo'
		--	AND IND_SURTIDO = 1
		group by 
			COD_LOCAL
			,[SUBCLASE]
			,[DIA_SEMANA]
			,SEMANA
	)

	select 
		COD_LOCAL
		,SUBCLASE
		,AVG(VTA) VTA
		,DIA_SEMANA
	from venta_subclase_dia V
	group by 
		COD_LOCAL
		,SUBCLASE
		,DIA_SEMANA


GO


