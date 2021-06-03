USE [NUEVO_SUGERIDO_FFVV]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_surtido_semana_t]
AS

	/*	Author:				Sebastian Esteban Cornejo Berrios
	 *	Description:	Entrega el lead time regular que tiene el cd para cada uno de los locales
	 *	Created_at: 	2021/05/20
	 *	Updated_at:		----/--/--
	 *	Cambios:			
	 *	-> ----/--/--:
	 *	-- ?? SELECT * FROM NUEVO_SUGERIDO_FFVV.dbo.vw_surtido_semana_t 
	 */

	
	SELECT 
		s.Sala cod_local, 
		s.Codigo SKU, 
		sem.SEMANA id_semana
	FROM NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_SURTIDO_TIENDA s
	,(SELECT MAX(SEMANA) SEMANA FROM NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_FORECAST_SEMANA_T) sem
	Where Surtido = 1

GO


