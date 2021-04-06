INSERT into RepNonFood.dbo.[recarga_bolsas_trfs_pmm]

SELECT
	PMM.TRF_NUMBER,
	PMM.Tienda_origen,
	PMM.Tienda_recibo,
	PMM.sku,
	PMM.DESC_SKU,
	PMM.PROVEEDOR,
	PMM.f_ingreso,
	PMM.f_aprobacion,
	PMM.f_envio,
	PMM.f_recepcion,
	PMM.ESTADO_TRF,
	PMM.ESTADO_LINEA,
	PMM.CJ,
	convert(float, PMM.Q_Requerida) CJ_Requerida,
	convert(float, PMM.Q_Asignada) CJ_Asignada,
	convert(float, PMM.Q_Enviada) CJ_Enviada,
	convert(float, PMM.Q_Recibida) CJ_Recibida,
	convert(float, PMM.kg_Requerida) UN_Requerida,
	convert(float, PMM.kg_Asignada) UN_Asignada,
	convert(float, PMM.kg_Enviada) UN_Enviada,
	convert(float, PMM.kg_Recibida) UN_Recibida
FROM OPENQUERY(PMM, '
	SELECT  
		th.TRF_NUMBER,
		lo2.ORG_LVL_NUMBER Tienda_origen,
		lo.ORG_LVL_NUMBER Tienda_recibo,
		-- lo.ORG_NAME_FULL Nombre_tienda,
		-- jq.prd_lvl_number6 division,
		pr.PRD_LVL_NUMBER sku,
		pr.PRD_NAME_FULL DESC_SKU,
		jq.VENDOR_NAME PROVEEDOR,
		-- pr.PRD_NAME_FULL descripcion,
		to_char(th.TRF_ENTRY_DATE, ''YYYY-MM-DD'') f_ingreso,
		to_char(th.trf_aprov_date, ''YYYY-MM-DD'') f_aprobacion,
		to_char(th.trf_ship_date, ''YYYY-MM-DD'') f_envio,
		to_char(th.trf_rec_date, ''YYYY-MM-DD'') f_recepcion,
		stt.TRF_STS_DESC ESTADO_TRF,
		stl.TRF_STS_DESC ESTADO_LINEA,
		jq.NUNI_TRF CJ,
		td.TRF_QTY_ALLOC Q_solicitada,
		To_number(td.QTY_REQ_INNERS) Q_Requerida,
		To_number(td.QTY_ALLOC_INNERS) Q_Asignada,
		To_number(td.QTY_SHIP_INNERS) Q_Enviada,
		To_number(td.REC_TO_DATE_INNERS) Q_Recibida,    
		To_number(td.TRF_QTY_REQ) kg_Requerida,  
		To_number(td.TRF_IN_CARTON) kg_Asignada,  
		To_number(td.TRF_SHP_CARTON) kg_Enviada,     
		To_number(td.TRF_REC_CTN_TO_DAT) kg_Recibida
	FROM trfhdree th
	LEFT JOIN trfdtlee td 
		ON th.TRF_NUMBER = td.TRF_NUMBER 
		AND th.TRF_SHIP_LOC = td.TRF_SHP_LOC
	LEFT JOIN trfstscd stl
		ON td.TRF_STATUS = stl.TRF_STATUS_ID
	LEFT JOIN trfstscd stt
		ON th.TRF_STATUS = stt.TRF_STATUS_ID
	LEFT JOIN prdmstee pr 
		ON td.PRD_LVL_CHILD = pr.PRD_LVL_CHILD
	LEFT JOIN orgmstee lo 
		ON th.TRF_REC_LOC = lo.ORG_LVL_CHILD
	LEFT JOIN orgmstee lo2
		ON th.TRF_SHIP_LOC = lo2.ORG_LVL_CHILD
	LEFT JOIN prdtreep jq 
		ON td.PRD_LVL_CHILD = jq.PRD_LVL_CHILD
	WHERE (JQ.prd_lvl_number2 LIKE ''%J09%'' 
			OR JQ.prd_lvl_number2 LIKE ''%J12%''
		)
		--pr.PRD_LVL_NUMBER in (''20441070'')
		AND (to_char(th.TRF_ENTRY_DATE, ''YYYY-MM-DD'') >= TO_CHAR(sysdate - 1, ''YYYY-MM-DD'')
			OR to_char(th.TRF_APROV_DATE, ''YYYY-MM-DD'') >= TO_CHAR(sysdate - 1, ''YYYY-MM-DD'')
			OR to_char(th.TRF_SHIP_DATE, ''YYYY-MM-DD'') >= TO_CHAR(sysdate - 1, ''YYYY-MM-DD'')
			OR to_char(th.TRF_REC_DATE, ''YYYY-MM-DD'') >= TO_CHAR(sysdate - 1, ''YYYY-MM-DD'')
			OR to_char(th.TRF_PICK_DATE, ''YYYY-MM-DD'') >= TO_CHAR(sysdate - 1, ''YYYY-MM-DD'')
			OR to_char(th.TRF_RLS_PICK_DATE, ''YYYY-MM-DD'') >= TO_CHAR(sysdate - 1, ''YYYY-MM-DD'')
		)
		AND lo2.ORG_LVL_NUMBER = 417
		--AND td.TRF_QTY_ALLOC <> 0
		--AND th.TRF_NUMBER = 14420304
		--AND lo.ORG_LVL_NUMBER IN (147)
		--And (To_number(td.TRF_QTY_ALLOC)
		--	- (CASE WHEN To_number(td.TRF_SHP_CARTON) IS NULL THEN 0 ELSE To_number(td.TRF_SHP_CARTON) end)
		--	- (CASE WHEN To_number(td.TRF_QTY_CNCL) IS NULL THEN 0 ELSE To_number(td.TRF_QTY_CNCL) end)
		--) <> 0
	ORDER BY th.TRF_ENTRY_DATE, th.TRF_NUMBER, th.TRF_STATUS
') PMM