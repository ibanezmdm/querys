USE [RepNonFood]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[View_compra_nac_stock_mensual]
AS

	/*	Author:				Sebastian Esteban Cornejo Berrios
	 *	Description:	consulta el consto de stock mensual de los ultimos 12 meses
	 *	Created_at: 	2021/01/04
	 *	Updated_at:		----/--/--
	 *	Cambios:
	 *	-- TODO: 
	 *	-- ?? SELECT * FROM RepNonFood.[dbo].[View_compra_nac_stock_mensual]
	 */

	select 
		*,
		convert(int, id_mes / 100) año,
		id_mes % 100 mes
	from RepNonFood.dbo.compra_nac_stock_mensual

GO


