USE [NUEVO_SUGERIDO_FFVV]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Sebastian Cornejo
-- Create date: 2021/02/25
-- Description:	calcula lead-time desde la fecha actual hasta los dias de depacho desde el cd a locales.
-- ?? EXEC [NUEVO_SUGERIDO_FFVV].dbo.[Sp_NSFFVV_CALCULA_VAR_LEAD_TIME_PROV] '2021-05-24'
-- ?? select * from NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_VAR_LEAD_TIME_PROV where cod_local = 104
-- =============================================

ALTER PROCEDURE [dbo].[Sp_NSFFVV_CALCULA_VAR_LEAD_TIME_PROV]
	@dia_pedido as date
AS

BEGIN
	declare @dia_proceso date = getdate();
	-- declare @dia_proceso date = '2021-04-30';
	-- declare @dia_pedido date = getdate() + 8 - datepart(WEEKDAY, getdate())
	-- declare @dia_pedido date = '2021-03-08';
	declare @id_semana_actual int = datepart(year, @dia_proceso) * 100 + datepart(iso_week, @dia_proceso);
	declare @id_semana_final int = datepart(year, @dia_pedido) * 100 + datepart(iso_week, @dia_pedido);

	-- select @dia_proceso, @id_semana_actual, @dia_pedido, @id_semana_final
	truncate table [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_VAR_LEAD_TIME_PROV];

	with lead_time_prov as (
		select
			cd.id_semana,
			cd.cod_local,
			cd2.dia_entrega_cd,
			pd.SUBCLASE,
			sum(pd.PERFIL_DIA) lead_time_prov
			-- pd.PERFIL_DIA,
			-- pd.DIA_SEMANA
		from [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_CICLO_DIA_FRECUENCIAS] cd
		left join [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_PERFIL_DIARIO] pd
			on cd.cod_local  = pd.COD_LOCAL
			and datepart(weekday, @dia_proceso) <= pd.DIA_SEMANA -- dia_inicial
			-- and datepart(weekday, @dia_pedido) >= pd.DIA_SEMANA -- dia_final
		left join [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_CICLO_DIA_FRECUENCIAS] cd2
			on cd2.cod_local = cd.cod_local
			and cd2.id_semana = @id_semana_final
		where cd.id_semana = case when @id_semana_actual < @id_semana_final then @id_semana_actual end
			-- and pd.DIA_SEMANA >= cd.dia_entrega_cd
			and cd.dia_entrega_cd = datepart(weekday, @dia_proceso)
			--and cd.COD_LOCAL = 104
			--and SUBCLASE = 'J0401010101 - NEGROS'
		group by 	
			cd.id_semana,
			cd.cod_local,
			cd.dia_entrega_cd,
			cd2.dia_entrega_cd,
			pd.SUBCLASE

		union 

		select
			cd.id_semana,
			cd.cod_local,
			cd.dia_entrega_cd,
			pd.SUBCLASE,
			sum(pd.PERFIL_DIA) lead_time_cd
			-- pd.PERFIL_DIA,
			-- pd.DIA_SEMANA
		from [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_CICLO_DIA_FRECUENCIAS] cd
		left join [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_PERFIL_DIARIO] pd
			on cd.cod_local  = pd.COD_LOCAL
			-- and datepart(weekday, @dia_proceso) >= pd.DIA_SEMANA -- dia_inicial
			and cd.dia_entrega_cd >= pd.DIA_SEMANA -- dia_final
		where id_semana = @id_semana_final
			-- and cd.dia_entrega_cd = case when @id_semana_actual > @id_semana_final then 1 else datepart(weekday, @dia_proceso) end
			and pd.DIA_SEMANA >= case when @id_semana_actual < @id_semana_final then 1 else datepart(weekday, @dia_proceso) end
		group by 	
			cd.id_semana,
			cd.cod_local,
			cd.dia_entrega_cd,
			pd.SUBCLASE
	)


	insert into [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_VAR_LEAD_TIME_PROV] (
		[id_semana],
		[cod_local],
		[dia_entrega_cd],
		[SUBCLASE],
		[lead_time_prov]
	)

	select *
	from lead_time_prov
	where SUBCLASE is not null
	-- 	and cod_local = 101
	-- 	and SUBCLASE = 'J0401010101 - NEGROS'
	-- ORDER by dia_entrega_cd

END