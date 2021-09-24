-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02]
-- // MODULO:			ESTATUS POR ORDEN/SERIAL
-- // OPERACION:		LIBERACION / STORED PROCEDURE
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	31/MAY/2021
-- //////////////////////////////////////////////////////////////  

USE [DATA_02]
GO

-- //////////////////////////////////////////////////////////////



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_MATERIAL_PROGRAMADO_ESCANEADO_X_ESTACION]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_MATERIAL_PROGRAMADO_ESCANEADO_X_ESTACION]
GO
/*
 EXEC	[dbo].[PG_LI_MATERIAL_PROGRAMADO_ESCANEADO_X_ESTACION] 0,0, 'LAMINACION', 'IT-010'
    
*/

CREATE PROCEDURE [dbo].[PG_LI_MATERIAL_PROGRAMADO_ESCANEADO_X_ESTACION]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_USUARIO_EVENTO			VARCHAR(100),
	@PP_ESTACION				VARCHAR(100)
AS

	SELECT	SERIAL,  
			[MATERIAL_PROGRAMADO].ITEM_NO,
			originalqty AS CANTIDAD,
			CODIGO_ETIQUETA,
			( CASE WHEN EP_NOMBRE IS NULL THEN 'N/E'
				ELSE CONCAT(EP_NOMBRE, ' ', EP_APELLIDO_PATERNO) END ) AS RESPONSABLE,
			CONVERT(VARCHAR,F_EVENTO, 20) AS F_EVENTO 
	FROM [MATERIAL_PROGRAMADO] (NOLOCK)
	INNER JOIN ccjoblin_sql (NOLOCK) ON LTRIM(RTRIM(ccjoblin_sql.jobno)) + RIGHT('000'+ LTRIM(RTRIM(ser_no)),3) = SERIAL
	LEFT JOIN HOWE.dbo.VISTA_GAFETES (NOLOCK) ON VISTA_GAFETES.EN_NUM_EMP = K_RESPONSABLE
	WHERE USUARIO_EVENTO =  @PP_USUARIO_EVENTO
	AND ESTACION = @PP_ESTACION
	AND CONVERT(DATE, F_EVENTO) = CONVERT(DATE, GETDATE())
	ORDER BY K_MATERIAL_PROGRAMADO DESC
	-- ////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////
-- USE DATA_02
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_ESTATUS_X_SERIAL_ORDEN]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_ESTATUS_X_SERIAL_ORDEN]
GO

/*
												  (ORDEN)
 EXEC	[dbo].[PG_LI_ESTATUS_X_SERIAL_ORDEN] 0,0, '', '( TODOS )', '( TODOS )', '( TODOS )'
 EXEC	[dbo].[PG_LI_ESTATUS_X_SERIAL_ORDEN] 0,0, 'rpwldfclwlcpx7,q30-s32629004*200769ctx7%magn02#wdl@1', '( TODOS )', '( TODOS )', '( TODOS )'
 EXEC	[dbo].[PG_LI_ESTATUS_X_SERIAL_ORDEN] 0,0, '32629', '( TODOS )', '( TODOS )', '( TODOS )'
 EXEC	[dbo].[PG_LI_ESTATUS_X_SERIAL_ORDEN] 0,0, '32630', '( TODOS )', '( TODOS )', '( TODOS )'
*/


CREATE PROCEDURE [dbo].[PG_LI_ESTATUS_X_SERIAL_ORDEN]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_BUSCAR						VARCHAR(150),
	@PP_CLIENTE						VARCHAR(50),
	@PP_MESA						VARCHAR(50),
	@PP_EVENTO_ACTUAL				VARCHAR(100)
AS

	-- ///////CUANDO SE ESCANEA EL SERIAL DE LA ETIQUE TRAE LA S AL PRINCIPIO CON ESTO SE ELIMINA///////////////////////////////////////////////////////
	IF SUBSTRING(@PP_BUSCAR, 1, 1) = 'S'
		SET @PP_BUSCAR = SUBSTRING(@PP_BUSCAR, 2 , LEN(@PP_BUSCAR))

	-- ///////SE DECLARAN VARIABLES A USARSE////////////////////////////////////
	DECLARE @VP_PART_NO				VARCHAR(50) = '' 
	DECLARE @VP_QTY					VARCHAR(50) = '' 
	DECLARE @VP_SERIAL_1			VARCHAR(50) = '' 
	DECLARE @VP_SERIAL_2			VARCHAR(50) = '' 
	DECLARE @VP_CUSTNO				VARCHAR(50) = '' 
	DECLARE @VP_CLIENTE				VARCHAR(50) = ''
	DECLARE @VP_PRODUCT_CAT			VARCHAR(50) = '' 
	DECLARE @VP_LOTE_1				VARCHAR(50) = '' 
	DECLARE @VP_LOTE_2				VARCHAR(50) = '' 

	IF LEN(@PP_BUSCAR) > 29
		BEGIN
			EXECUTE [dbo].[PG_GET_DATO_ETIQUETA_KIT]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
														@PP_BUSCAR,
														@OU_PART_NO		 =	@VP_PART_NO			OUTPUT,
														@OU_QTY			 =	@VP_QTY				OUTPUT,
														@OU_SERIAL_1	 =	@VP_SERIAL_1		OUTPUT,
														@OU_SERIAL_2	 =	@VP_SERIAL_2		OUTPUT,
														@OU_CUSTNO		 =  @VP_CUSTNO			OUTPUT,
														@OU_CLIENTE		 =  @VP_CLIENTE			OUTPUT,
														@OU_PRODUCT_CAT	 =  @VP_PRODUCT_CAT 	OUTPUT,
														@OU_LOTE_1		 =  @VP_LOTE_1			OUTPUT,
														@OU_LOTE_2		 =  @VP_LOTE_2			OUTPUT	

			SET @PP_BUSCAR = @VP_SERIAL_1
		END

	-- ///////SE CREA TABLA TEMPORAL PARA GUARDAR DATOS DEL PRIMER SELECT///////////////////////////////////////////////////////
	DECLARE @TBL_SEGUIMIENTO_MATERIAL_PROGRAMADO_LOG AS TABLE(
			JOBNO				VARCHAR(50),
			SER_NO				INT,
			SERIAL				VARCHAR(50),
			KIT_DESC			VARCHAR(255),
			ORIGINAL_QTY		INT,
			CUSTOMER			VARCHAR(50),
			ITEM_NO				VARCHAR(100),
			--ITEM_NO_ETIQUETA	VARCHAR(100),
			CUS_ITEM_NO			VARCHAR(100),
			MODEL_NO			VARCHAR(100),
			VERSION_NO			VARCHAR(100),
			MESA				VARCHAR(100),
			F_CREACION			DATE,
			EVENTO_ACTUAL		VARCHAR(100)
			--EVENTO_SIGUIENTE	VARCHAR(100),
			--F_EVENTO			DATE
	)

	-- //////////SE INGRESAN LOS DATOS A LA TABLA TEMPORAL////////////////////////////////////////////////////
	INSERT INTO @TBL_SEGUIMIENTO_MATERIAL_PROGRAMADO_LOG
	SELECT	LTRIM(RTRIM(ccjoblin_sql.jobno))		AS JOBNO, 
			Ser_No,
			-- ===========================
			LTRIM(RTRIM(ccjoblin_sql.jobno)) + RIGHT('000'+ CONVERT(VARCHAR(10),ser_no), 3) AS SERIAL,
			-- ===========================
			LTRIM(RTRIM(ccjoblin_sql.kitdesc))		AS KIT_DESC, 
			CONVERT(INT,ccjoblin_sql.originalqty)	AS ORIGINAL_QTY, 
			LTRIM(RTRIM(ccjoblin_sql.customer))		AS CUSTOMER, 
			-- ===========================
			LTRIM(RTRIM(ccjoblin_sql.item_no))		AS ITEM_NO,
			-- ===========================
			LTRIM(RTRIM(cccusitm_sql.cus_item_no))	AS CUS_ITEM_NO,
			LTRIM(RTRIM(cccusitm_sql.modelno))		AS MODEL_NO,
			LTRIM(RTRIM(cccusitm_sql.versionno))	AS VERSION_NO,
			LTRIM(RTRIM(MACHINE))					AS MESA,
			[dbo].[CONVERT_INT_TO_DATE](ccjobhdr_sql.datecreated) AS F_CREACION,
			-- ===========================
			ISNULL(( SELECT D_KIT_RUTA_EVENTO
				FROM [MATERIAL_PROGRAMADO] (NOLOCK)
				INNER JOIN KIT_RUTA_EVENTO (NOLOCK) ON KIT_RUTA_EVENTO.K_KIT_RUTA_EVENTO = [MATERIAL_PROGRAMADO].K_TIPO_EVENTO_KIT
				WHERE SERIAL = LTRIM(RTRIM(ccjoblin_sql.jobno)) + RIGHT('000'+ CONVERT(VARCHAR(10),ser_no), 3)), 'MATERIALES') AS EVENTO_ACTUAL
			-- ===========================
	FROM ccjoblin_sql  (NOLOCK)
	INNER JOIN ccjobhdr_sql (NOLOCK) ON ccjoblin_sql.jobno = ccjobhdr_sql.jobno 
		AND status = 'P'
		AND ccjobhdr_sql.JOBNO < 50000
	-- ===========================
	INNER JOIN	cccusitm_sql (NOLOCK) ON ccjoblin_sql.Item_No = cccusitm_sql.item_no 
	AND		ccjoblin_sql.customer = cccusitm_sql.cus_no
	AND		cccusitm_sql.versionno = (	SELECT	MAX(CONVERT(INT, versionno)) 
													FROM	cccusitm_sql (NOLOCK)
													WHERE	cccusitm_sql.Item_No = ccjoblin_sql.item_no  
													AND		cccusitm_sql.cus_no = ccjoblin_sql.customer)

	-- ////////SE REALIZA EL SELECT FINAL////////////////////////////////////////
	SELECT	SMPL.*,
			-- ===========================
			ISNULL(UPPER([MATERIAL_PROGRAMADO].ITEM_NO), 'N/E')  AS ITEM_NO_ETIQUETA,
			-- ===========================
			( CASE WHEN EVENTO_ACTUAL = 'FACTURADO' THEN 'FIN'
					ELSE (
			SELECT ISNULL(( SELECT TOP 1  D_KIT_RUTA_EVENTO
			FROM KIT_RUTA (NOLOCK)
			INNER JOIN KIT_RUTA_EVENTO (NOLOCK) ON KIT_RUTA_EVENTO.K_KIT_RUTA_EVENTO = KIT_RUTA.K_KIT_RUTA_EVENTO
			WHERE KIT_RUTA.ITEM_NO = SMPL.ITEM_NO
			AND KIT_RUTA.MODELNO = SMPL.MODEL_NO
			AND KIT_RUTA.VERSIONNO = SMPL.VERSION_NO
			AND KIT_RUTA.O_KIT_RUTA_EVENTO > (	SELECT  KIT_RUTA.O_KIT_RUTA_EVENTO
												FROM KIT_RUTA (NOLOCK)
												INNER JOIN KIT_RUTA_EVENTO (NOLOCK) ON KIT_RUTA_EVENTO.K_KIT_RUTA_EVENTO = KIT_RUTA.K_KIT_RUTA_EVENTO
												WHERE KIT_RUTA.ITEM_NO = SMPL.ITEM_NO
												AND KIT_RUTA.MODELNO = SMPL.MODEL_NO
												AND KIT_RUTA.VERSIONNO = SMPL.VERSION_NO
												AND KIT_RUTA.K_KIT_RUTA_EVENTO = (	SELECT TOP 1 K_TIPO_EVENTO_KIT 
																					FROM [MATERIAL_PROGRAMADO] (NOLOCK)
																					WHERE SERIAL = SMPL.SERIAL))), 'N/E' )) END )  AS EVENTO_SIGUIENTE,
			-- ===========================
			--( CASE WHEN EVENTO_ACTUAL = 'FACTURADO' THEN 'FIN'
			--		ELSE (	ISNULL(( SELECT TOP 1 D_KIT_RUTA_EVENTO
			--				FROM KIT_RUTA (NOLOCK)
			--				INNER JOIN KIT_RUTA_EVENTO (NOLOCK) ON KIT_RUTA_EVENTO.K_KIT_RUTA_EVENTO = KIT_RUTA.K_KIT_RUTA_EVENTO
			--				WHERE KIT_RUTA.ITEM_NO = SMPL.ITEM_NO
			--				AND KIT_RUTA.MODELNO = SMPL.MODEL_NO
			--				AND KIT_RUTA.VERSIONNO = SMPL.VERSION_NO
			--				AND KIT_RUTA.K_KIT_RUTA_EVENTO > (	SELECT TOP 1 K_TIPO_EVENTO_KIT 
			--													FROM [MATERIAL_PROGRAMADO] (NOLOCK)
			--													WHERE SERIAL = SMPL.SERIAL)), 'N/E' )) END )  AS EVENTO_SIGUIENTE,
			-- ===========================
			ISNULL(CONVERT(DATE, [MATERIAL_PROGRAMADO].F_EVENTO), CONVERT(DATE, GETDATE()))  AS F_EVENTO
			-- ===========================
	FROM @TBL_SEGUIMIENTO_MATERIAL_PROGRAMADO_LOG AS SMPL
	LEFT JOIN  [MATERIAL_PROGRAMADO] (NOLOCK) ON SMPL.SERIAL = [MATERIAL_PROGRAMADO].SERIAL
	-- ===========================
	WHERE EVENTO_ACTUAL  = ( CASE WHEN @PP_EVENTO_ACTUAL <> '( TODOS )' THEN @PP_EVENTO_ACTUAL
								ELSE EVENTO_ACTUAL END )
	-- ===========================
	AND	(	SMPL.JOBNO				LIKE '%'+@PP_BUSCAR+'%'
			OR	SMPL.CUS_ITEM_NO	LIKE '%'+@PP_BUSCAR+'%' 
			OR	SMPL.ITEM_NO		LIKE '%'+@PP_BUSCAR+'%'
			OR	SMPL.MODEL_NO		LIKE '%'+@PP_BUSCAR+'%'
			OR SMPL.SERIAL			LIKE '%'+@PP_BUSCAR+'%' )
	-- ===========================
	AND SMPL.CUSTOMER = ( CASE WHEN @PP_CLIENTE <> '( TODOS )' THEN @PP_CLIENTE
										ELSE SMPL.CUSTOMER END )
	-- ===========================
	AND SMPL.MESA = ( CASE WHEN @PP_MESA <> '( TODOS )' THEN @PP_MESA
										ELSE SMPL.MESA END )
	-- ===========================
	ORDER BY JOBNO, SER_NO
	-- ////////////////////////////////////////////////
