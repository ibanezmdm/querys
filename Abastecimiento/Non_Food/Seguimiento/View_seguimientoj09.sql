SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[View_seguimientoj09]
AS

	/*	Author:				Sebastian Esteban Cornejo Berrios
	 *	Description:	Consulta que muestra el inventario de las 2 ultimas semanas y el promedio de venta de las 4 ultimas semanas de productos inactivos y descontinuados de J09
	 *	Created_at: 	2020/09/02
	 *	Updated_at:		2021/05/18
	 *	Cambios:
	 *		-> 2021/05/18: se asigna valor 1 a campo mayor_a_cero cunado el local de origes es 115.
	 *	-- TODO: 
	 *	-- ?? SELECT * FROM RepNonFood.[dbo].[View_seguimientoj09] where cod_local = 101 and sku = 3023049
	 */

	select 
		ms.*, 
		oh.COD_LOCAL,
		ml.NOM_LOCAL,
		oh.FECHA, 
		oh.COSTO_INV_CONT_HOY, 
		oh.COSTO_INV_DISP_HOY,
		oh.UN_INV_CONT_HOY,
		oh.UN_INV_DISP_HOY,
		case when cv.cto_vta_X < 800 or cv.cto_vta_X is null then 800 else cv.cto_vta_X end cto_vta_X,
		case 
			when oh.COD_LOCAL = 115 then 1
			when oh.COSTO_INV_CONT_HOY > 0 then 1 
			else 0
		end mayor_a_cero,
		vta.un_vta,
		vta.cto_vta,
		vta.vta,
		datepart(year, dateadd(day, -6, oh.FECHA)) * 100 + datepart(iso_week, dateadd(day, -6, oh.FECHA)) semana
	from RepNonFood.dbo.MAESTRA_SKU_FULL ms
	inner join RepNonFood.dbo.seguimientoj09_stock_2sem oh
		on oh.sku = ms.sku
	left join RepNonFood.dbo.seguimientoj09_cto_vta_X cv
		on cv.sku = oh.sku
		and cv.cod_local = oh.cod_local
	left join INFORMES3.dbo.MAESTRA_LOCALES_OFICIAL ml
		on ml.COD_LOCAL = oh.COD_LOCAL
	left join [RepNonFood].[dbo].RepNF_seguimientoj09_vta vta
		on vta.sku = ms.SKU
		and vta.COD_LOCAL = oh.COD_LOCAL
		and vta.SEMANA = datepart(year, dateadd(day, -6, oh.FECHA)) * 100 + datepart(iso_week, dateadd(day, -6, oh.FECHA))
	where ms.DIVISION like 'J09%'
		and ESTADO in ('Inactivo', 'Descontinuado')
		and oh.COSTO_INV_CONT_HOY <> 0

GO