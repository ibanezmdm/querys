SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[View_analisis_pronostico_venta]
AS

	/*	Author:				Sebastian Esteban Cornejo Berrios
	 *	Description:	Consulta que muestra el pronostico con la venta real dentro del periodo del catalogo
	 *	Created_at: 	2020/08/14
	 *	Updated_at:		2020/09/04
	 *	Cambios:
	 *		-> 2020/08/18: Se agrega campo cat_actual, el cual indica si la conbinacion id_catalogo/sku se encuentra vigente en SAP.
	 *		-> 2020/08/24: Se agrega campo vta_un_acido, el cual muestra el valor minimo entre el pronostico_unidades y las un_vta.
	 *		-> 2020/09/04: Se agrega cargas de abastecimiento.
	 *		-> 2020/09/29: Se compara con pronostico modificado en base a errores historicos
	 *	-- TODO: 
	 *	-- ?? SELECT top 10 * FROM PronosticosVentas.[dbo].[View_analisis_pronostico_venta]
	 */

	select 
		pr.*,
		isnull(SUM(vp.un_vta), 0) un_vta,
		isnull(SUM(vp.monto_vta_si), 0) monto_vta_si,
		isnull(SUM(vp.monto_vta), 0) monto_vta,
		isnull(SUM(vp.costo_vta), 0) costo_vta,
		isnull(round(SUM(vp.monto_vta) / case when SUM(vp.un_vta) = 0 then 1 else SUM(vp.un_vta) end, 0), 0) p_promedio,
		case 
			when pr.F_F <= convert(date, getdate() - 1) then 'finalizado'
			when pr.F_I <= convert(date, getdate() - 1) then 'vigente'
			else 'no iniciado'
		end status_catalogo,
		case when P.sku_j is null then 0 else 1 end cat_actual,
		isnull(ac.ionhnd, 0) on_hand,
		isnull(ac.ionord, 0) on_order,
		DATEDIFF(DAY, pr.F_I, pr.F_F) dias_catalogo,
		case 
			when pr.F_I < getdate() then datediff(DAY, pr.F_I, case when getdate() - 1 < pr.F_F then getdate() - 1 else pr.F_F end) 
			else 0
		end dias_transcurridos,
		case 
			when isnull(SUM(vp.un_vta), 0) < pr.[Pronostico Unidades] then isnull(SUM(vp.un_vta), 0)
			else pr.[Pronostico Unidades]
		end vta_un_acida,
		pc.cantidad carga_abastecimiento,
		case 
			when isnull(SUM(vp.un_vta), 0) < pc.cantidad then isnull(SUM(vp.un_vta), 0)
			else pc.cantidad
		end vta_carga_acida
	from PronosticosVentas.[dbo].[PRONOSTICO_RESUMEN_RESPALDO_2] pr
	left join PronosticosVentas.dbo.pronostico_cargas pc
		on pc.id_catalogo = pr.ID_CATALOGO
		and pc.sku = pr.SKU
		and pc.cod_local = pr.COD_LOCAL
	left join PronosticosVentas.dbo.Promociones_SAP_Resumen p
		on p.ID_CATALOGO = pr.ID_CATALOGO
		and p.SKU_J = pr.SKU
	left join PronosticosVentas.dbo.DATA_ASR_CONTINGENCIA ac
		on ac.iitem = pr.sku
		and ac.istor = pr.cod_local
	left join PronosticosVentas.dbo.VentaSkusPromocion vp
		on pr.COD_LOCAL = vp.cod_local
		and pr.SKU = vp.sku
		and pr.F_I <= vp.fecha
		and pr.F_F >= vp.fecha
	where pr.cod_local not in (147, 115, 138)
		and pr.ID_CATALOGO = 3706
	group by 
		pr.COD_LOCAL,
		pr.DEPARTAMENTO,
		pr.DETALLE_PROMOCION,
		pr.ESTADO,
		pr.F_F,
		pr.F_I,
		pr.ID_CATALOGO,
		pr.ID_PROMOCION,
		pr.INDICE_SURTIDO,
		pr.NOM_CATALOGO,
		pr.NOM_PROMOCION,
		pr.NOM_PROVEEDOR,
		pr.NOM_SKU,
		pr.PRECIO_PROMOCIONAL,
		pr.[Pronostico Cajas],
		pr.[Pronostico Unidades],
		pr.SKU,
		pr.[Unidades Efectivas],
		pr.UXC,
		pr.factor,
		pr.bfactor,
		pr.[pronostico modificado],
		p.sku_j,
		ac.ionhnd,
		ac.ionord,
		pc.cantidad
		
GO
