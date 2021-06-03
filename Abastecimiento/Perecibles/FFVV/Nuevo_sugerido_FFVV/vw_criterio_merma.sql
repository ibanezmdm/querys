USE [NUEVO_SUGERIDO_FFVV]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_criterio_merma]
AS

	/*	Author:				Sebastian Esteban Cornejo Berrios
	 *	Description:	entrega las conbinaciones sku/local que tienen criterio de merma igual a 1
	 *	Created_at: 	2021/05/20
	 *	Updated_at:		----/--/--
	 *	Cambios:			
	 *	-> ----/--/--:
	 *	-- ?? SELECT * FROM NUEVO_SUGERIDO_FFVV.dbo.vw_criterio_merma where cod_local = 104
	 */

	with criterio_merma as (
		select 
			Codigo sku,
			Sala cod_local,
			vsa.VTA_SEM_ANTERIOR,
			lm.LIMITE_MERMA,
			m.MERMA_UNIDADES,
			case 
				when isnull(vsa.VTA_SEM_ANTERIOR, 0) > 0 and isnull(abs(m.MERMA_UNIDADES), 0) >= lm.LIMITE_MERMA * isnull(vsa.VTA_SEM_ANTERIOR, 0) 
					then 1 
				else 0 
			end criterio_merma
		from NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_SURTIDO_TIENDA s
		left join NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_VENTA_SEM_ANTERIOR vsa
			on s.Codigo = vsa.SKU
			and s.Sala = vsa.COD_LOCAL
		left join [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_LIMITE_MERMA] lm
			on lm.COD_LOCAL = s.Sala
		left join (
			SELECT 
				[CUSTCOL_7] SKU
				,[COD_LOCALFISICO] COD_LOCAL
				,[ID_SEMANACANALISIS] SEMANA
				,SUM(ISNULL([UNIDADES], 0)) MERMA_UNIDADES
			FROM [SUGERIDO_COMPRA].[dbo].[FFYVV_MERMA]
			GROUP BY [CUSTCOL_7]
				,[COD_LOCALFISICO] 
				,[ID_SEMANACANALISIS]
		) m
			on s.Sala = m.COD_LOCAL
			and s.Codigo = m.SKU
		where Surtido = 1
	)

	select *
	from criterio_merma
	where criterio_merma = 1

GO


