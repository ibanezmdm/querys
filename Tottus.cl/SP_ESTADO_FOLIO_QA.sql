USE [INFORMES3]
GO
/****** Object:  StoredProcedure [dbo].[Sp_ESTADO_FOLIO_QA]    Script Date: 06-11-2019 10:29:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[Sp_ESTADO_FOLIO_QA_v3]
AS
BEGIN
	SELECT
		CAB.NUMERO_ORDEN
		,F.NUMEROFOLIO
		,CASE when F.NUMEROFOLIO IS null then 'SIN FOLIO PMM'
		ELSE '' END FOLIO_PMM 
		, F.ESTADO ESTADO_FOLIO
		, CASE
      WHEN CAB.ID_sucursal=4 THEN 'Tienda Gris'
      WHEN CAB.ID_sucursal=9 THEN 'CD La Farfana'
      WHEN CAB.ID_sucursal=17 THEN 'CD F12'
      WHEN CAB.ID_sucursal=3 THEN 'Alderete'
      WHEN CAB.ID_sucursal=15 THEN 'Vivaceta'
    END Origen
    , qv.[Patente]
    , qv.[Transporte]
    , QC.Conductor
    , QC.[Telefono Transportista] [Telefono Conductor]
    , CL.NOMBRES [Nombre Cliente]
    , CL.CELULAR [Telefono Cliente]
    , CAB.LUGAR_DE_DESPACHO Direccion
    , CAB.COMUNA_DESPACHO Comuna
    , [Fecha Viaje]
    , [Fecha Salida]
    , [Fecha Entrega]
    , convert(date,F.FECHADESPACHO) FECHA_INICIO_DESPACHO
    , F.FECHADESPACHO FECHA_HORA_INICIO_DESPACHO
    , (SELECT SEMANA
				FROM [192.168.148.104].INFORMES3.dbo.DHW_MES_GC
				WHERE CONVERT(DATE,FECHA)=CONVERT(DATE,convert(date,F.FECHADESPACHO))
			) SEMANA
    , [Estado Entrega] ESTADO_QA
    , [Fh Fin Despacho]
    , [Condicion]
    , F.TIENDADERECOJO AS 'Punto_de_Retiro'
    , case
      when F.TIENDADERECOJO is null then 'Despacho Domicilio'
      else  'Despacho C&C' end 'Tipo Despacho',
		E.COMENTARI AS 'ESTADO_CHILEXPRESS',
		B.Estado_BlueE AS 'ESTADO_BLUE',
		C.ESTADO AS 'ESTADO_C&C',
		CASE
			WHEN F.TIENDADERECOJO IS NULL AND F.ESTADO = 'EN RUTA'
				AND ([Estado Entrega] = 'ENTREGADO OK' OR E.COMENTARI = 'PIEZA ENTREGADA A DESTINA' OR B.Estado_BlueE = 'Entregado') THEN 'ENTREGA TOTAL'
				ELSE F.ESTADO
		END AS ESTADO_FINAL_ENTREGADO,
		CASE
			WHEN F.TIENDADERECOJO IS NULL AND F.ESTADO = 'EN RUTA' THEN
				CASE 
					WHEN [Estado Entrega] = 'ENTREGADO OK' THEN 'QA_RENDICION'
					WHEN E.COMENTARI = 'PIEZA ENTREGADA A DESTINA' THEN 'CHILEXPRESS'
					WHEN B.Estado_BlueE = 'Entregado' THEN 'BLUEXPRESS'
				END
				ELSE NULL
		END AS ENTREGADO_POR
	FROM [192.168.148.104].[INFORMES3].dbo.CL_DS_CABECERA_PEDIDOS CAB LEFT JOIN
		(SELECT *
		FROM OPENQUERY(SANDBOX_F,'SELECT f.*, o.tiendaderecojo FROM icarrasco.ds_folio f left join ds_oc o on f.numeroorden = o.numero_orden where TO_CHAR(O.FECHA_HORA_INICIO_DESPACHO, ''YYYYMMDD'') > ''20190901''')) F ON F.[numeroorden]=cab.[numero_orden] LEFT JOIN --AND CAB ON CAB.NUMERO_ORDEN=F.[numeroorden]
		[INFORMES3].[dbo].[OC_ESTADO_FOLIO_F12_QA] QV ON QV.[N° Orden]=F.NUMEROFOLIO LEFT JOIN
		[192.168.148.104].[INFORMES3].[dbo].[QA_CUMPLIMIENTO_VIAJES_F12] QC ON QC.[Viaje]=QV.[Nro Viaje] LEFT JOIN
		[192.168.148.104].[INFORMES3].[dbo].OC_DS_CLIENTES CL ON CL.RUT=CAB.RUT_CLIENTE LEFT JOIN
		(SELECT I.FOLIO,
			I.ID_ESTADO,
			E.COMENTARI
		FROM
			(SELECT FOLIO, MAX(CONVERT(FLOAT,[COD_Estado])) ID_ESTADO
			FROM [INFORMES3].[dbo].[OC_ESTADO_FOLIO_F12_CHILEXPRESS]
			GROUP BY FOLIO
			) I LEFT JOIN [INFORMES3].[dbo].[OC_ESTADO_FOLIO_F12_CHILEXPRESS] E ON E.FOLIO = I.FOLIO AND I.ID_ESTADO = E.COD_ESTADO
		) E ON E.FOLIO = F.NUMEROFOLIO LEFT JOIN
		[INFORMES3].[dbo].[OC_ESTADO_FOLIO_F12_BLUEXPRESS] B ON B.Folio_BlueE = F.NUMEROFOLIO LEFT JOIN
		[INFORMES3].[dbo].[OC_ESTADO_FOLIO_F12_C&C] C ON C.PEDIDO = CAB.NUMERO_ORDEN
	WHERE  CAB.ID_SUCURSAL IN (3,4,9,15,17) AND CONVERT(DATE,CAB.FECHA_INICIO_DESPACHO)>='2019-09-01'
	group by
		CAB.NUMERO_ORDEN
		,F.NUMEROFOLIO	
		,F.ESTADO
		,CAB.ID_sucursal
		,qv.[Patente]
		,qv.[Transporte]
		,QC.Conductor
		,QC.[Telefono Transportista] 
		,CL.NOMBRES 
		,CL.CELULAR 
		,CAB.LUGAR_DE_DESPACHO 
		,CAB.COMUNA_DESPACHO 
		,[Fecha Viaje]
		,[Fecha Salida]
		,[Fecha Entrega]
		,F.FECHADESPACHO 
		,[Estado Entrega]
		,[Fh Fin Despacho]
		,[Condicion]
		,F.TIENDADERECOJO
		,E.COMENTARI
		,B.Estado_BlueE
		,C.ESTADO

END