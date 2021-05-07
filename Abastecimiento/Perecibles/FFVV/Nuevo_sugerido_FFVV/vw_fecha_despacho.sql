USE [NUEVO_SUGERIDO_FFVV]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [dbo].[vw_fecha_despacho]
AS

	/*	Author:				Sebastian Esteban Cornejo Berrios
	 *	Description:	Resumen para calcular la fecha de despacho a cd para trfs que estan fuera de las frecuencias cargadas.
	 *	Created_at: 	2021/05/02
	 *	Updated_at:		----/--/--
	 *	Cambios:			
	 *	-> ----/--/--: 
	 *	-- ?? SELECT * FROM NUEVO_SUGERIDO_FFVV.dbo.vw_fecha_despacho
	 */

	
	select 
		id_semana,
		fecha_entrega_cd,
		min(fecha_sala) fecha_despacho
	from nuevo_sugerido_ffvv.dbo.vw_ciclo_fecha_frecuencia
	group by 
		id_semana,
		fecha_entrega_cd

GO


