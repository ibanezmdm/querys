SELECT
	DEPARTAMENTO,
	NOM_CATALOGO,
	P.NOM_PROMOCION,
	P.DETALLE_PROMOCION,
	P.SKU,
	P.NOM_SKU,
	ESTADO,
	P.NOM_PROVEEDOR,
	P.COD_LOCAL,
	[Pronostico Unidades],
	[Pronostico Cajas],
	UXC,
	[Unidades Efectivas],
	convert(int, INDICE_SURTIDO) INDICE_SURTIDO,
	factor,
	bfactor,
	[Pronostico Modificado]
FROM [PronosticosVentas].[dbo].[PRONOSTICO_RESUMEN_2] P
WHERE (P.COD_LOCAL NOT IN (SELECT * FROM [10.195.254.201].INFORMES3.dbo.TIENDAS_ASENTADAS) OR P.COD_LOCAL IN (202, 203, 206, 209))
	-- and factor is not null
