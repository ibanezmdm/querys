
TRUNCATE TABLE NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_FILLRATE_SEMANAL_PONDERADO;
	--?? select * from NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_FILLRATE_SEMANAL_PONDERADO

	with numero_semana as (
		select
			SEMANA,
			row_number() over (order by semana desc) n_semana
		from NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_FILLRATE_SEMANAL
		group by semana
	)

	INSERT INTO NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_FILLRATE_SEMANAL_PONDERADO

	select 
		subclase,
		isnull([4], 0) FR_SEM4,
		isnull([3], 0) FR_SEM3,
		isnull([2], 0) FR_SEM2,
		isnull([1], 0) FR_SEM1,
		isnull([1], 0) * 0.4 + isnull([2], 0) * 0.3 + isnull([3], 0) * 0.2 + isnull([4], 0) * 0.1 FR_PONDERADO
	from (
		select 
			subclase,
			FILLRATE,
			n_semana
		from NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_FILLRATE_SEMANAL fs
		inner join numero_semana ns
			on fs.SEMANA = ns.SEMANA
	) f
	pivot (sum(FILLRATE) for n_semana in ([1], [2], [3], [4])) as pvt
	