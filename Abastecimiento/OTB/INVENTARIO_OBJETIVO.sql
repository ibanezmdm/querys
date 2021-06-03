with inv_obj as (
	SELECT DISTINCT 
		R2.[DIVISION]
		,R2.[DEPARTAMENTO]
		,R2.[SUBDEPARTAMENTO]
		,R2.[CLASE]
		,R2.[SUBCLASE]
		,R2.[COD_LOCAL]
		,R2.[NOM_LOCAL]
		,ISNULL(R2.[COSTO_INV_DISP_HOY],0)+ISNULL(R2.[ON_ORDER_ASR_VALORIZADO],0)-R2.[VENTA_PROM_2_SEMANAS_FUTURAS] INVENTARIO_PROYECTADO
		,R2.[INVENTARIO_OBJETIVO]+ISNULL(R2.[INEFICIENCIA_UT_VALORIZADA],0) INVENTARIO_OBJETIVO,
		le.cod_local_espejo
	FROM [INFORMES3].[dbo].[OTBC_REPORTE_FASE2] R2 
	left join INFORMES3.dbo.TIENDAS_ASENTADAS ta
		on r2.cod_local = ta.cod_local
	left join [10.195.254.203].PronosticosVentas.dbo.LocalesEspejo_Aperturas le
		on le.cod_local = r2.cod_local
		and le.fecha_apertura > convert(date, getdate() - 21)
	where ta.cod_local is null
		and r2.cod_local not in (115)
)

select 
	i.COD_LOCAL,
	i.NOM_LOCAL,
	i.DIVISION,
	round(SUM(case when i.cod_local_espejo is null then i.INVENTARIO_OBJETIVO else esp.INVENTARIO_OBJETIVO end), 0) inv_obj 
from inv_obj i
left join inv_obj esp -- locales espejo
	on i.cod_local_espejo = esp.COD_LOCAL
	and i.SUBCLASE = esp.SUBCLASE
where i.DIVISION not in ('J0502 - LACTEOS', 'JSJ - SIN JERARQUIA', 'J12 - ADMINISTRATIVA')
group by 
	i.COD_LOCAL,
	i.NOM_LOCAL,
	i.DIVISION
order by
	i.COD_LOCAL,
	i.DIVISION