GO





-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////
-- USE DATA_02
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_ESTATUS_MATERIAL_PROGRAMADO_X_ORDEN]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_ESTATUS_MATERIAL_PROGRAMADO_X_ORDEN]
GO

/*
 EXEC	[dbo].[PG_SK_ESTATUS_MATERIAL_PROGRAMADO_X_ORDEN] 0,0, '41026'
*/


CREATE PROCEDURE [dbo].[PG_SK_ESTATUS_MATERIAL_PROGRAMADO_X_ORDEN]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_ORDEN						VARCHAR(100)
AS
	-- ///////SE CREA TABLA TEMPORAL PARA GUARDAR DATOS DEL PRIMER SELECT///////////////////////////////////////////////////////
	DECLARE @TBL_SEGUIMIENTO_MATERIAL_PROGRAMADO_LOG AS TABLE(
			JOBNO				VARCHAR(50),
			SER_NO				INT,
			SERIAL				VARCHAR(50),
			KIT_DESC			VARCHAR(255),
			ORIGINAL_QTY		INT,
			CUSTOMER			VARCHAR(50),
			ITEM_NO				VARCHAR(100),
			--ITEM_NO_ETIQUETA	VARCHAR(100),
			CUS_ITEM_NO			VARCHAR(100),
			MODEL_NO			VARCHAR(100),
			VERSION_NO			VARCHAR(100),
			MESA				VARCHAR(100),
			F_CREACION			DATE,
			EVENTO_ACTUAL		VARCHAR(100)
			--EVENTO_SIGUIENTE	VARCHAR(100),
			--F_EVENTO			DATE
	)

	-- //////////SE INGRESAN LOS DATOS A LA TABLA TEMPORAL////////////////////////////////////////////////////
	INSERT INTO @TBL_SEGUIMIENTO_MATERIAL_PROGRAMADO_LOG
	SELECT	LTRIM(RTRIM(ccjoblin_sql.jobno))		AS JOBNO, 
			Ser_No,
			-- ===========================
			LTRIM(RTRIM(ccjoblin_sql.jobno)) + RIGHT('000'+ CONVERT(VARCHAR(10),ser_no), 3) AS SERIAL,
			-- ===========================
			LTRIM(RTRIM(ccjoblin_sql.kitdesc))		AS KIT_DESC, 
			CONVERT(INT,ccjoblin_sql.originalqty)	AS ORIGINAL_QTY, 
			LTRIM(RTRIM(ccjoblin_sql.customer))		AS CUSTOMER, 
			-- ===========================
			LTRIM(RTRIM(ccjoblin_sql.item_no))		AS ITEM_NO,
			-- ===========================
			LTRIM(RTRIM(cccusitm_sql.cus_item_no))	AS CUS_ITEM_NO,
			LTRIM(RTRIM(cccusitm_sql.modelno))		AS MODEL_NO,
			LTRIM(RTRIM(cccusitm_sql.versionno))	AS VERSION_NO,
			LTRIM(RTRIM(MACHINE))					AS MESA,
			[dbo].[CONVERT_INT_TO_DATE](ccjobhdr_sql.datecreated) AS F_CREACION,
			-- ===========================
			ISNULL(( SELECT D_KIT_RUTA_EVENTO
				FROM [MATERIAL_PROGRAMADO] (NOLOCK)
				INNER JOIN KIT_RUTA_EVENTO (NOLOCK) ON KIT_RUTA_EVENTO.K_KIT_RUTA_EVENTO = [MATERIAL_PROGRAMADO].K_TIPO_EVENTO_KIT
				WHERE SERIAL = LTRIM(RTRIM(ccjoblin_sql.jobno)) + RIGHT('000'+ CONVERT(VARCHAR(10),ser_no), 3)), 'MATERIALES') AS EVENTO_ACTUAL
			-- ===========================
	FROM ccjoblin_sql  (NOLOCK)
	INNER JOIN ccjobhdr_sql (NOLOCK) ON ccjoblin_sql.jobno = ccjobhdr_sql.jobno 
		AND status = 'P'
		AND ccjobhdr_sql.JOBNO < 50000
	-- ===========================
	INNER JOIN	cccusitm_sql (NOLOCK) ON ccjoblin_sql.Item_No = cccusitm_sql.item_no 
	AND		ccjoblin_sql.customer = cccusitm_sql.cus_no
	AND		cccusitm_sql.versionno = (	SELECT	MAX(CONVERT(INT, versionno)) 
													FROM	cccusitm_sql (NOLOCK)
													WHERE	cccusitm_sql.Item_No = ccjoblin_sql.item_no  
													AND		cccusitm_sql.cus_no = ccjoblin_sql.customer)

	-- ////////SE REALIZA EL SELECT FINAL////////////////////////////////////////
	SELECT	SMPL.*,
			-- ===========================
			ISNULL(UPPER([MATERIAL_PROGRAMADO].ITEM_NO), 'N/E')  AS ITEM_NO_ETIQUETA,
			-- ===========================
			( CASE WHEN EVENTO_ACTUAL = 'FACTURADO' THEN 'FIN'
					ELSE (
			SELECT ISNULL(( SELECT TOP 1  D_KIT_RUTA_EVENTO
			FROM KIT_RUTA (NOLOCK)
			INNER JOIN KIT_RUTA_EVENTO (NOLOCK) ON KIT_RUTA_EVENTO.K_KIT_RUTA_EVENTO = KIT_RUTA.K_KIT_RUTA_EVENTO
			WHERE KIT_RUTA.ITEM_NO = SMPL.ITEM_NO
			AND KIT_RUTA.MODELNO = SMPL.MODEL_NO
			AND KIT_RUTA.VERSIONNO = SMPL.VERSION_NO
			AND KIT_RUTA.O_KIT_RUTA_EVENTO > (	SELECT  KIT_RUTA.O_KIT_RUTA_EVENTO
												FROM KIT_RUTA (NOLOCK)
												INNER JOIN KIT_RUTA_EVENTO (NOLOCK) ON KIT_RUTA_EVENTO.K_KIT_RUTA_EVENTO = KIT_RUTA.K_KIT_RUTA_EVENTO
												WHERE KIT_RUTA.ITEM_NO = SMPL.ITEM_NO
												AND KIT_RUTA.MODELNO = SMPL.MODEL_NO
												AND KIT_RUTA.VERSIONNO = SMPL.VERSION_NO
												AND KIT_RUTA.K_KIT_RUTA_EVENTO = (	SELECT TOP 1 K_TIPO_EVENTO_KIT 
																					FROM [MATERIAL_PROGRAMADO] (NOLOCK)
																					WHERE SERIAL = SMPL.SERIAL))), 'N/E' )) END )  AS EVENTO_SIGUIENTE,
			-- ===========================
			ISNULL(CONVERT(DATE, [MATERIAL_PROGRAMADO].F_EVENTO), CONVERT(DATE, GETDATE()))  AS F_EVENTO
			-- ===========================
	FROM @TBL_SEGUIMIENTO_MATERIAL_PROGRAMADO_LOG AS SMPL
	LEFT JOIN  [MATERIAL_PROGRAMADO] (NOLOCK) ON SMPL.SERIAL = [MATERIAL_PROGRAMADO].SERIAL
	-- ===========================
	WHERE SMPL.JOBNO = @PP_ORDEN
	-- ===========================
	ORDER BY SER_NO
	-- ////////////////////////////////////////////////
