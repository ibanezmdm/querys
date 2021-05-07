SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[View_NF_RECARGA_BOLSAS]
AS

	-- =============================================
	-- Author:			<Sebastian Cornejo Berrios>
	-- Create at:		<2020/11/16>
	-- Update at:		<2021/05/03>
	-- Description:	Reporte automatico para recargas de bolas
	-- Update:
	-- 	-> 2020/11/24: Se agrega trfs de PMM, se reemplaza la cantidad on order por las trfs cuando el on order de ASR es null
	--	-> 2021/04/05: Se añade stock y transito de skus 20451555, 20451556, 20451557, 20451558 al sku 20406527
	-- 	-> 2021/04/07: Se actualiza calculo de balance
	-- 	-> 2021/05/03: Si el valor de las trfs es nulo se reemplaza por un 0
	-- ?? SELECT * FROM [RepNonFood].[dbo].[View_NF_RECARGA_BOLSAS] where cod_local = 513 order by sku, cod_local 
	-- =============================================

	with base_recarga_bolsas as (
		select
			ra.cod_local,
			ra.nom_local,
			s.sku,
			ra.nom_sku,
			ms.CASEPACK,
			s.camada_plltz * s.estiba_plltz * casepack plltz,
			ra.cod_prov_pmm,
			ra.nom_prov,
			oh.UN_INV_DISP_HOY + isnull(oh_t.on_hand, 0) UN_INV_DISP_HOY,
			case when oh.UN_INV_DISP_HOY < 0 then 0 else oh.UN_INV_DISP_HOY end + isnull(oh_t.on_hand, 0) un_inv_disp_local,
			ac.IONHND on_hand,
			case when ac.IONORD is null then isnull(trf.trfs, 0) else ac.IONORD end + isnull(oh_t.on_order, 0) on_order,
			case when oh.UN_INV_DISP_HOY < 0 then 0 else isnull(oh.UN_INV_DISP_HOY, 0) end + isnull(oh_t.on_hand, 0) + case when ac.IONORD is null then isnull(trf.trfs, 0) else ac.IONORD end + isnull(oh_t.on_order, 0) balance,
			case 
				when s.sku_espejo is not null and le.cod_local is not null then isnull(round(plse.prom_acotado * s.factor_espejo, 0), ceiling(CASEPACK / s.semanas))
				when le.cod_local is not null then isnull(round(ple.prom_acotado, 0), ceiling(CASEPACK / s.semanas))
				when s.sku_espejo is not null then isnull(round(pse.prom_acotado * s.factor_espejo, 0), ceiling(CASEPACK / s.semanas))
				else isnull(round(p.prom_acotado, 0), ceiling(CASEPACK / s.semanas))
			end perfil_vta,
			case when lf.cod_local is not null and s.sku = 20441070 then lf.carga end carga_fazil,
			round(ac.IDEM52, 0) demand,
			ic.UN_INV_DISP_HOY un_inv_disp_cd,
			s.semanas,
			s.camada_plltz,
			s.estiba_plltz
			-- oh_t.on_hand,
			-- oh_t.on_order

		from [RepNonFood].[dbo].[recarga_bolsas_skus] s
		inner join RepNonFood.dbo.MAESTRA_SKU_FULL ms
			on s.sku = ms.sku
		inner join [repnonfood].[dbo].[recarga_bolsas_reporte_abastecimiento] ra
			on s.sku = ra.sku
		left join RepNonFood.dbo.recarga_bolsas_local_espejo le
			on ra.cod_local = le.cod_local
		left join [RepNonFood].[dbo].[recarga_bolsas_fazil] lf
			on ra.cod_local = lf.cod_local
		left join [INFORMES3].[dbo].[CE_INV_CD417_DIA] ic
			on s.sku = ic.SKU
		left join RepNonFood.dbo.recarga_bolsas_trfs_pmm_resumen trf
			on s.sku = trf.sku
			and ra.cod_local = trf.cod_local
		left join INFORMES3.dbo.stock_hoy_cia oh
			on s.sku = oh.sku
			and ra.cod_local = oh.COD_LOCAL
		left join [repnonfood].[dbo].[recarga_bolsas_asr_contingencia] ac
			on s.sku = ac.IITEM
			and ra.cod_local = ac.ISTOR
		left join RepNonFood.dbo.recarga_bolsas_perfil p
			on s.sku = p.sku
			and ra.cod_local = p.cod_local
		left join RepNonFood.dbo.recarga_bolsas_perfil ple
			on s.sku = ple.sku
			and le.cod_local_espejo = ple.cod_local
		left join RepNonFood.dbo.recarga_bolsas_perfil pse
			on s.sku_espejo = pse.sku
			and ra.cod_local = pse.cod_local
		left join RepNonFood.dbo.recarga_bolsas_perfil plse
			on s.sku_espejo = plse.sku
			and le.cod_local_espejo = plse.cod_local
		
		left join (
			select 
				'20406527' as sku,
				ra.COD_LOCAL, 
				isnull(sum(case when oh.UN_INV_DISP_HOY < 0 then 0 else oh.UN_INV_DISP_HOY end), 0) on_hand,
				isnull(sum(case when ac.IONORD is null then trf.trfs else ac.IONORD end), 0) on_order
			from [RepNonFood].[dbo].[recarga_bolsas_skus] s
			inner join [repnonfood].[dbo].[recarga_bolsas_reporte_abastecimiento] ra
				on ra.SKU = s.sku
			left join INFORMES3.dbo.stock_hoy_cia oh
				on s.sku = oh.SKU
				and ra.COD_LOCAL = oh.COD_LOCAL
			left join [repnonfood].[dbo].[recarga_bolsas_asr_contingencia] ac
				on s.sku = ac.IITEM
				and ra.cod_local = ac.ISTOR
			left join RepNonFood.dbo.recarga_bolsas_trfs_pmm_resumen trf
				on s.sku = trf.sku
				and ra.cod_local = trf.cod_local
			where s.sku in (20451555, 20451556, 20451557, 20451558)
			group by ra.COD_LOCAL
		) oh_t
			on oh_t.COD_LOCAL = ra.cod_local
			and convert(int, oh_t.sku) = convert(int, s.sku)
		where ra.cod_local not in (115, 148, 147, 138, 109)
			-- and ra.cod_local = 111
			-- and s.sku = 20441070
	)

	select *,
		perfil_vta * semanas + isnull(carga_fazil, 0) un_plan,
		case 
			when ceiling((perfil_vta * semanas + isnull(carga_fazil, 0) - isnull(balance,0)) / CASEPACK) * CASEPACK < 0 then 0
			when (perfil_vta * semanas + isnull(carga_fazil, 0)) > (camada_plltz * casepack)
				then ceiling((perfil_vta * semanas + isnull(carga_fazil, 0) - isnull(balance,0)) / (camada_plltz * casepack)) * (camada_plltz * casepack) 
			else ceiling((perfil_vta * semanas + isnull(carga_fazil, 0) - isnull(balance,0)) / CASEPACK) * CASEPACK
		end recarga_un,
		case 
			when ceiling((perfil_vta * semanas + isnull(carga_fazil, 0) - isnull(balance,0)) / CASEPACK) < 0 then 0
			when (perfil_vta * semanas + isnull(carga_fazil, 0)) > (camada_plltz * casepack)
				then ceiling((perfil_vta * semanas + isnull(carga_fazil, 0) - isnull(balance,0)) / (camada_plltz * casepack)) * (camada_plltz)
			else ceiling((perfil_vta * semanas + isnull(carga_fazil, 0) - isnull(balance,0)) / CASEPACK)
		end recarga_ctn
	from base_recarga_bolsas
	-- where cod_local <> 109
	-- order by sku, cod_local

GO
