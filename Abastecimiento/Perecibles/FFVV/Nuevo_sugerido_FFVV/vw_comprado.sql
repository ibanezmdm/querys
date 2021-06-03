USE [NUEVO_SUGERIDO_FFVV]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[vw_comprado]
AS

	/*	Author:				Sebastian Esteban Cornejo Berrios
	 *	Description:	Calcula la fecha de entrega en cd para las compras aun no relializadas por sistema pero informadas por el analista
	 *	Created_at: 	2021/05/20
	 *	Updated_at:		----/--/--
	 *	Cambios:			
	 *	-> ----/--/--:
	 *	-- ?? SELECT * FROM NUEVO_SUGERIDO_FFVV.dbo.vw_comprado where sala = 104 and id_semana = 202121
	 */
	
		select
			[SKU]
			,[Producto]
			,[CAJAS]
			,[SALA]
			,[FECHA EN TIENDA]
			,fd.id_semana
			,case when cf.fecha_entrega_cd is not null 
				then cf.fecha_entrega_cd
				else dateadd(day, -case when datediff(day, fd.fecha_entrega_cd, [FECHA EN TIENDA]) >= lr.lead_time then 0 else 1 end, fd.fecha_entrega_cd) 
			end fecha_entrega_cd
			,case when cf.dia_entrega_cd is not null
				then cf.dia_entrega_cd
				else datepart(weekday, dateadd(day, -case when datediff(day, fd.fecha_entrega_cd, [FECHA EN TIENDA]) >= lr.lead_time then 0 else 1 end, fd.fecha_entrega_cd)) 
			end dia_entrega_cd,
			datepart(weekday, [FECHA EN TIENDA]) dia_sala
		from NUEVO_SUGERIDO_FFVV.[dbo].NSFFVV_COMPRADO c
		left join NUEVO_SUGERIDO_FFVV.dbo.vw_lead_time_regular lr
			on lr.cod_local = c.SALA
		left join NUEVO_SUGERIDO_FFVV.dbo.vw_fecha_despacho fd
			on fd.fecha_despacho = c.[FECHA EN TIENDA]
		left join NUEVO_SUGERIDO_FFVV.dbo.vw_ciclo_fecha_frecuencia cf
			on cf.cod_local = c.SALA
			and cf.fecha_sala = c.[FECHA EN TIENDA]
		where cajas > 0
			--and lr.lead_time = 2
			--and cf.fecha_entrega_cd is null
			--and fd.id_semana is null
			--and SKU = 5014015


GO