GO





-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////
-- USE DATA_02
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_RUTA_KIT]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_RUTA_KIT]
GO
/*
 EXEC	[dbo].[PG_LI_RUTA_KIT] 0,0, 'PTLFSCLWLNPA5', 'wtl', '0013'
 EXEC	[dbo].[PG_LI_RUTA_KIT] 0,0, 'PWLDFCLWLCPX7', 'WDL', '0012'
    
*/

CREATE PROCEDURE [dbo].[PG_LI_RUTA_KIT]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	@PP_KIT							VARCHAR(50),
	@PP_MODELO						VARCHAR(50),
	@PP_VERSION						VARCHAR(50)
AS
	
	SELECT D_KIT_RUTA_EVENTO, 
	KIT_RUTA.* 
	FROM KIT_RUTA (NOLOCK)
	INNER JOIN KIT_RUTA_EVENTO (NOLOCK) ON KIT_RUTA_EVENTO.K_KIT_RUTA_EVENTO = KIT_RUTA.K_KIT_RUTA_EVENTO
	WHERE ITEM_NO = @PP_KIT
	AND MODELNO = @PP_MODELO
	AND VERSIONNO = @PP_VERSION
	ORDER BY O_KIT_RUTA_EVENTO
	-- ////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> RN_EXISTE
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_GET_DATO_ETIQUETA_KIT]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_GET_DATO_ETIQUETA_KIT]
GO
/*
 EXEC [dbo].[PG_GET_DATO_ETIQUETA_KIT] 0, 0, 'RPMRAQBLNRUPD2,Q30-S11601005*184983C%MAGN03#PRA@66611'
 EXEC [dbo].[PG_GET_DATO_ETIQUETA_KIT] 0, 0, 'RUWD2TFBCNPLV5,Q30-S06259008~06258*186132A%MAGN03#WDM@12345!54321'
 EXEC [dbo].[PG_GET_DATO_ETIQUETA_KIT] 0, 0, 'RPJLFCRLMCKTX7,Q30-S11836002*2532932BQW-AD%IRVI02#JJL@33071'
*/
CREATE PROCEDURE [dbo].[PG_GET_DATO_ETIQUETA_KIT]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================	
	@PP_ETIQUETA_EMBARQUE		VARCHAR(100),
	-- ===========================		
	@OU_PART_NO					VARCHAR(50) OUTPUT,
	@OU_QTY						VARCHAR(50) OUTPUT,
	@OU_SERIAL_1				VARCHAR(50) OUTPUT,
	@OU_SERIAL_2				VARCHAR(50) OUTPUT,
	@OU_CUSTNO					VARCHAR(50) OUTPUT,
	@OU_CLIENTE					VARCHAR(50) OUTPUT,
	@OU_PRODUCT_CAT				VARCHAR(50) OUTPUT,
	@OU_LOTE_1					VARCHAR(50) OUTPUT,
	@OU_LOTE_2					VARCHAR(50) OUTPUT
