USE [BioStar]
GO
/****** Object:  StoredProcedure [dbo].[getChecadasTotales]    Script Date: 16/01/2018 17:39:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Raul González>
-- Create date: <25/09/2017>
-- Description:	<Procedimiento para obtener los datos del reporte de checadores, hoja TOTALES>
-- =============================================
ALTER PROCEDURE [dbo].[getChecadasTotales]
(
	-- PARÁMETROS:
	-- FECHA INICIAL Y FECHA FINAL (DATE): SE DEBEN OBTENER LAS FECHAS DE LAS CUALES SE CONSULTAN LOS VALORES, PARA CONVERTIRLO
	-- EN EL FORMATO CORRESPONDIENTE.
	@pInicio date,
	@pFInal date
)
AS
BEGIN	
	DECLARE
		@fInicio date,
		@fFinal date,
		@fechaInicial datetime,
		@fechaFinal datetime
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	-- SI LA FECHA INICIO ES UN VALOR NULO, REGRESA EL INICIO DEL DÍA DE HOY, DE OTRA FORMA EL INICIO DEL DÍA 
	-- QUE SE ENVIÓ COMO PARÁMETRO
	SET @fInicio = @pInicio
	SET @fFinal = @pFInal
	--select @fInicio
	--select @fFinal
	
	IF @fInicio = NULL 
		set @fechaInicial = DATEADD(dd,DATEDIFF(dd,0,GETDATE()),0)
	ELSE
		set @fechaInicial = DATEADD(dd,DATEDIFF(dd,0,@fInicio),0)
	-- SI LA FECHA FINAL ES UN VALOR NULO, REGRESA EL FINAL DEL DÍA DE HOY, EN CASO CONTRARIO EL FINAL DEL DÍA ENVIADO
	-- COMO FECHA FINAL
	IF @fFInal = NULL
		set @fechaFinal = DATEADD(ms, -3, DATEADD(dd, DATEDIFF(dd, -1, GETDATE()), 0))
	ELSE
		set @fechaFinal = DATEADD(ms, -3, DATEADD(dd, DATEDIFF(dd, -1, @fFInal), 0))

	/* VALIDACIONES PARA VERIFICAR EL FORMATO EN QUE APARECEN LAS FECHAS
	SELECT @fechaInicial
	SELECT @fechaFinal

	--variables de paso
	declare @in as int = DATEDIFF(S,'1970-01-01 00:00:00',@fechaInicial)
	declare @fin as int = DATEDIFF(S,'1970-01-01 00:00:00',@fechaFinal)

	SELECT @in
	SELECT @fin*/
	-- SE REALIZA LA CONSULTA EN BASE A LAS FECHAS OBTENIDAS DESDE EL PARÁMETRO
	SELECT * FROM (
		SELECT
		DATEADD(S,t1.nDateTime,'1970-01-01 00:00:00') AS Date,
		t2.sName AS Device,
		t4.sName AS Event,
		t1.nUserID AS "User ID",
		ISNULL((SELECT t3.sUserName FROM TB_USER t3 WHERE t1.nUserID = t3.sUserID),'') AS Nombre
		FROM
		TB_EVENT_LOG t1 INNER JOIN TB_READER t2 ON t1.nReaderIdn = t2.nReaderIdn
		INNER JOIN 
		TB_EVENT_DATA t4 ON t1.nEventIdn = t4.nEventIdn
		WHERE 
		t1.nEventIdn in (55,56,61)
		AND t1.nDateTime BETWEEN DATEDIFF(S,'1970-01-01 00:00:00',@fechaInicial) AND DATEDIFF(S,'1970-01-01 00:00:00',@fechaFinal)
	UNION
		SELECT
		DATEADD(S,t1.nDateTime,'1970-01-01 00:00:00') AS Date,
		t2.sName AS Device,
		t4.sName AS Event,
		t1.nUserID AS "User ID",
		ISNULL((SELECT t3.sUserName FROM TB_USER t3 WHERE t1.nUserID = t3.sUserID),'') AS Nombre
		FROM
		TB_EVENT_LOG_BK t1 INNER JOIN TB_READER t2 ON t1.nReaderIdn = t2.nReaderIdn
		INNER JOIN 
		TB_EVENT_DATA t4 ON t1.nEventIdn = t4.nEventIdn
		WHERE 
		t1.nEventIdn in (55,56,61)
		AND t1.nDateTime BETWEEN DATEDIFF(S,'1970-01-01 00:00:00',@fechaInicial) AND DATEDIFF(S,'1970-01-01 00:00:00',@fechaFinal)
		) AS query
	ORDER BY Date ASC
END
