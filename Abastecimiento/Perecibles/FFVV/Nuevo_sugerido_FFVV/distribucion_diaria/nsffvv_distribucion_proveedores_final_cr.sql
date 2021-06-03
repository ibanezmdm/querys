-- con distribucion simplificada

SELECT A.[SUBDEPARTAMENTO]
      ,A.[CLASE]
      ,A.[NOM_SKU]
      ,A.[SKU]
      ,A.[LOCAL]
      ,DIST.COD_PMM 
      ,DIST.NOM_PROVEEDOR
      ,A.[ID_SEMANA]
      ,A.[CASEPACK]
      ,A.[SUGERIDO_TOTAL]
      ,A.[lunes]
      ,DIST.lunes lunes_dist
      ,ceiling(A.lunes*dist.lunes) COMPRA_LUNES_CAJAS
      ,A.[martes]
      ,DIST.martes martes_dist
      ,ceiling(A.martes*dist.martes) COMPRA_MARTES_CAJAS
      ,A.[miercoles]
      ,DIST.miercoles miercoles_dist
      ,ceiling(A.miercoles*dist.miercoles) COMPRA_MIERCOLES_CAJAS
      ,A.[jueves]
      ,DIST.jueves jueves_dist
      ,ceiling(A.jueves*dist.jueves) COMPRA_JUEVES_CAJAS
      ,A.[viernes]
      ,DIST.viernes viernes_dist
      ,ceiling(A.viernes*dist.viernes) COMPRA_VIERNES_CAJAS
      ,A.[sabado]
      ,DIST.sabado sabado_dist      
      ,ceiling(A.sabado*dist.sabado) COMPRA_SABADO_CAJAS
  FROM [NUEVO_SUGERIDO_FFVV].[dbo].[NSFVV_DISTRIBUCION_DIARIA_V2_FINAL_PIVOT] A LEFT JOIN
       [10.195.254.201].[NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_DISTRIBUCION_PROVEEDORES] DIST ON DIST.SEMANA=A.ID_SEMANA AND DIST.SKU=A.SKU
  where a.SKU=5014291 and a.LOCAL=104
  ORDER BY A.SKU,A.LOCAL,DIST.NOM_PROVEEDOR
  
  -- con distribucion de seba
  
  SELECT A.[SUBDEPARTAMENTO]
      ,A.[CLASE]
      ,A.[NOM_SKU]
      ,A.[SKU]
      ,A.[LOCAL]
      ,DIST.COD_PMM 
      ,DIST.NOM_PROVEEDOR
      ,A.[ID_SEMANA]
      ,A.[CASEPACK]
      ,A.[SUGERIDO_TOTAL]
      ,A.[lunes]
      ,DIST.lunes lunes_dist
      ,ceiling(A.lunes*dist.lunes) COMPRA_LUNES_CAJAS
      ,A.[martes]
      ,DIST.martes martes_dist
      ,ceiling(A.martes*dist.martes) COMPRA_MARTES_CAJAS
      ,A.[miercoles]
      ,DIST.miercoles miercoles_dist
      ,ceiling(A.miercoles*dist.miercoles) COMPRA_MIERCOLES_CAJAS
      ,A.[jueves]
      ,DIST.jueves jueves_dist
      ,ceiling(A.jueves*dist.jueves) COMPRA_JUEVES_CAJAS
      ,A.[viernes]
      ,DIST.viernes viernes_dist
      ,ceiling(A.viernes*dist.viernes) COMPRA_VIERNES_CAJAS
      ,A.[sabado]
      ,DIST.sabado sabado_dist      
      ,ceiling(A.sabado*dist.sabado) COMPRA_SABADO_CAJAS
  FROM (
  SELECT M.SUBDEPARTAMENTO,M.CLASE,M.NOM_SKU,A.SKU,A.COD_LOCAL LOCAL, A.ID_SEMANA,M.CASEPACK,A.sugerido_cajas SUGERIDO_TOTAL
       ,A.lunes
       ,A.martes
       ,A.miercoles
       ,A.jueves
       ,A.viernes
       ,A.sabado
FROM (
SELECT  id_semana
        ,cod_local
        ,sku
        ,[sugerido_cajas]
        , isnull([1],0) lunes
        , isnull([2],0) martes
        , isnull([3],0) miercoles
        , isnull([4],0) jueves
        , isnull([5],0) viernes
        , isnull([6],0) sabado
FROM  (
      SELECT id_semana
            ,cod_local
            ,sku
            ,sum(compra_cajas) compra_cajas
            ,dia_entrega_cd
            ,sum(cf.sugerido_cajas) sugerido_cajas
     FROM  [NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_dist_dia_compra_final] cf
     GROUP BY id_semana, sku,cod_local, dia_entrega_cd) cf PIVOT (sum(cf.compra_cajas) FOR dia_entrega_cd IN ([1], [2], [3], [4], [5], [6])) AS pvt
) A LEFT JOIN  
[10.195.254.201].RepNonFood.dbo.maestra_sku M ON M.SKU=A.SKU
        ) A LEFT JOIN
       [10.195.254.201].[NUEVO_SUGERIDO_FFVV].[dbo].[NSFFVV_DISTRIBUCION_PROVEEDORES] DIST ON DIST.SEMANA=A.ID_SEMANA AND DIST.SKU=A.SKU
  where a.SKU=5014291 and a.LOCAL=104
  ORDER BY A.SKU,A.LOCAL,DIST.NOM_PROVEEDOR