
TRUNCATE TABLE NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_COMPRA_PREDISTRIBUIDA;

WITH COMPRA AS (
	select 
		oc.*, 
		case 
			when f.fecha_sala is null then fd.fecha_despacho 
			else f.fecha_sala 
		end fecha_esp_recep_sala,
		case 
			when f.dia_sala is null then datepart(weekday, fd.fecha_despacho)
			else f.dia_sala
		end dia_sala,
		datepart(YEAR, FECHA_ESP_RECEP) * 100 + DATEPART(iso_week, FECHA_ESP_RECEP) id_semana
	from openquery(pmm, '
		SELECT 
			DT.PMG_PO_NUMBER AS OC,
			dmt.dmt_desc as tipo_oc,
			O.ORG_LVL_NUMBER AS LOCAL_ENVIO,
			--O.ORG_NAME_FULL AS NOM_LOCAL_ENVIO,
			L.ORG_LVL_NUMBER AS LOCAL_RECIBO,
			--L.ORG_NAME_FULL AS NOM_LOCAL_RECIBO,
			so.pmg_stat_name AS ESTADO_OC,
			P.PRD_LVL_NUMBER AS SKU,
			--P.PRD_NAME_FULL AS PRODUCTO,
			--p.prd_lvl_number6 as division,
			--ROUND(I.ON_HAND_QTY) AS ON_HAND,
			T.PMG_SELL_QTY AS UNID_SOLIC,
			HD.PMG_EXP_RCT_DATE AS FECHA_ESP_RECEP
			--TO_NUMBER(NVL(T.PMG_PACK_QTY, -1)) AS CAJAS_SOLIC
			--T.PMG_PCT_ALLOC * 100 AS PORCENTAJE
		FROM PMGHDREE HD -- tabla OC    
		left join RPLDMTCD dmt -- tabla tipo oc
			on hd.dmt_code = dmt.dmt_code
		left join PMGSTSCD so -- tabla status oc
			on hd.pmg_stat_code = so.pmg_stat_code
		left join PMGDTLEE DT -- tabla detalle oc
			on DT.PMG_PO_NUMBER = HD.PMG_PO_NUMBER
		left join PMGALLEE T -- TABLA DE UNIDADES PREDISTRIBUIDAS LOCALES
			on DT.PMG_DTL_TECH_KEY = T.PMG_DTL_TECH_KEY
		left join PRDTREEP P
			on P.PRD_LVL_CHILD = T.PRD_LVL_CHILD
		left join ORGMSTEE L
			on L.ORG_LVL_CHILD = T.ORG_LVL_CHILD
		left join ORGMSTEE O
			on O.ORG_LVL_CHILD = DT.ORG_LVL_CHILD
		WHERE to_char(hd.PMG_EXP_RCT_DATE, ''yyyy/mm/dd'') >= to_char(sysdate - 4, ''yyyy/mm/dd'')
			and to_char(hd.PMG_EXP_RCT_DATE, ''yyyy/mm/dd'') <= to_char(sysdate + 13, ''yyyy/mm/dd'')
			--and DT.PMG_PO_NUMBER in (41826827)
			and hd.DMT_CODE = 1
			and p.prd_lvl_number6 like ''%J04%''
			and hd.pmg_stat_code in (4, 5, 6)
	') oc
	left join NUEVO_SUGERIDO_FFVV.dbo.vw_ciclo_fecha_frecuencia f
		on oc.fecha_esp_recep = f.fecha_entrega_cd
		and oc.local_recibo = f.cod_local
	left join NUEVO_SUGERIDO_FFVV.dbo.vw_lead_time lt
		on lt.id_semana = datepart(YEAR, FECHA_ESP_RECEP) * 100 + DATEPART(iso_week, FECHA_ESP_RECEP)
		and lt.cod_local = oc.local_recibo
	left join NUEVO_SUGERIDO_FFVV.dbo.vw_fecha_despacho fd
		on fd.fecha_entrega_cd = oc.fecha_esp_recep
) 


INSERT into NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_COMPRA_PREDISTRIBUIDA (
	[OC]
	,[TIPO_OC]
	,[LOCAL_ENVIO]
	,[LOCAL_RECIBO]
	,[ESTADO_OC]
	,[SKU]
	,[UNID_SOLIC]
	,[fecha_esp_recep_cd]
	,[fecha_esp_recep_sala]
	,[dia_sala]
	,[id_semana]
)

SELECT * 
FROM COMPRA 
-- WHERE fecha_esp_recep_sala is not null;

--?? select * from NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_COMPRA_PREDISTRIBUIDA where sku = 05014038

