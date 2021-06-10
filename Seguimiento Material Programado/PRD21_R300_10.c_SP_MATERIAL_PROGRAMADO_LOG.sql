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
 EXEC	[dbo].[PG_LI_MATERIAL_PROGRAMADO_ESCANEADO_X_ESTACION] 0,0, 'CORTE_PRD', 'PRD-001'
    
*/

CREATE PROCEDURE [dbo].[PG_LI_MATERIAL_PROGRAMADO_ESCANEADO_X_ESTACION]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	@PP_USUARIO_EVENTO			VARCHAR(100),
	@PP_ESTACION				VARCHAR(100)
AS

	SELECT	SERIAL,  
			ITEM_NO,
			CODIGO_ETIQUETA,
			( CASE WHEN EP_NOMBRE IS NULL THEN 'N/E'
				ELSE CONCAT(EP_NOMBRE, ' ', EP_APELLIDO_PATERNO) END ) AS RESPONSABLE,
			F_LOG 
	FROM [MATERIAL_PROGRAMADO_LOG] (NOLOCK)
	LEFT JOIN HOWE.dbo.VISTA_GAFETES (NOLOCK) ON VISTA_GAFETES.EN_NUM_EMP = K_RESPONSABLE
	WHERE USUARIO_EVENTO =  @PP_USUARIO_EVENTO
	AND ESTACION = @PP_ESTACION
	AND CONVERT(DATE, F_LOG) = CONVERT(DATE, GETDATE())
	
	-- ////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_ESTATUS_X_SERIAL_ORDEN]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_ESTATUS_X_SERIAL_ORDEN]
GO

/*
												  (ORDEN)
 EXEC	[dbo].[PG_LI_ESTATUS_X_SERIAL_ORDEN] 0,0, '', '( TODOS )', '( TODOS )', '( TODOS )'
 EXEC	[dbo].[PG_LI_ESTATUS_X_SERIAL_ORDEN] 0,0, '32629', '( TODOS )', '( TODOS )', '( TODOS )'
 EXEC	[dbo].[PG_LI_ESTATUS_X_SERIAL_ORDEN] 0,0, '32630', '( TODOS )', '( TODOS )', '( TODOS )'
*/


CREATE PROCEDURE [dbo].[PG_LI_ESTATUS_X_SERIAL_ORDEN]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	@PP_BUSCAR						VARCHAR(150),
	@PP_CLIENTE						VARCHAR(50),
	@PP_MESA						VARCHAR(50),
	@PP_EVENTO_ACTUAL				VARCHAR(100)
