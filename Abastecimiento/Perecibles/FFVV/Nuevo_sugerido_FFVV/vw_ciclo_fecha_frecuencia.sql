
USE [NUEVO_SUGERIDO_FFVV]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_ciclo_fecha_frecuencia]
AS

	/*	Author:				Sebastian Esteban Cornejo Berrios
	 *	Description:	Calcula las fechas exactas para cada dia de despacho a cd
	 *	Created_at: 	2021/05/01
	 *	Updated_at:		----/--/--
	 *	Cambios:			
	 *	-- ?? SELECT * FROM [NUEVO_SUGERIDO_FFVV].[dbo].[vw_ciclo_fecha_frecuencia] where cod_local = 104 and id_semana = 202117
	 */

	select 
		id_semana,
		cod_local,
		dia_entrega_cd,
		fs.FECHA fecha_entrega_cd,
		sig_frecuencia,
		dateadd(day, case when sig_frecuencia < 7 then sig_frecuencia - dia_entrega_cd else sig_frecuencia - dia_entrega_cd + 1 end, fs.FECHA) fecha_sig_frecuencia,
		dia_sala,
		dateadd(day, case when dia_entrega_cd < dia_sala then dia_sala - dia_entrega_cd else dia_sala + 7 - dia_entrega_cd end, fs.FECHA) fecha_sala,
		dia_sala_sig,
		dateadd(day, case when dia_entrega_cd < dia_sala_sig then dia_sala_sig - dia_entrega_cd else dia_sala_sig + 7 - dia_entrega_cd end, fs.FECHA) fecha_sala_sig
	FROM [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_CICLO_DIA_FRECUENCIAS] f
	inner join INFORMES3.dbo.DHW_MES_GC fs
		on f.id_semana = fs.SEMANA
		and f.dia_entrega_cd = datepart(weekday, fs.FECHA)
	--where cod_local = 104
	--	and id_semana = 202118
		--and dia_entrega_cd = 1

GO


