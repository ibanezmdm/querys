
delete from NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_FORECAST_DIARIO
	where semana = (datepart(year, GETDATE() + 8 - datepart(weekday, getdate())) * 100 + datepart(iso_week, GETDATE() + 8 - datepart(weekday, getdate())))
		or semana <= (datepart(year, GETDATE() + 1 - 7 * 4 - datepart(weekday, getdate())) * 100 + datepart(iso_week, GETDATE() + 1 - 7 * 4 - datepart(weekday, getdate())));

	with forecast as (
		SELECT 
			(datepart(year, GETDATE() + 8 - datepart(weekday, getdate())) * 100 + datepart(iso_week, GETDATE() + 8 - datepart(weekday, getdate()))) SEMANA,
			A.COD_LOCAL,
			A.SKU,
			A.SUBCLASE,
			B.DIA_SEMANA,
			B.PERFIL_DIA,
			A.PROM_SEM_ACOTADO * B.PERFIL_DIA FORECAST_DIA
		FROM NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_PROM_SEMANAL_ACOTADO A 
		LEFT JOIN NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_PERFIL_DIARIO B 
			ON B.COD_LOCAL = A.COD_LOCAL 
			AND B.SUBCLASE = A.SUBCLASE
	)

	INSERT INTO NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_FORECAST_DIARIO
	--?? select distinct semana from  NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_FORECAST_DIARIO order by semana desc

	SELECT 
		AA.SEMANA,
		AA.COD_LOCAL,
		AA.SKU,
		AA.SUBCLASE,
		AA.DIA_SEMANA,
		BB.FECHA,
		AA.PERFIL_DIA,
		AA.FORECAST_DIA
	FROM forecast AA 
	LEFT JOIN (
		SELECT 
			SEMANA, 
			FECHA, 
			DATEPART(weekday, FECHA) DIA 
		FROM INFORMES3.dbo.DHW_MES_GC
 	) BB 
		ON BB.SEMANA = AA.SEMANA 
		AND BB.DIA = AA.DIA_SEMANA
	ORDER BY 
		AA.COD_LOCAL,
		AA.SKU,
		AA.SUBCLASE,
		AA.DIA_SEMANA