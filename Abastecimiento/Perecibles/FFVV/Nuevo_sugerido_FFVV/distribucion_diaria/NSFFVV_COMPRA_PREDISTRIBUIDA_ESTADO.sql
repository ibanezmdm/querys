
truncate table NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_COMPRA_PREDISTRIBUIDA_ESTADO
insert into NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_COMPRA_PREDISTRIBUIDA_ESTADO

	select *
	from openquery(dw,'
		select 
			e.num_ordencompra OC,
			e.desc_estadooc ESTADO_OC,
			e.desc_tipocancelacion TIPO_CANCELACION
		from dssmkpmmcl.estado_oc_ffvv e
	')


	update cp
	set ESTADO_OC = ce.ESTADO_OC
	from NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_COMPRA_PREDISTRIBUIDA cp
	left join NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_COMPRA_PREDISTRIBUIDA_ESTADO ce
		on cp.OC = ce.OC
	where cp.ESTADO_OC <> ce.ESTADO_OC
		and ce.OC is not null

