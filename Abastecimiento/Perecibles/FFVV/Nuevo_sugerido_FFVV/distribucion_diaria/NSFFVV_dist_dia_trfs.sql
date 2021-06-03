
truncate table NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_dist_dia_trfs;

with transito as (	
	select 
		sku,
		tienda as cod_local,
		sum(unidades) as cantidad,
		convert(date, fecha_despacho) fecha_despacho
	from OPENQUERY(MANHATAN,' 
	SELECT   
		IT.ITEM_NAME AS SKU,   
		LPN.D_FACILITY_ALIAS_ID AS TIENDA,  
		LD.SHIPPED_QTY AS UNIDADES,  
		TO_CHAR(LD.CREATED_DTTM,''YYYY/MM/DD'') AS FECHA_DESPACHO  
	FROM LPN
	left join LPN_DETAIL LD
		on LPN.LPN_ID = LD.LPN_ID
	left join ITEM_CBO IT
		on LD.ITEM_ID = IT.ITEM_ID
	left join ITEM_PACKAGE_CBO PACK
		on IT.ITEM_ID = PACK.ITEM_ID  
	WHERE LPN.LPN_FACILITY_STATUS = ''90''   
		AND TO_CHAR(LPN.LPN_STATUS_UPDATED_DTTM,''YYYY/MM/DD'') >= (to_char(getdate() - 4,''YYYY/MM/DD''))  
		AND LPN.INBOUND_OUTBOUND_INDICATOR = ''O''
		AND LD.ITEM_ID = IT.ITEM_ID  
		and IT.ref_field5 like(''J04%'')  
		and pack.package_uom_id = ''73''  
		and pack.is_std = ''1''  
		and pack.mark_for_deletion = ''0''
	')
	GROUP BY SKU, TIENDA, FECHA_DESPACHO
) 

insert into NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_dist_dia_trfs
	--?? select * from  NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_dist_dia_trfs where cod_local = 101 and sku = 5014004
	--?? select distinct fecha_despacho, fecha_sala from  NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_dist_dia_trfs order by fecha_despacho desc, fecha_sala desc

select trf.*,
	fd.fecha_entrega_cd,
	datepart(weekday, fd.fecha_entrega_cd) dia_entrega_cd,
	fd.id_semana,
	case when lt.lead_time = 2
		then 
			case 
				when datepart(weekday, dateadd(day, 1, fd.fecha_despacho)) % 7 = 0 then dateadd(day, 2, fd.fecha_despacho)
				else dateadd(day, 1, fd.fecha_despacho)
			end
		else fd.fecha_despacho
	end fecha_sala
from transito trf
left join nuevo_sugerido_ffvv.dbo.vw_fecha_despacho fd
	on fd.fecha_despacho = trf.fecha_despacho
left join nuevo_sugerido_ffvv.dbo.vw_ciclo_fecha_frecuencia cf
	on cf.cod_local = trf.cod_local
	and cf.fecha_entrega_cd = fd.fecha_entrega_cd
left join nuevo_sugerido_ffvv.dbo.vw_lead_time_regular lt
	on lt.cod_local = trf.cod_local


