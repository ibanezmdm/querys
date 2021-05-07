USE [RepNonFood]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [dbo].[View_maestra_sku_hogar_bazar]
AS

	/*	Author:				Sebastian Esteban Cornejo Berrios
	 *	Description:	Consulta skus de NF 
	 *	Created_at: 	2020/12/29
	 *	Updated_at:		2021/04/16
	 *	Cambios:
	 *		-> 2021/04/16: Se agrega palletizado
	 *	-- ?? SELECT * FROM RepNonFood.[dbo].[View_maestra_sku_hogar_bazar]
	 */

	select 
		ms.[DIVISION]
		,ms.[DEPARTAMENTO]
		,ms.[SUBDEPARTAMENTO]
		,ms.[CLASE]
		,ms.[SUBCLASE]
		,ms.[ID_PROV]
		,ms.[NOM_PROV]
		,ms.[RUT_PROV]
		,ms.[MARCA]
		,ms.[SKU]
		,ms.[NOM_SKU]
		,ms.[FECHA_CREACION]
		,ms.[ESTADO]
		,ms.[EAN]
		,ms.[P_COSTO]
		,ms.[P_VIGENTE]
		,ms.[FECHA_UL_RECEPCION]
		,ms.[PROCEDENCIA]
		,ms.[CASEPACK]
		,ms.[FECHA_ACT_ESTADO]
		,ms.[P_VENTA]
		,pl.palletizado
	from RepNonFood.dbo.MAESTRA_SKU_FULL ms
	left join RepNonFood.dbo.maestra_sku_pallet pl
		on pl.sku = ms.SKU
	where (DIVISION like 'J10%'
		or DIVISION like 'J09%'
	) and ms.ESTADO in ('Activo', 'Inactivo')

GO