AS
	
	DECLARE @VP_PART_NO	VARCHAR(50) = '', @VP_QTY VARCHAR(50) = '', @VP_SERIAL_1 VARCHAR(50) = '';
	DECLARE @VP_SERIAL_2 VARCHAR(50) = '', @VP_CUSTNO VARCHAR(50) = '' , @VP_CLIENTE VARCHAR(50) = '';
	DECLARE @VP_PRODUCT_CAT VARCHAR(50) = '' , @VP_LOTE_1 VARCHAR(50) = '', @VP_LOTE_2 VARCHAR(50) = ''; 

	DECLARE @VP_DELIMITADOR			VARCHAR(5) = ''
	DECLARE @VP_POSICION_COMA		INT = 0
	DECLARE @VP_POSICION_GUION		INT = 0
	DECLARE @VP_POSICION_ASTERISCO	INT = 0 
	DECLARE @VP_POSICION_PORCENTAJE INT = 0
	DECLARE @VP_POSICION_NUMERAL	INT = 0
	DECLARE @VP_POSICION_ARROBA		INT = 0
	DECLARE @VP_POSICION_TILDE		INT = 0
	DECLARE @VP_POSICION_ADMIRACION	INT = 0

	-- /////////////////////////////////////////////////////
	IF SUBSTRING(@PP_ETIQUETA_EMBARQUE,1,1) = 'R'
		SET @PP_ETIQUETA_EMBARQUE = SUBSTRING(@PP_ETIQUETA_EMBARQUE, 2,LEN(@PP_ETIQUETA_EMBARQUE))


	IF SUBSTRING(@PP_ETIQUETA_EMBARQUE,1,1) = 'P'
		BEGIN
			---------------------OBTENER Part No-----------------------------------------------
			SET @VP_DELIMITADOR = ','
			SET @VP_POSICION_COMA  = CHARINDEX(@VP_DELIMITADOR, @PP_ETIQUETA_EMBARQUE)
			
			SET @VP_PART_NO  = SUBSTRING(@PP_ETIQUETA_EMBARQUE, 1,@VP_POSICION_COMA - 1)
			
			 ----------------------OBTENER Qty--------------------------------------
			SET @VP_DELIMITADOR = '-'
			SET @VP_POSICION_GUION = CHARINDEX(@VP_DELIMITADOR, @PP_ETIQUETA_EMBARQUE)
			
			SET @VP_QTY =  SUBSTRING(@PP_ETIQUETA_EMBARQUE, (1 + @VP_POSICION_COMA), (@VP_POSICION_GUION - (@VP_POSICION_COMA + 1)))
			SET @VP_QTY =  SUBSTRING(@VP_QTY,2,10)

			 -------------------------OBTENER SERIAL---------------------------------------------------------------------------------
			SET @VP_DELIMITADOR = '*'
			SET @VP_POSICION_ASTERISCO = CHARINDEX(@VP_DELIMITADOR, @PP_ETIQUETA_EMBARQUE)
			
			SET @VP_SERIAL_1 = SUBSTRING(@PP_ETIQUETA_EMBARQUE, (1 + @VP_POSICION_GUION), (@VP_POSICION_ASTERISCO - (@VP_POSICION_GUION + 1)))
			
			 -------------------------OBTENER CUSTNO---------------------------------------------------------------------------------
			SET @VP_DELIMITADOR = '%'
			SET @VP_POSICION_PORCENTAJE = CHARINDEX(@VP_DELIMITADOR, @PP_ETIQUETA_EMBARQUE)
			
			SET @VP_CUSTNO = SUBSTRING(@PP_ETIQUETA_EMBARQUE, (1 + @VP_POSICION_ASTERISCO), (@VP_POSICION_PORCENTAJE - (@VP_POSICION_ASTERISCO + 1)))

			 -------------------------OBTENER CLIENTE---------------------------------------------------------------------------------
			SET @VP_DELIMITADOR = '#'
			SET @VP_POSICION_NUMERAL = CHARINDEX(@VP_DELIMITADOR, @PP_ETIQUETA_EMBARQUE)
			
			SET @VP_CLIENTE = SUBSTRING(@PP_ETIQUETA_EMBARQUE, (1 + @VP_POSICION_PORCENTAJE), (@VP_POSICION_NUMERAL - (@VP_POSICION_PORCENTAJE + 1)))

			-------------------------OBTENER PRODUCT CAT---------------------------------------------------------------------------------
			SET @VP_DELIMITADOR = '@'
			SET @VP_POSICION_ARROBA = CHARINDEX(@VP_DELIMITADOR, @PP_ETIQUETA_EMBARQUE)
			
			SET @VP_PRODUCT_CAT = SUBSTRING(@PP_ETIQUETA_EMBARQUE, (1 + @VP_POSICION_NUMERAL), (@VP_POSICION_ARROBA - (@VP_POSICION_NUMERAL + 1)))

			 -------------------------OBTENER LOTE_1---------------------------------------------------------------------------------

			SET @VP_LOTE_1 = SUBSTRING(@PP_ETIQUETA_EMBARQUE, (1 + @VP_POSICION_ARROBA), 10)
		END
	ELSE
		BEGIN
			---------------------OBTENER Part No-----------------------------------------------
			SET @VP_DELIMITADOR = ','
			SET @VP_POSICION_COMA  = CHARINDEX(@VP_DELIMITADOR, @PP_ETIQUETA_EMBARQUE)
			
			SET @VP_PART_NO  = SUBSTRING(@PP_ETIQUETA_EMBARQUE, 1,@VP_POSICION_COMA - 1)
			
			 ----------------------OBTENER Qty--------------------------------------
			SET @VP_DELIMITADOR = '-'
			SET @VP_POSICION_GUION = CHARINDEX(@VP_DELIMITADOR, @PP_ETIQUETA_EMBARQUE)
			
			SET @VP_QTY =  SUBSTRING(@PP_ETIQUETA_EMBARQUE, (1 + @VP_POSICION_COMA), (@VP_POSICION_GUION - (@VP_POSICION_COMA + 1)))
			SET @VP_QTY =  SUBSTRING(@VP_QTY,2,10)
			 -------------------------OBTENER SERIAL_1---------------------------------------------------------------------------------
			SET @VP_DELIMITADOR = '~'
			SET @VP_POSICION_TILDE = CHARINDEX(@VP_DELIMITADOR, @PP_ETIQUETA_EMBARQUE)
			
			SET @VP_SERIAL_1 = SUBSTRING(@PP_ETIQUETA_EMBARQUE, (1 + @VP_POSICION_GUION), (@VP_POSICION_TILDE - (@VP_POSICION_GUION + 1)))
			
			 -------------------------OBTENER SERIAL_2---------------------------------------------------------------------------------
			SET @VP_DELIMITADOR = '*'
			SET @VP_POSICION_ASTERISCO = CHARINDEX(@VP_DELIMITADOR, @PP_ETIQUETA_EMBARQUE)
			
			SET @VP_SERIAL_2 = SUBSTRING(@PP_ETIQUETA_EMBARQUE, (1 + @VP_POSICION_TILDE), (@VP_POSICION_ASTERISCO - (@VP_POSICION_TILDE + 1)))
			
			 -------------------------OBTENER CUSTNO---------------------------------------------------------------------------------
			SET @VP_DELIMITADOR = '%'
			SET @VP_POSICION_PORCENTAJE = CHARINDEX(@VP_DELIMITADOR, @PP_ETIQUETA_EMBARQUE)
			
			SET @VP_CUSTNO = SUBSTRING(@PP_ETIQUETA_EMBARQUE, (1 + @VP_POSICION_ASTERISCO), (@VP_POSICION_PORCENTAJE - (@VP_POSICION_ASTERISCO + 1)))

			 -------------------------OBTENER PRODUCT CLIENTE---------------------------------------------------------------------------------
			SET @VP_DELIMITADOR = '#'
			SET @VP_POSICION_NUMERAL = CHARINDEX(@VP_DELIMITADOR, @PP_ETIQUETA_EMBARQUE)
			
			SET @VP_CLIENTE = SUBSTRING(@PP_ETIQUETA_EMBARQUE, (1 + @VP_POSICION_PORCENTAJE), (@VP_POSICION_NUMERAL - (@VP_POSICION_PORCENTAJE + 1)))

			-------------------------OBTENER PRODUCT CATEGORY---------------------------------------------------------------------------------
			SET @VP_DELIMITADOR = '@'
			SET @VP_POSICION_ARROBA = CHARINDEX(@VP_DELIMITADOR, @PP_ETIQUETA_EMBARQUE)
			
			SET @VP_PRODUCT_CAT = SUBSTRING(@PP_ETIQUETA_EMBARQUE, (1 + @VP_POSICION_NUMERAL), (@VP_POSICION_ARROBA - (@VP_POSICION_NUMERAL + 1)))

			-------------------------OBTENER LOTE 1---------------------------------------------------------------------------------
			SET @VP_DELIMITADOR = '!'
			SET @VP_POSICION_ADMIRACION = CHARINDEX(@VP_DELIMITADOR, @PP_ETIQUETA_EMBARQUE)
			
			SET @VP_LOTE_1 = SUBSTRING(@PP_ETIQUETA_EMBARQUE, (1 + @VP_POSICION_ARROBA), (@VP_POSICION_ADMIRACION - (@VP_POSICION_ARROBA + 1)))

			 -------------------------OBTENER LOTE 2---------------------------------------------------------------------------------
			SET @VP_LOTE_2 = SUBSTRING(@PP_ETIQUETA_EMBARQUE, (1 + @VP_POSICION_ADMIRACION), 10)
						
		END		
	
	--SELECT	@VP_PART_NO		AS 'ITEM NO',		
	--		@VP_QTY			AS 'CANTIDAD',	
	--		@VP_SERIAL_1	AS 'SERIAL 1',		
	--		@VP_SERIAL_2	AS 'SERIAL 2',		
	--		@VP_CUSTNO		AS 'CUS NO',			
	--		@VP_CLIENTE		AS 'CLIENTE',			
	--		@VP_PRODUCT_CAT AS 'PROD CAT',		
	--		@VP_LOTE_1		AS 'LOTE 1',			
	--		@VP_LOTE_2		AS 'LOTE 2'		

	SET @OU_PART_NO		 =	@VP_PART_NO			
	SET @OU_QTY			 =	@VP_QTY			
	SET @OU_SERIAL_1	 =	SUBSTRING(@VP_SERIAL_1, 2, LEN(@VP_SERIAL_1)) --@VP_SERIAL_1	SE QUITA LA S DEL SERIAL
	SET @OU_SERIAL_2	 =	@VP_SERIAL_2	
	SET	@OU_CUSTNO		 =  @VP_CUSTNO		
	SET	@OU_CLIENTE		 =  @VP_CLIENTE		
	SET	@OU_PRODUCT_CAT	 =  @VP_PRODUCT_CAT 
	SET	@OU_LOTE_1		 =  @VP_LOTE_1		
	SET	@OU_LOTE_2		 =  @VP_LOTE_2		

	-- /////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////
-- USE [DATA_02]
-- GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RPT_MATERIAL_PROGRAMADO_ESCANEADO_X_EVENTO_TURNO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RPT_MATERIAL_PROGRAMADO_ESCANEADO_X_EVENTO_TURNO]
GO
/*
 EXEC	[dbo].[PG_RPT_MATERIAL_PROGRAMADO_ESCANEADO_X_EVENTO_TURNO] 0,144,  '2021/07/05' , '2021/07/05' , '( TODOS )' , 400 , -1 -- CERTIFICACION
    
*/

CREATE PROCEDURE [dbo].[PG_RPT_MATERIAL_PROGRAMADO_ESCANEADO_X_EVENTO_TURNO]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	--========================================
	@PP_F_INICIO					DATE,
	@PP_F_FIN						DATE,
	@PP_CLIENTE						VARCHAR(50),
	--@PP_MODELO						VARCHAR(50),
	@PP_EVENTO						INT,
	@PP_TURNO						VARCHAR(50)
