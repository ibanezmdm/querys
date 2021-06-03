
TRUNCATE TABLE NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_SUGERIDO_SEMANAL_CALCULADO;

	update NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_BASE_SUGERIDO_SEMANAL
	set CASEPACK = 1
	where CASEPACK = 0 or CASEPACK is null

	INSERT INTO NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_SUGERIDO_SEMANAL_CALCULADO 

	SELECT 
		LOCAL
		,SUBCLASE
		,CASEPACK
		,bs.SKU
		,NOM_SKU
		,OH_INICIAL
		,FORECAST_SEM_ACTUAL
		,FORECAST_PROM_DIA_SEM_T
		,FORECAST_SEM_T
		,MERMA_SEM_ANT
		,VTA_SEM_ANT
		,LIMITE_MERMA
		,CRITERIO_MERMA
		,isnull(t.on_order_compra + t.compra_order_cicle, 0) COMPRAS_SEMANA_ACTUAL
		,FR_PONDERADO
		,EFECTO_FR
		,FACTOR_FR
		,isnull(t.on_order_trf + t.trf_order_cicle, 0) TRANSITO_CD
		,EN_PROMO
		,MIN_PRES_FINAL_UN
		,SS_UN   
		,MIN_PRES_SS
		,OH_INICIAL+TRANSITO_CD+COMPRAS_SEMANA_ACTUAL*FACTOR_FR-FORECAST_SEM_ACTUAL OH_TEORICO_SEM_T
		,ec.compra SUGERIDO_UN
		,CEILING(ec.compra / CASEPACK) SUGERIDO_CAJAS
		,SEMANA
	FROM NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_BASE_SUGERIDO_SEMANAL bs
	left join (
		select 
			ss.cod_local,
			ss.sku,
			id_semana,
			sum(compra) compra
		from nuevo_sugerido_ffvv.dbo.NSFFVV_dist_dia_estimacion_compra_sem ss
		group by 	
			ss.cod_local,
			ss.sku,
			id_semana
	) ec
		on ec.cod_local = bs.[LOCAL]
		and ec.SKU = bs.SKU
		and ec.id_semana = bs.SEMANA
	left join NUEVO_SUGERIDO_FFVV.dbo.vw_dist_dia_transito_sem t
		on t.cod_local = bs.[LOCAL]
		and t.sku = bs.SKU
		and t.dia_entrega_cd = 1
