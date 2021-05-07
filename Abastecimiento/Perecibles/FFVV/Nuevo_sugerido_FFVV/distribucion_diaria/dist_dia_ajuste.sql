
-- declare @dia_pedido date = (select MAX(fecha_hora) from NUEVO_SUGERIDO_FFVV.dbo.NSFFVV_SUGERIDO_CALCULADO_F)
declare @dia_pedido date = getdate();
declare @dia_inicio_compra date = dateadd(day, 8 - datepart(weekday, @dia_pedido), @dia_pedido);
declare @id_semana_pedido int = datepart(year, @dia_inicio_compra) * 100 + datepart(iso_week, @dia_inicio_compra);
declare @id_semana_anterior int = datepart(year, dateadd(day, -7, @dia_inicio_compra)) * 100 + datepart(iso_week, dateadd(day, -7, @dia_inicio_compra));
declare @dia as smallint = datepart(weekday, @dia_inicio_compra);
declare @desviaciones as int;
declare @iteracion as int = 1;
-- select 
-- 	@dia_pedido dia_pedido,
-- 	@dia_inicio_compra dia_inicio_compra,
-- 	@id_semana_pedido id_semana_pedido,
-- 	@id_semana_anterior id_semana_anterior,
-- 	@dia dia,
-- 	@desviaciones desviaciones,
-- 	@iteracion iteracion


/** Calculo de cantidad exacta a comprar en cajas para cada dia
	* Desc:		Query que calcula la cantidad exacta a comprar en cajas para cada dia, tomando en cuenta que se tienen que comprar las mismas cantidades sugeridas o corregidas.
	* param:	@id_semana_pedido >> indeca la semana de pedido
	* param:	@dia >> indica el primer dia de despacho a cd
	* -- ?? select * from [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_compra_final]
**/

-- llena la tabla final con las cantidades por dia redondeadas a cajas
truncate table [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_compra_final]
insert into [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_compra_final]

select 
	ec.cod_local,
	ec.SKU,
	case when ms.CASEPACK is null or ms.CASEPACK = 0 then 1 else ms.CASEPACK end casepack,
	ec.dia_entrega_cd,
	ec.id_semana,
	ec.sugerido_cajas,
	ec.compra,
	round(ec.compra / case when ms.CASEPACK is null or ms.CASEPACK = 0 then 1 else ms.CASEPACK end, 0) * case when ms.CASEPACK is null or ms.CASEPACK = 0 then 1 else ms.CASEPACK end compra_unidades,
	round(ec.compra / case when ms.CASEPACK is null or ms.CASEPACK = 0 then 1 else ms.CASEPACK end, 0) compra_cajas
from NUEVO_SUGERIDO_FFVV.dbo.[NSFFVV_dist_dia_estimacion_compra] ec
left join RepNonFood.dbo.MAESTRA_SKU ms
	on ms.sku = ec.SKU
where ec.sugerido_cajas is not null
	-- and ec.SKU = 5014038
	-- and cod_local = 104



-- se llena una tabla con los skus que tienen desviaciones entre las cantidades compradas y sugerido o corregido
truncate table [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_desviacion_compra]
insert into [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_desviacion_compra]

select *
from (
	select 
		sf.cod_local,
		sf.SKU,
		sf.sugerido_cajas,
		sum(sf.compra_cajas) compra_cajas
	from [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_compra_final] sf
	group by 
		sf.cod_local,
		sf.SKU,
		sf.sugerido_cajas
) sf
where sf.compra_cajas <> sf.sugerido_cajas

-- se cuentan las desviaciones envontradas
set @desviaciones = (select count(*) from [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_desviacion_compra])


-- se genera un ciclo while el cual va corrigiendo las cantidades hasta que las cajas a comprar sean iguales a las cajas sugeridas o corregidas (test: tope 50 iteraciones)
while @desviaciones <> 0 or @iteracion = 50
begin

	-- Añade una caja a compras menores al los pedidos
	update sf
	set compra_cajas = sf.compra_cajas + 1
	from [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_compra_final] sf
	inner join (
		select 
			sf.cod_local,
			sf.sku,
			sf.dia_entrega_cd,
			sf.compra_cajas,
			ds.sugerido_cajas,
			ds.compra_cajas compra_cajas_total,
			sf.compra_estimada,
			sf.casepack,
			sf.compra_cajas * casepack - sf.compra_estimada difencia,
			ROW_NUMBER() over(partition by sf.cod_local, sf.sku order by sf.compra_cajas * casepack - sf.compra_estimada asc) as row_number
		from [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_compra_final] sf
		inner join [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_desviacion_compra] ds
			on ds.cod_local = sf.cod_local
			and ds.SKU = sf.SKU
		where ds.sugerido_cajas > ds.compra_cajas
			-- and sf.SKU = 5014004
			-- and sf.cod_local = 104
	) filtro
		on sf.cod_local = filtro.cod_local
		and sf.SKU = filtro.SKU
		and sf.dia_entrega_cd = filtro.dia_entrega_cd
	where row_number = 1


	-- Quita una caja a compras mayores al pedido
	update sf
	set compra_cajas = sf.compra_cajas - 1
	from [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_compra_final] sf
	inner join (
		select 
			sf.cod_local,
			sf.sku,
			sf.dia_entrega_cd,
			sf.compra_cajas,
			ds.sugerido_cajas,
			ds.compra_cajas compra_cajas_total,
			sf.compra_estimada,
			sf.casepack,
			sf.compra_cajas * casepack - sf.compra_estimada diferencia,
			ROW_NUMBER() over(partition by sf.cod_local, sf.sku order by sf.compra_cajas * casepack - sf.compra_estimada desc) as row_number
		from [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_compra_final] sf
		inner join [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_desviacion_compra] ds
			on ds.cod_local = sf.cod_local
			and ds.SKU = sf.SKU
		where ds.sugerido_cajas < ds.compra_cajas
			and sf.compra_cajas > 0
			-- and sf.SKU = 5014010
			-- and sf.cod_local = 104
	) filtro
		on sf.cod_local = filtro.cod_local
		and sf.SKU = filtro.SKU
		and sf.dia_entrega_cd = filtro.dia_entrega_cd
	where row_number = 1


	-- se vuelve a evaluar la cantidad de desviaciones entre cantidades a comprar y sugeridas o corregidas
	truncate table [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_desviacion_compra]
	insert into [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_desviacion_compra]

	select *
	from (
		select 
			sf.cod_local,
			sf.SKU,
			sf.sugerido_cajas,
			sum(sf.compra_cajas) compra_cajas
		from [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_compra_final] sf
		group by 
			sf.cod_local,
			sf.SKU,
			sf.sugerido_cajas
	) sf
	where sf.compra_cajas <> sf.sugerido_cajas

	-- se vuelve a evaluar cuantas desviaciones tenemos, en caso de tener 0 se termina el ciclo while.
	set @desviaciones = (select count(*) from [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_desviacion_compra])
	set @iteracion = @iteracion + 1

end