AS
	
	DECLARE @TBL_MATERIAL_ESCANEADO TABLE(
		ID							INT IDENTITY(1,1),
		CLIENTE						VARCHAR(50),
		MODELO						VARCHAR(50),
		ITEM_NO						VARCHAR(50),
		CUS_ITEM_NO					VARCHAR(50),
		SERIAL						VARCHAR(50),
		CANTIDAD_PATRON				INT,
		CANTIDAD_PIEZA_X_PATRON		INT,
		EVENTO						VARCHAR(50),
		F_EVENTO					DATE,
		TURNO						INT
	)

	INSERT INTO @TBL_MATERIAL_ESCANEADO
	SELECT DISTINCT 
		LTRIM(RTRIM(ccjoblin_sql.customer))		AS CUSTOMER,
		LTRIM(RTRIM(cccusitm_sql.modelno))		AS MODEL_NO,
		[MATERIAL_PROGRAMADO_LOG].ITEM_NO, 
		LTRIM(RTRIM(cccusitm_sql.cus_item_no))	AS CUS_ITEM_NO,
		SERIAL, 
		2 AS CANTIDAD_PATRON,
		CONVERT(INT,ccjoblin_sql.originalqty)	AS ORIGINAL_QTY, 
		D_KIT_RUTA_EVENTO AS EVENTO, 
		CONVERT(DATE,F_LOG) AS F_EVENTO,
		( CASE WHEN FORMAT(CAST(F_LOG AS TIME(0)), N'hhmmss') > 2000 AND FORMAT(CAST(F_LOG AS TIME(0)), N'hhmmss')  < 60002  THEN 3
				WHEN FORMAT(CAST(F_LOG AS TIME(0)), N'hhmmss') > 60001 AND FORMAT(CAST(F_LOG AS TIME(0)), N'hhmmss')  < 153001 THEN 1
				ELSE 2 END ) AS TURNO
	FROM [MATERIAL_PROGRAMADO_LOG] (NOLOCK) 
	INNER JOIN KIT_RUTA_EVENTO (NOLOCK) ON K_KIT_RUTA_EVENTO = K_TIPO_EVENTO_KIT
	INNER JOIN ccjoblin_sql (NOLOCK) ON (LTRIM(RTRIM(ccjoblin_sql.jobno)) + RIGHT('000'+ CONVERT(VARCHAR(10),ser_no), 3)) = SERIAL
	-- ===========================
	INNER JOIN	cccusitm_sql (NOLOCK) ON ccjoblin_sql.Item_No = cccusitm_sql.item_no 
	AND		ccjoblin_sql.customer = cccusitm_sql.cus_no
	AND		cccusitm_sql.versionno = (	SELECT	MAX(CONVERT(INT, versionno)) 
													FROM	cccusitm_sql (NOLOCK)
													WHERE	cccusitm_sql.Item_No = ccjoblin_sql.item_no  
													AND		cccusitm_sql.cus_no = ccjoblin_sql.customer)
	-- ===========================
	WHERE K_TIPO_EVENTO_KIT  = @PP_EVENTO
	AND CONVERT(DATE, F_LOG) >= @PP_F_INICIO
	AND CONVERT(DATE, F_LOG) <= @PP_F_FIN
	-- ===========================
	AND LTRIM(RTRIM(ccjoblin_sql.customer)) = ( CASE WHEN @PP_CLIENTE <> '( TODOS )' THEN @PP_CLIENTE
													ELSE LTRIM(RTRIM(ccjoblin_sql.customer)) END )
	-- ===========================
	--AND LTRIM(RTRIM(cccusitm_sql.modelno)) = ( CASE WHEN @PP_MODELO <> '( TODOS )' THEN @PP_MODELO
	--														ELSE LTRIM(RTRIM(cccusitm_sql.modelno)) END )
	-- ////////////////////////////////////////////////
	SELECT CLIENTE,				
		   MODELO,					
		   ITEM_NO,	
		   CUS_ITEM_NO,	
		   SERIAL,				
		   CANTIDAD_PATRON,			
		   CANTIDAD_PIEZA_X_PATRON,	
		   (CANTIDAD_PATRON * CANTIDAD_PIEZA_X_PATRON ) AS TOTAL_PIEZAS,
		   EVENTO,					
		   F_EVENTO,				
		   TURNO		 
	FROM @TBL_MATERIAL_ESCANEADO
	WHERE TURNO = ( CASE WHEN @PP_TURNO <> -1 THEN @PP_TURNO
						ELSE TURNO END )
	ORDER BY F_EVENTO, TURNO, CLIENTE, MODELO

	-- ////////////////////////////////////////////////
GO





-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////
-- USE [DATA_02]
-- GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RPT_SQF_POR_COLOR_X_EVENTO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RPT_SQF_POR_COLOR_X_EVENTO]
GO
/*
 EXEC	[dbo].[PG_RPT_SQF_POR_COLOR_X_EVENTO] 0,144, 'FMCKTX7'
 EXEC	[dbo].[PG_RPT_SQF_POR_COLOR_X_EVENTO] 0,144, 'FWLNPX7'
    
*/

CREATE PROCEDURE [dbo].[PG_RPT_SQF_POR_COLOR_X_EVENTO]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	--========================================
	@PP_COLOR						VARCHAR(50)
