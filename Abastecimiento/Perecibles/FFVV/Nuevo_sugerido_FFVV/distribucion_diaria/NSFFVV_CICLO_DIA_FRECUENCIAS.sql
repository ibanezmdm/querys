declare @dia_proceso date = getdate() + 8 - datepart(WEEKDAY, getdate());

declare @id_semana int = (
	select distinct id_semana 
	from [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_FRECUENCIAS] 
	where id_semana = datepart(year, @dia_proceso) * 100 + datepart(iso_week, @dia_proceso)
);

declare @id_semana_def int = datepart(year, @dia_proceso) * 100;


-- borra calendario de semana a cargar
delete from NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_CICLO_DIA_FRECUENCIAS
where id_semana = datepart(year, @dia_proceso) * 100 + datepart(ISO_WEEK, @dia_proceso);


-- select @dia_proceso, @id_semana, @id_semana_def

with ciclo_diario_frecuencias as (
	SELECT 
		fi.id_semana,
		fi.cod_local,
		fi.dia_entrega_cd,
		--min(ff.dia_entrega_cd) dia_entrega_cd
		min(ff.dia_entrega_cd + case when fi.dia_entrega_cd > ff.dia_entrega_cd then 6 else 0 end) sig_frecuencia
	FROM [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_FRECUENCIAS] fi
	left join [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_FRECUENCIAS] ff
		on fi.cod_local = ff.cod_local
		and fi.id_semana = ff.id_semana
	where fi.id_semana = case when @id_semana is null then @id_semana_def else @id_semana end
		and fi.dia_entrega_cd < ff.dia_entrega_cd + case when fi.dia_entrega_cd > ff.dia_entrega_cd then 6 else 0 end 
		--and fi.dia_entrega_cd = 1
		--and fi.cod_local = 207
	group by fi.id_semana, fi.dia_entrega_cd, fi.cod_local
)


insert into [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_CICLO_DIA_FRECUENCIAS] (
	[id_semana],
	[cod_local],
	[dia_entrega_cd],
	[sig_frecuencia],
	[dia_sala],
	[dia_sala_sig]
)

-- select * from [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_CICLO_DIA_FRECUENCIAS]

select 
	datepart(year, @dia_proceso) * 100 + datepart(iso_week, @dia_proceso) id_semana,
	fr.cod_local,
	fr.dia_entrega_cd,
	fr.sig_frecuencia,
	fi.dia_sala,
	ff.dia_sala dia_sala_sig
from ciclo_diario_frecuencias fr
left join NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_FRECUENCIAS fi
	on fr.cod_local = fi.cod_local
	and fr.id_semana = fi.id_semana
	and fr.dia_entrega_cd = fi.dia_entrega_cd
left join NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_FRECUENCIAS ff
	on fr.cod_local = ff.cod_local
	and fr.id_semana = ff.id_semana
	and case when fr.sig_frecuencia % 6 = 0 then 6 else fr.sig_frecuencia % 6 end = ff.dia_entrega_cd