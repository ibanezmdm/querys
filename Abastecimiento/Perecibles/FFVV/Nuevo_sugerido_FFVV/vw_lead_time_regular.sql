USE [NUEVO_SUGERIDO_FFVV]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[vw_lead_time_regular]
AS

	/*	Author:				Sebastian Esteban Cornejo Berrios
	 *	Description:	Entrega el lead time regular que tiene el cd para cada uno de los locales
	 *	Created_at: 	2021/05/20
	 *	Updated_at:		----/--/--
	 *	Cambios:			
	 *	-> ----/--/--:
	 *	-- ?? SELECT * FROM NUEVO_SUGERIDO_FFVV.dbo.vw_lead_time_regular where lead_time > 1
	 */

	
	select distinct
		cod_local,
		max(dia_sala - dia_entrega_cd) lead_time
		-- max(case when dia_entrega_cd < dia_sala then dia_sala - dia_entrega_cd else dia_sala + 7 - dia_entrega_cd end) lead_time
	from [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_CICLO_DIA_FRECUENCIAS]
	--where id_semana = 202118
	--	and cod_local = 104
	group by cod_local

GO