AS
	
	-- //////////SE CREA TABLA TEMPORAL PARA GUARDAR LOS SQF TRANFERIDOS A LAS ORDENES/////////////////////////////////
	DECLARE @TBL_SQF_EN_ORDEN_ABIERTA TABLE(
				--LOTE				VARCHAR(20),
				--SQF_TRANSFER		DECIMAL(13,4),
				ORDEN				VARCHAR(50)
			)
	SET NOCOUNT ON

	-- //////////SE DECLARAN LAS VARIABLES A USAR/////////////////////////////////
	--DECLARE @VP_LOTE VARCHAR(20) = '', @VP_LEVEL VARCHAR(20) = '', @VP_DOC_TYPE VARCHAR(5) = '', @VP_DOC_ORD_NO	VARCHAR(10) = '';
	--DECLARE @VP_TRX_QTY DECIMAL(13,4) = 0, @VP_SQF_TRANSFERIDO DECIMAL(13,4) = 0, @VP_ORDEN VARCHAR(50), @VP_LOCACION VARCHAR(50);
		
	--DECLARE CU_ORDENES_ABIERTAS CURSOR 
	--FOR	SELECT DISTINCT LTRIM(RTRIM(CCJOBHDR_SQL.jobno)), LTRIM(RTRIM(LOC))
	--FROM  CCJOBHDR_SQL(NOLOCK)
	--INNER JOIN CCJOBLIN_SQL (NOLOCK) ON ccjobhdr_sql.jobno = ccjoblin_sql.jobno
	--INNER JOIN imlocfil_sql (NOLOCK) ON imlocfil_sql.loc_desc = CCJOBHDR_SQL.MACHINE
	--WHERE CONCAT('F', RIGHT(LTRIM(RTRIM(ITEM_NO)),6)) = @PP_COLOR
	--AND status = 'P'
	--AND ccjobhdr_sql.JOBNO < 50000
	--AND FOLIO IS NOT NULL

	--OPEN CU_ORDENES_ABIERTAS
	--FETCH NEXT FROM CU_ORDENES_ABIERTAS INTO @VP_ORDEN, @VP_LOCACION

	--WHILE @@FETCH_STATUS = 0
	--	BEGIN
	--		DECLARE CU_SQF_EN_ORDEN_ABIERTA CURSOR 
	--		FOR	SELECT IMLSTRX_SQL.ser_lot_no, IMLSTRX_SQL.lev_no, IMINVTRX_SQL.doc_type, LTRIM(RTRIM(IMINVTRX_SQL.doc_ord_no)), IMLSTRX_SQL.trx_qty
	--			-- ===========================
	--			 FROM IMLSTRX_SQL (NOLOCK)
	--				-- ===========================
	--				INNER JOIN IMINVTRX_SQL (NOLOCK) ON IMLSTRX_SQL.source = IMINVTRX_SQL.source 
	--					AND IMLSTRX_SQL.ord_no = IMINVTRX_SQL.ord_no 
	--			     AND IMLSTRX_SQL.ctl_no = IMINVTRX_SQL.ctl_no 
	--			     AND IMLSTRX_SQL.line_no = IMINVTRX_SQL.line_no 
	--			     AND IMLSTRX_SQL.lev_no = IMINVTRX_SQL.lev_no 
	--			     AND IMLSTRX_SQL.seq_no = IMINVTRX_SQL.seq_no
	--			-- ===========================
	--			 WHERE IMINVTRX_SQL.item_no = @PP_COLOR
	--			 AND LTRIM(RTRIM(IMINVTRX_SQL.loc)) = @VP_LOCACION
	--			 -- ===========================
	--			 AND (	LTRIM(RTRIM(IMINVTRX_SQL.doc_ord_no)) = @VP_ORDEN
	--					OR	LTRIM(RTRIM(IMINVTRX_SQL.doc_ord_no)) = 'J' + @VP_ORDEN
	--					OR	LTRIM(RTRIM(IMINVTRX_SQL.doc_ord_no)) = @VP_ORDEN
	--					)
	--			-- ===========================  
	--			ORDER BY IMLSTRX_SQL.ser_lot_no, IMINVTRX_SQL.lev_no DESC
	--		-- ///////////////////////////////////////////
					
	--		OPEN CU_SQF_EN_ORDEN_ABIERTA
	--		FETCH NEXT FROM CU_SQF_EN_ORDEN_ABIERTA INTO @VP_LOTE, @VP_LEVEL, @VP_DOC_TYPE, @VP_DOC_ORD_NO, @VP_TRX_QTY
					
	--		WHILE @@FETCH_STATUS = 0
	--			BEGIN
	--				-- ///////////////////////////////////////////
	--				DECLARE @VP_LOTE_ACTUAL VARCHAR(20) = @VP_LOTE

	--				-- /////////// TRANSFERENCIA A LA ORDEN ///////////////////////
	--				IF @VP_DOC_TYPE = 'R' --AND SUBSTRING(@VP_DOC_ORD_NO, 1, 1) <> 'J'
	--					BEGIN
	--						SET @VP_SQF_TRANSFERIDO = @VP_SQF_TRANSFERIDO + @VP_TRX_QTY
	--					END

	--				IF @VP_DOC_TYPE = 'I' --AND SUBSTRING(@VP_DOC_ORD_NO, 1, 1) <> 'J'
	--					BEGIN
	--					 SET @VP_SQF_TRANSFERIDO = @VP_SQF_TRANSFERIDO - @VP_TRX_QTY 
	--					END

	--				IF @VP_DOC_TYPE = 'T' AND @VP_LEVEL = 1
	--					BEGIN
	--						SET @VP_SQF_TRANSFERIDO = @VP_SQF_TRANSFERIDO + @VP_TRX_QTY
	--					END

	--				IF @VP_DOC_TYPE = 'T' AND @VP_LEVEL = 0
	--					BEGIN
	--					 SET @VP_SQF_TRANSFERIDO = @VP_SQF_TRANSFERIDO - @VP_TRX_QTY 
	--					END

	--				-- ///////////////////////////////////////////
	--				FETCH NEXT FROM CU_SQF_EN_ORDEN_ABIERTA INTO @VP_LOTE, @VP_LEVEL, @VP_DOC_TYPE, @VP_DOC_ORD_NO, @VP_TRX_QTY

	--				-- ///////////////////////////////////////////
	--				IF ( @VP_LOTE_ACTUAL <> @VP_LOTE OR @@FETCH_STATUS <> 0 )
	--					BEGIN
	--						INSERT INTO @TBL_SQF_EN_ORDEN_ABIERTA
	--						SELECT	RIGHT( '000000' + @VP_LOTE_ACTUAL, 6),
	--								@VP_SQF_TRANSFERIDO,
	--								@VP_ORDEN

	--						SET @VP_SQF_TRANSFERIDO = 0
	--					END
	--			END
			
	--		CLOSE CU_SQF_EN_ORDEN_ABIERTA
	--		DEALLOCATE CU_SQF_EN_ORDEN_ABIERTA	

	--	FETCH NEXT FROM CU_ORDENES_ABIERTAS INTO @VP_ORDEN, @VP_LOCACION

	--END
		
	--CLOSE CU_ORDENES_ABIERTAS
	--DEALLOCATE CU_ORDENES_ABIERTAS	

	---- ///////SE OBTIENEN LAS ORDENES ABIERTAS EN PRD///////////////////////////////////////////////////////
	INSERT INTO @TBL_SQF_EN_ORDEN_ABIERTA
	SELECT LTRIM(RTRIM(JOBNO)) 
	FROM ccjobhdr_sql (NOLOCK)
	WHERE status = 'P' 
	AND CONCAT('F',LTRIM(RTRIM(COLOUR))) = @PP_COLOR
	AND FOLIO IS NOT NULL

	---- ///////SE OBTIENE EL TOTAL DE SQF TRANSFERIDO A LA MESA DEL COLOR///////////////////////////////////////////////////////
	DECLARE @VP_SQF_TRANSFERIDO_PRD DECIMAL(13,4) = 0
	--SELECT @VP_SQF_TRANSFERIDO_PRD = SUM(SQF_TRANSFER)
	--FROM @TBL_SQF_EN_ORDEN_ABIERTA
	--WHERE SQF_TRANSFER > 0

	SELECT @VP_SQF_TRANSFERIDO_PRD = SUM(qty_on_hand) 
	FROM IMINVLOC_SQL (NOLOCK)
	WHERE LTRIM(RTRIM(item_no)) = @PP_COLOR
	AND LOC LIKE 'T%' 
	AND qty_on_hand > 0

	IF @VP_SQF_TRANSFERIDO_PRD IS NULL 
		SET @VP_SQF_TRANSFERIDO_PRD = 0

	---- ///////SE OBTIENE EL TOTAL DE SQF EN INSPECCION DE CORTE #30///////////////////////////////////////////////////////
	DECLARE @VP_TOTAL_SQF_INSP_CORTE DECIMAL(13,4) = 0, @VP_N_KIT_INSP_CORTE INT = 0
	SELECT  @VP_TOTAL_SQF_INSP_CORTE	=	SUM(CONVERT(DECIMAL(13,4),(OriginalQty * stdsqmper))),
			@VP_N_KIT_INSP_CORTE = COUNT(SER_NO)
	FROM  CCJOBLIN_SQL (NOLOCK) 
	WHERE JOBNO IN (SELECT DISTINCT ORDEN FROM @TBL_SQF_EN_ORDEN_ABIERTA)
	AND LTRIM(RTRIM(ccjoblin_sql.jobno)) + RIGHT('000'+ LTRIM(RTRIM(ser_no)),3)  IN ( SELECT DISTINCT SERIAL 
																						FROM [MATERIAL_PROGRAMADO] (NOLOCK)
																						WHERE CONCAT('F', RIGHT(LTRIM(RTRIM(ITEM_NO)),6)) = @PP_COLOR AND K_TIPO_EVENTO_KIT = 30)
	
	IF @VP_TOTAL_SQF_INSP_CORTE IS NULL 
		SET @VP_TOTAL_SQF_INSP_CORTE = 0

	IF @VP_N_KIT_INSP_CORTE IS NULL 
		SET @VP_N_KIT_INSP_CORTE = 0

	---- ///////SE OBTIENE EL TOTAL DE SQF EN SKIVING #200///////////////////////////////////////////////////////
	DECLARE @VP_TOTAL_SQF_SKIVING DECIMAL(13,4) = 0, @VP_N_KIT_SKIVING INT = 0
	SELECT  @VP_TOTAL_SQF_SKIVING	=	SUM(CONVERT(DECIMAL(13,4),(OriginalQty * stdsqmper))),
			@VP_N_KIT_SKIVING = COUNT(Ser_No)
	FROM  CCJOBLIN_SQL (NOLOCK) 
	WHERE JOBNO IN ( SELECT DISTINCT ORDEN FROM @TBL_SQF_EN_ORDEN_ABIERTA )
	AND LTRIM(RTRIM(ccjoblin_sql.jobno)) + RIGHT('000'+ LTRIM(RTRIM(ser_no)),3)  IN ( SELECT DISTINCT SERIAL 
																						FROM [MATERIAL_PROGRAMADO] (NOLOCK)
																						WHERE CONCAT('F', RIGHT(LTRIM(RTRIM(ITEM_NO)),6)) = @PP_COLOR AND K_TIPO_EVENTO_KIT = 200)
	
	IF @VP_TOTAL_SQF_SKIVING IS NULL 
		SET @VP_TOTAL_SQF_SKIVING = 0

	IF @VP_N_KIT_SKIVING IS NULL 
		SET @VP_N_KIT_SKIVING = 0

	---- ///////SE OBTIENE EL TOTAL DE SQF EN RECUT #210///////////////////////////////////////////////////////
	DECLARE @VP_TOTAL_SQF_RECUT DECIMAL(13,4) = 0, @VP_N_KIT_RECUT INT = 0
	SELECT  @VP_TOTAL_SQF_RECUT	=	SUM(CONVERT(DECIMAL(13,4),(OriginalQty * stdsqmper))),
			@VP_N_KIT_RECUT = COUNT(Ser_No)
	FROM  CCJOBLIN_SQL (NOLOCK) 
	WHERE JOBNO IN ( SELECT DISTINCT ORDEN FROM @TBL_SQF_EN_ORDEN_ABIERTA )
	AND LTRIM(RTRIM(ccjoblin_sql.jobno)) + RIGHT('000'+ LTRIM(RTRIM(ser_no)),3)  IN ( SELECT DISTINCT SERIAL 
																						FROM [MATERIAL_PROGRAMADO] (NOLOCK)
																						WHERE CONCAT('F', RIGHT(LTRIM(RTRIM(ITEM_NO)),6)) = @PP_COLOR AND K_TIPO_EVENTO_KIT = 210)
	
	IF @VP_TOTAL_SQF_RECUT IS NULL 
		SET @VP_TOTAL_SQF_RECUT = 0

	IF @VP_N_KIT_RECUT IS NULL 
		SET @VP_N_KIT_RECUT = 0

	---- ///////SE OBTIENE EL TOTAL DE SQF EN LAMINACION #220///////////////////////////////////////////////////////
	DECLARE @VP_TOTAL_SQF_LAMINACION DECIMAL(13,4) = 0, @VP_N_KIT_LAMINACION INT = 0
	SELECT  @VP_TOTAL_SQF_LAMINACION	=	SUM(CONVERT(DECIMAL(13,4),(OriginalQty * stdsqmper))),
			@VP_N_KIT_LAMINACION = COUNT(Ser_No)
	FROM  CCJOBLIN_SQL (NOLOCK) 
	WHERE JOBNO IN ( SELECT DISTINCT ORDEN FROM @TBL_SQF_EN_ORDEN_ABIERTA )
	AND LTRIM(RTRIM(ccjoblin_sql.jobno)) + RIGHT('000'+ LTRIM(RTRIM(ser_no)),3)  IN ( SELECT DISTINCT SERIAL 
																						FROM [MATERIAL_PROGRAMADO] (NOLOCK)
																						WHERE CONCAT('F', RIGHT(LTRIM(RTRIM(ITEM_NO)),6)) = @PP_COLOR AND K_TIPO_EVENTO_KIT = 220)
	
	IF @VP_TOTAL_SQF_LAMINACION IS NULL 
		SET @VP_TOTAL_SQF_LAMINACION = 0

	IF @VP_N_KIT_LAMINACION IS NULL 
		SET @VP_N_KIT_LAMINACION = 0

	---- ///////SE OBTIENE EL TOTAL DE SQF EN PERFORACION #230///////////////////////////////////////////////////////
	DECLARE @VP_TOTAL_SQF_PERFORACION DECIMAL(13,4) = 0, @VP_N_KIT_PERFORACION INT = 0
	SELECT  @VP_TOTAL_SQF_PERFORACION	=	SUM(CONVERT(DECIMAL(13,4),(OriginalQty * stdsqmper))),
			@VP_N_KIT_PERFORACION = COUNT(SER_NO)
	FROM  CCJOBLIN_SQL (NOLOCK) 
	WHERE JOBNO IN ( SELECT DISTINCT ORDEN FROM @TBL_SQF_EN_ORDEN_ABIERTA )
	AND LTRIM(RTRIM(ccjoblin_sql.jobno)) + RIGHT('000'+ LTRIM(RTRIM(ser_no)),3)  IN ( SELECT DISTINCT SERIAL 
																						FROM [MATERIAL_PROGRAMADO] (NOLOCK)
																						WHERE CONCAT('F', RIGHT(LTRIM(RTRIM(ITEM_NO)),6)) = @PP_COLOR AND K_TIPO_EVENTO_KIT = 230)
	
	IF @VP_TOTAL_SQF_PERFORACION IS NULL 
		SET @VP_TOTAL_SQF_PERFORACION = 0

	IF @VP_N_KIT_PERFORACION IS NULL 
		SET @VP_N_KIT_PERFORACION = 0

	---- ///////SE OBTIENE EL TOTAL DE SQF EN QUILTING #240///////////////////////////////////////////////////////
	DECLARE @VP_TOTAL_SQF_QUILTING DECIMAL(13,4) = 0, @VP_N_KIT_QUILTING INT = 0
	SELECT  @VP_TOTAL_SQF_QUILTING	=	SUM(CONVERT(DECIMAL(13,4),(OriginalQty * stdsqmper))),
			@VP_N_KIT_QUILTING = COUNT(Ser_No)
	FROM  CCJOBLIN_SQL (NOLOCK) 
	WHERE JOBNO IN ( SELECT DISTINCT ORDEN FROM @TBL_SQF_EN_ORDEN_ABIERTA )
	AND LTRIM(RTRIM(ccjoblin_sql.jobno)) + RIGHT('000'+ LTRIM(RTRIM(ser_no)),3)  IN ( SELECT DISTINCT SERIAL 
																						FROM [MATERIAL_PROGRAMADO] (NOLOCK)
																						WHERE CONCAT('F', RIGHT(LTRIM(RTRIM(ITEM_NO)),6)) = @PP_COLOR AND K_TIPO_EVENTO_KIT = 240)
	
	IF @VP_TOTAL_SQF_QUILTING IS NULL 
		SET @VP_TOTAL_SQF_QUILTING = 0

	IF @VP_N_KIT_QUILTING IS NULL 
		SET @VP_N_KIT_QUILTING = 0

	---- ///////SE OBTIENE EL TOTAL DE SQF EN EMBOSSING #250///////////////////////////////////////////////////////
	DECLARE @VP_TOTAL_SQF_EMBOSSING DECIMAL(13,4) = 0, @VP_N_KIT_EMBOSSING INT = 0
	SELECT  @VP_TOTAL_SQF_EMBOSSING	=	SUM(CONVERT(DECIMAL(13,4),(OriginalQty * stdsqmper))),
			@VP_N_KIT_EMBOSSING = COUNT(Ser_No)
	FROM  CCJOBLIN_SQL (NOLOCK) 
	WHERE JOBNO IN ( SELECT DISTINCT ORDEN FROM @TBL_SQF_EN_ORDEN_ABIERTA )
	AND LTRIM(RTRIM(ccjoblin_sql.jobno)) + RIGHT('000'+ LTRIM(RTRIM(ser_no)),3)  IN ( SELECT DISTINCT SERIAL 
																						FROM [MATERIAL_PROGRAMADO] (NOLOCK)
																						WHERE CONCAT('F', RIGHT(LTRIM(RTRIM(ITEM_NO)),6)) = @PP_COLOR AND K_TIPO_EVENTO_KIT = 250)
	
	IF @VP_TOTAL_SQF_EMBOSSING IS NULL 
		SET @VP_TOTAL_SQF_EMBOSSING = 0

	IF @VP_N_KIT_EMBOSSING IS NULL 
		SET @VP_N_KIT_EMBOSSING = 0

	---- ///////SE OBTIENE EL TOTAL DE SQF EN INSP. PERFO. #300///////////////////////////////////////////////////////
	DECLARE @VP_TOTAL_SQF_INSP_PERFO DECIMAL(13,4) = 0, @VP_N_KIT_INSP_PERF INT = 0
	SELECT  @VP_TOTAL_SQF_INSP_PERFO	=	SUM(CONVERT(DECIMAL(13,4),(OriginalQty * stdsqmper))),
			@VP_N_KIT_INSP_PERF = COUNT(Ser_No)
	FROM  CCJOBLIN_SQL (NOLOCK) 
	WHERE JOBNO IN ( SELECT DISTINCT ORDEN FROM @TBL_SQF_EN_ORDEN_ABIERTA )
	AND LTRIM(RTRIM(ccjoblin_sql.jobno)) + RIGHT('000'+ LTRIM(RTRIM(ser_no)),3)  IN ( SELECT DISTINCT SERIAL 
																						FROM [MATERIAL_PROGRAMADO] (NOLOCK)
																						WHERE CONCAT('F', RIGHT(LTRIM(RTRIM(ITEM_NO)),6)) = @PP_COLOR AND K_TIPO_EVENTO_KIT = 300)
	
	IF @VP_TOTAL_SQF_INSP_PERFO IS NULL 
		SET @VP_TOTAL_SQF_INSP_PERFO = 0

	IF @VP_N_KIT_INSP_PERF IS NULL 
		SET @VP_N_KIT_INSP_PERF = 0

	---- ///////SE OBTIENE EL TOTAL DE SQF EN CERTIFICACION #400///////////////////////////////////////////////////////
	DECLARE @VP_TOTAL_SQF_CERTIFICACION DECIMAL(13,4) = 0, @VP_N_KIT_CERTIFICACION INT = 0
	SELECT  @VP_TOTAL_SQF_CERTIFICACION	=	SUM(CONVERT(DECIMAL(13,4),(OriginalQty * stdsqmper))),
			@VP_N_KIT_CERTIFICACION = COUNT(Ser_No)
	FROM  CCJOBLIN_SQL (NOLOCK) 
	WHERE JOBNO IN ( SELECT DISTINCT ORDEN FROM @TBL_SQF_EN_ORDEN_ABIERTA )
	AND LTRIM(RTRIM(ccjoblin_sql.jobno)) + RIGHT('000'+ LTRIM(RTRIM(ser_no)),3)  IN ( SELECT DISTINCT SERIAL 
																						FROM [MATERIAL_PROGRAMADO] (NOLOCK)
																						WHERE CONCAT('F', RIGHT(LTRIM(RTRIM(ITEM_NO)),6)) = @PP_COLOR AND K_TIPO_EVENTO_KIT = 400)
	
	IF @VP_TOTAL_SQF_CERTIFICACION IS NULL 
		SET @VP_TOTAL_SQF_CERTIFICACION = 0

	IF @VP_N_KIT_CERTIFICACION IS NULL 
		SET @VP_N_KIT_CERTIFICACION = 0

	---- ///////SE OBTIENE EL TOTAL DE SQF EN LIBERACION QC #410///////////////////////////////////////////////////////
	DECLARE @VP_TOTAL_SQF_LIBERACION_QC DECIMAL(13,4) = 0, @VP_N_KIT_LIBERACION_QC INT = 0
	SELECT  @VP_TOTAL_SQF_LIBERACION_QC	=	SUM(CONVERT(DECIMAL(13,4),(OriginalQty * stdsqmper))),
			@VP_N_KIT_LIBERACION_QC = COUNT(Ser_No)
	FROM  CCJOBLIN_SQL (NOLOCK) 
	WHERE JOBNO IN ( SELECT DISTINCT ORDEN FROM @TBL_SQF_EN_ORDEN_ABIERTA )
	AND LTRIM(RTRIM(ccjoblin_sql.jobno)) + RIGHT('000'+ LTRIM(RTRIM(ser_no)),3)  IN ( SELECT DISTINCT SERIAL 
																						FROM [MATERIAL_PROGRAMADO] (NOLOCK)
																						WHERE CONCAT('F', RIGHT(LTRIM(RTRIM(ITEM_NO)),6)) = @PP_COLOR AND K_TIPO_EVENTO_KIT = 410)
	
	IF @VP_TOTAL_SQF_LIBERACION_QC IS NULL 
		SET @VP_TOTAL_SQF_LIBERACION_QC = 0

	IF @VP_N_KIT_LIBERACION_QC IS NULL 
		SET @VP_N_KIT_LIBERACION_QC = 0

	---- ///////SE OBTIENE EL TOTAL DE SQF EN PRODUCTO TERMINADO///////////////////////////////////////////////////////
	DECLARE @VP_TOTAL_SQF_MFP DECIMAL(13,4) = 0, @VP_N_KIT_MFP INT = 0
	SELECT  @VP_TOTAL_SQF_MFP	=	SUM(CONVERT(DECIMAL(13,4),(OriginalQty * stdsqmper))),
			@VP_N_KIT_MFP = COUNT(SER_NO)
	FROM  CCJOBLIN_SQL (NOLOCK) 
	WHERE JOBNO IN (SELECT DISTINCT ORDEN FROM @TBL_SQF_EN_ORDEN_ABIERTA)
	AND LTRIM(RTRIM(ccjoblin_sql.jobno)) + RIGHT('000'+ LTRIM(RTRIM(ser_no)),3)  IN ( SELECT DISTINCT SERIAL_1 
																						FROM INVENTARIO_EMBARQUE (NOLOCK)
																						WHERE COLOR = @PP_COLOR AND K_ESTATUS_INVENTARIO_EMBARQUE IN (1,2))
	
	IF @VP_TOTAL_SQF_MFP IS NULL 
		SET @VP_TOTAL_SQF_MFP = 0

	IF @VP_N_KIT_MFP IS NULL 
		SET @VP_N_KIT_MFP = 0

	---- ///////SE OBTIENE EL TOTAL DE SQF ENVIADO O FACTURADO///////////////////////////////////////////////////////
	DECLARE @VP_TOTAL_SQF_FACTURADO DECIMAL(13,4) = 0, @VP_N_KIT_FACTURADO INT = 0
	SELECT  @VP_TOTAL_SQF_FACTURADO	=	SUM(CONVERT(DECIMAL(13,4),(OriginalQty * stdsqmper))),
			@VP_N_KIT_FACTURADO = COUNT(Ser_No)
	FROM  CCJOBLIN_SQL (NOLOCK) 
	WHERE JOBNO IN (SELECT DISTINCT ORDEN FROM @TBL_SQF_EN_ORDEN_ABIERTA)
	AND LTRIM(RTRIM(ccjoblin_sql.jobno)) + RIGHT('000'+ LTRIM(RTRIM(ser_no)),3)  IN ( SELECT DISTINCT SERIAL_1 
																						FROM INVENTARIO_EMBARQUE (NOLOCK)
																						WHERE COLOR = @PP_COLOR AND K_ESTATUS_INVENTARIO_EMBARQUE > 2)
	
	IF @VP_TOTAL_SQF_FACTURADO IS NULL 
		SET @VP_TOTAL_SQF_FACTURADO = 0
	
	IF @VP_N_KIT_FACTURADO IS NULL 
		SET @VP_N_KIT_FACTURADO = 0

	---- ///////SE OBTIENE EL TOTAL DE SQF EN LOS FOLIOS DEL COLOR///////////////////////////////////////////////////////
	--DECLARE @_SQF_EN_FOLIO DECIMAL(13,2) = 0
	--SELECT @_SQF_EN_FOLIO = SUM(CONVERT(DECIMAL(13,2),LTRIM(RTRIM(SQF)))) 
	--FROM RP_SC (NOLOCK)
	--INNER JOIN RP_FOLIOS (NOLOCK) ON RP_FOLIOS.TAG = RP_SC.TAGNO 
	--INNER JOIN CCJOBHDR_SQL (NOLOCK) ON CCJOBHDR_SQL.JOBNO = RP_FOLIOS.JOBNO
	--WHERE CCJOBHDR_SQL.JOBNO IN (SELECT DISTINCT ORDEN FROM @TBL_SQF_EN_ORDEN_ABIERTA)

	---- ///////SE OBTIENE EL TOTAL DE SQF EN PRODUCCION///////////////////////////////////////////////////////
	DECLARE @VP_SQF_EN_PRD DECIMAL(13,4) = 0

	SET @VP_SQF_EN_PRD = @VP_SQF_TRANSFERIDO_PRD - @VP_TOTAL_SQF_INSP_CORTE
	SET @VP_SQF_EN_PRD = @VP_SQF_EN_PRD - @VP_TOTAL_SQF_SKIVING
	SET @VP_SQF_EN_PRD = @VP_SQF_EN_PRD - @VP_TOTAL_SQF_RECUT
	SET @VP_SQF_EN_PRD = @VP_SQF_EN_PRD - @VP_TOTAL_SQF_LAMINACION
	SET @VP_SQF_EN_PRD = @VP_SQF_EN_PRD - @VP_TOTAL_SQF_PERFORACION
	SET @VP_SQF_EN_PRD = @VP_SQF_EN_PRD - @VP_TOTAL_SQF_QUILTING
	SET @VP_SQF_EN_PRD = @VP_SQF_EN_PRD - @VP_TOTAL_SQF_EMBOSSING
	SET @VP_SQF_EN_PRD = @VP_SQF_EN_PRD - @VP_TOTAL_SQF_INSP_PERFO
	SET @VP_SQF_EN_PRD = @VP_SQF_EN_PRD - @VP_TOTAL_SQF_CERTIFICACION
	SET @VP_SQF_EN_PRD = @VP_SQF_EN_PRD - @VP_TOTAL_SQF_LIBERACION_QC
	SET @VP_SQF_EN_PRD = @VP_SQF_EN_PRD - @VP_TOTAL_SQF_MFP
	SET @VP_SQF_EN_PRD = @VP_SQF_EN_PRD - @VP_TOTAL_SQF_FACTURADO

	---- ///////SE MUESTRA EL RESULTADO///////////////////////////////////////////////////////
	SELECT	@PP_COLOR						AS COLOR,
			@VP_SQF_TRANSFERIDO_PRD			AS SQF_TRASFERIDO_PRD,
			@VP_SQF_EN_PRD					AS SQF_PRD,
			--=================================================
			@VP_N_KIT_INSP_CORTE			AS N_KIT_INSP_CORTE,
			@VP_TOTAL_SQF_INSP_CORTE		AS SQF_INSP_CORTE,
			--=================================================
			@VP_N_KIT_SKIVING				AS N_KIT_SKIVING,
			@VP_TOTAL_SQF_SKIVING			AS SQF_SKIVING,
			--=================================================
			@VP_N_KIT_RECUT					AS N_KIT_RECUT,
			@VP_TOTAL_SQF_RECUT				AS SQF_RECUT,
			--=================================================
			@VP_N_KIT_LAMINACION			AS N_KIT_LAMINACION,
			@VP_TOTAL_SQF_LAMINACION		AS SQF_LAMINACION,
			--=================================================
			@VP_N_KIT_PERFORACION			AS N_KIT_PERFORACION,
			@VP_TOTAL_SQF_PERFORACION		AS SQF_PERFORACION,
			--=================================================
			@VP_N_KIT_QUILTING				AS N_KIT_QUILTING,
			@VP_TOTAL_SQF_QUILTING			AS SQF_QUILTING,
			--=================================================
			@VP_N_KIT_EMBOSSING				AS N_KIT_EMBOSSING,
			@VP_TOTAL_SQF_EMBOSSING			AS SQF_EMBOSSING,
			--=================================================
			@VP_N_KIT_INSP_PERF				AS N_KIT_INSP_PERF,
			@VP_TOTAL_SQF_INSP_PERFO		AS SQF_INSP_PERFO,
			--=================================================
			@VP_N_KIT_CERTIFICACION			AS N_KIT_CERTIFICACION,
			@VP_TOTAL_SQF_CERTIFICACION		AS SQF_CERTIFICACION,
			--=================================================
			@VP_N_KIT_LIBERACION_QC			AS N_KIT_LIBERACION_QC,
			@VP_TOTAL_SQF_LIBERACION_QC		AS SQF_LIBERACION_QC,
			--=================================================
			@VP_N_KIT_MFP					AS N_KIT_MFP,
			@VP_TOTAL_SQF_MFP				AS SQF_MFP,
			--=================================================
			@VP_N_KIT_FACTURADO				AS N_KIT_FACTURADO,
			@VP_TOTAL_SQF_FACTURADO			AS SQF_FACTURADO
			--=================================================
			
	-- ////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////
