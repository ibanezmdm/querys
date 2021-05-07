USE [NUEVO_SUGERIDO_FFVV]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [dbo].[vw_lead_time]
AS

	/*	Author:				Sebastian Esteban Cornejo Berrios
	 *	Description:	Consulta que compara el contenido dentro de la descripcion de un producto contra el contenido de la subclase asociada
	 *	Created_at: 	2021/03/03
	 *	Updated_at:		2021/05/01
	 *	Cambios:			
	 *	-> 2021/05/01: Se considera el caso cuando el dia en sala es menor al dia entrega en cd
	 *	-- ?? SELECT * FROM SUGERIDO_COMPRA.dbo.vw_lead_time
	 */

	
	select distinct
		id_semana,
		cod_local,
		--,max(dia_sala - dia_entrega_cd) lead_time
		max(case when dia_entrega_cd < dia_sala then dia_sala - dia_entrega_cd else dia_sala + 7 - dia_entrega_cd end) lead_time
	from [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_CICLO_DIA_FRECUENCIAS]
	--where id_semana = 202118
	--	and cod_local = 104
	group by id_semana, cod_local

GO