AS

	DECLARE @TBL_SEGUIMIENTO_MATERIAL_PROGRAMADO_LOG AS TABLE(
			JOBNO				VARCHAR(50),
			SER_NO				INT,
			SERIAL				VARCHAR(50),
			KIT_DESC			VARCHAR(255),
			ORIGINAL_QTY		INT,
			CUSTOMER			VARCHAR(50),
			ITEM_NO				VARCHAR(100),
			ITEM_NO_ETIQUETA	VARCHAR(100),
			CUS_ITEM_NO			VARCHAR(100),
			MODEL_NO			VARCHAR(100),
			VERSION_NO			VARCHAR(100),
			MESA				VARCHAR(100),
			F_CREACION			DATE,
			EVENTO_ACTUAL		VARCHAR(100),
			EVENTO_SIGUIENTE	VARCHAR(100),
			F_EVENTO			DATE
	)

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
			ISNULL(( SELECT TOP 1 ITEM_NO
				FROM [MATERIAL_PROGRAMADO_LOG] (NOLOCK)
				WHERE SERIAL = LTRIM(RTRIM(ccjoblin_sql.jobno)) + RIGHT('000'+ CONVERT(VARCHAR(10),ser_no), 3)
				ORDER BY K_MATERIAL_PROGRAMADO_LOG DESC), 'N/E') AS ITEM_NO_ETIQUETA,
			-- ===========================
			LTRIM(RTRIM(cccusitm_sql.cus_item_no))	AS CUS_ITEM_NO,
			LTRIM(RTRIM(cccusitm_sql.modelno))		AS MODEL_NO,
			LTRIM(RTRIM(cccusitm_sql.versionno))	AS VERSION_NO,
			LTRIM(RTRIM(MACHINE))					AS MESA,
			[dbo].[CONVERT_INT_TO_DATE](ccjobhdr_sql.datecreated) AS F_CREACION,
			-- ===========================
			ISNULL(( SELECT TOP 1 D_KIT_RUTA_EVENTO
				FROM [MATERIAL_PROGRAMADO_LOG] (NOLOCK)
				INNER JOIN KIT_RUTA_EVENTO (NOLOCK) ON KIT_RUTA_EVENTO.K_KIT_RUTA_EVENTO = [MATERIAL_PROGRAMADO_LOG].K_TIPO_EVENTO_KIT
				WHERE SERIAL = LTRIM(RTRIM(ccjoblin_sql.jobno)) + RIGHT('000'+ CONVERT(VARCHAR(10),ser_no), 3) 
				ORDER BY K_MATERIAL_PROGRAMADO_LOG DESC), 'PENDIENTE') AS EVENTO_ACTUAL,
			-- ===========================
			ISNULL(( SELECT TOP 1 D_KIT_RUTA_EVENTO
				FROM KIT_RUTA (NOLOCK)
				INNER JOIN KIT_RUTA_EVENTO (NOLOCK) ON KIT_RUTA_EVENTO.K_KIT_RUTA_EVENTO = KIT_RUTA.K_KIT_RUTA_EVENTO
				WHERE ITEM_NO = ccjoblin_sql.item_no
				AND KIT_RUTA.K_KIT_RUTA_EVENTO > ( SELECT TOP 1 K_TIPO_EVENTO_KIT 
											FROM [MATERIAL_PROGRAMADO_LOG] (NOLOCK)
											WHERE SERIAL = LTRIM(RTRIM(ccjoblin_sql.jobno)) + RIGHT('000'+ CONVERT(VARCHAR(10),ser_no), 3) 
											ORDER BY K_MATERIAL_PROGRAMADO_LOG DESC	)), 'N/E' )  AS EVENTO_SIGUIENTE,
			-- ===========================
			CONVERT(DATE, GETDATE())				AS F_EVENTO
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
	-- ===========================
	WHERE	(	ccjoblin_sql.jobno					LIKE '%'+@PP_BUSCAR+'%'
					OR	cccusitm_sql.cus_item_no	LIKE '%'+@PP_BUSCAR+'%' 
					OR	ccjoblin_sql.item_no		LIKE '%'+@PP_BUSCAR+'%'
					OR	cccusitm_sql.modelno		LIKE '%'+@PP_BUSCAR+'%'
					OR	ccjoblin_sql.kit			LIKE '%'+@PP_BUSCAR+'%'
					OR LTRIM(RTRIM(ccjoblin_sql.jobno)) + RIGHT('000'+ CONVERT(VARCHAR(10),ser_no), 3) LIKE '%'+@PP_BUSCAR+'%' )
	-- ===========================
	AND ccjoblin_sql.customer = ( CASE WHEN @PP_CLIENTE <> '( TODOS )' THEN @PP_CLIENTE
										ELSE ccjoblin_sql.customer END )
	-- ===========================
	AND ccjobhdr_sql.MACHINE = ( CASE WHEN @PP_MESA <> '( TODOS )' THEN @PP_MESA
										ELSE ccjobhdr_sql.MACHINE END )
	-- ===========================
    ORDER BY ccjoblin_sql.jobno, SER_NO

	-- ////////////////////////////////////////////////
	SELECT * 
	FROM @TBL_SEGUIMIENTO_MATERIAL_PROGRAMADO_LOG
	WHERE EVENTO_ACTUAL  = ( CASE WHEN @PP_EVENTO_ACTUAL <> '( TODOS )' THEN @PP_EVENTO_ACTUAL
										ELSE EVENTO_ACTUAL END )
	ORDER BY JOBNO, SER_NO
	-- ////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_RUTA_KIT]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_RUTA_KIT]
GO
/*
 EXEC	[dbo].[PG_LI_RUTA_KIT] 0,0, 'PWLDROBWLCPX7', 'WDL', '0012'
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