-- USE [DATA_02]
-- GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RPT_GERENCIA_SQF_EN_LOCACION_X_COLOR]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RPT_GERENCIA_SQF_EN_LOCACION_X_COLOR]
GO
/*
 EXEC	[dbo].[PG_RPT_GERENCIA_SQF_EN_LOCACION_X_COLOR] 0,144,  'FCNPWT5' 
    
*/

CREATE PROCEDURE [dbo].[PG_RPT_GERENCIA_SQF_EN_LOCACION_X_COLOR]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	--========================================
	@PP_COLOR						VARCHAR(50)
AS
	DECLARE @VP_SQF_TRANSFERIDO_PRD DECIMAL(13,4) = 0
	SELECT @VP_SQF_TRANSFERIDO_PRD = SUM(qty_on_hand) 
	FROM IMINVLOC_SQL (NOLOCK)
	WHERE LTRIM(RTRIM(item_no)) = @PP_COLOR
	AND LOC LIKE 'T%' 
	AND qty_on_hand > 0

	IF @VP_SQF_TRANSFERIDO_PRD IS NULL 
		SET @VP_SQF_TRANSFERIDO_PRD = 0
	
	SELECT @VP_SQF_TRANSFERIDO_PRD AS SQF_PRD, LTRIM(RTRIM(ITEM_NO)) AS COLOR, LTRIM(RTRIM(LOC)) AS LOCACION, qty_on_hand AS SQF 
	FROM IMINVLOC_SQL (NOLOCK)
	WHERE LTRIM(RTRIM(item_no)) = @PP_COLOR 
	AND qty_on_hand > 0
	AND loc <> ''
	ORDER BY LOCACION

	-- ////////////////////////////////////////////////
GO


