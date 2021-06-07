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

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_ESTATUS_X_SERIAL_ORDEN]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_ESTATUS_X_SERIAL_ORDEN]
GO

/*
												  (ORDEN)
 EXEC	[dbo].[PG_LI_ESTATUS_X_SERIAL_ORDEN] 0,0, '', '( TODOS )', '( TODOS )'
 EXEC	[dbo].[PG_LI_ESTATUS_X_SERIAL_ORDEN] 0,0, '31337', '( TODOS )', '( TODOS )'
*/


CREATE PROCEDURE [dbo].[PG_LI_ESTATUS_X_SERIAL_ORDEN]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	@PP_BUSCAR						VARCHAR(150),
	@PP_CLIENTE						VARCHAR(50),
	@PP_MESA						VARCHAR(50)
AS

	-- /////////SE DECLARA LAS VARIABLES Y EL CURSOSR A USAR/////////////////////////////////////////////////////////////////////////////
	SELECT	LTRIM(RTRIM(ccjoblin_sql.jobno))		AS JOBNO, 
			-- ===========================
			ccjoblin_sql.Ser_No						AS SER_NO,
			-- ===========================
			LTRIM(RTRIM(ccjoblin_sql.jobno)) + RIGHT('000'+ LTRIM(RTRIM(ser_no)),3) AS SERIAL,
			-- ===========================
			LTRIM(RTRIM(ccjoblin_sql.kit))			AS KIT, 
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
			'PRODUCCION' AS EVENTO_ACTUAL,
			'PERFORACION' AS EVENTO_SIGUIENTE,
			CONVERT(DATE, GETDATE())				AS F_EVENTO
			-- ===========================
	FROM ccjoblin_sql  (NOLOCK)
	INNER JOIN ccjobhdr_sql (NOLOCK) ON ccjoblin_sql.jobno = ccjobhdr_sql.jobno 
		AND status = 'P'
		--AND folio IS NOT NULL 
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
					OR LTRIM(RTRIM(ccjoblin_sql.jobno)) + RIGHT('000'+ LTRIM(RTRIM(ser_no)),3) LIKE '%'+@PP_BUSCAR+'%' )
	-- ===========================
	AND ccjoblin_sql.customer = ( CASE WHEN @PP_CLIENTE <> '( TODOS )' THEN @PP_CLIENTE
										ELSE ccjoblin_sql.customer END )
	-- ===========================
	AND ccjobhdr_sql.MACHINE = ( CASE WHEN @PP_MESA <> '( TODOS )' THEN @PP_MESA
										ELSE ccjobhdr_sql.MACHINE END )
	-- ===========================
    ORDER BY ccjoblin_sql.jobno, SER_NO

	-- ////////////////////////////////////////////////
	-- ////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_RUTA_KIT]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_RUTA_KIT]
GO
/*
 EXEC	[dbo].[PG_LI_RUTA_KIT] 0,0, 'PMWGLFCCNPDX9', 'WKG', '0024'
 EXEC	[dbo].[PG_LI_RUTA_KIT] 0,0, 'PMJYFBRCNPDX9', 'WKG', '0024'
 EXEC	[dbo].[PG_LI_RUTA_KIT] 0,0, 'PMJYFBLCNPDX9', 'WKG', '0024'

 EXEC	[dbo].[PG_LI_RUTA_KIT] 0,0, 'PMWDZBRCNPDX9', 'WKZ', '0015'
    
*/

CREATE PROCEDURE [dbo].[PG_LI_RUTA_KIT]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	@PP_KIT							VARCHAR(50),
	@PP_MODELO						VARCHAR(50),
	@PP_VERSION						VARCHAR(50)
AS

	-- /////////SE DECLARA LAS VARIABLES Y EL CURSOSR A USAR/////////////////////////////////////////////////////////////////////////////
	DECLARE @VP_SECUENCIA_EVENTO VARCHAR(255) = ''

	SET NOCOUNT OFF
	--DECLARE @TBL_PROCESO_X_PATRON AS TABLE(
	CREATE TABLE #RUTA_KIT(
		ID				INT IDENTITY(1,1),
		D_PROCESO		VARCHAR(100),
		ESTATUS			INT
	)

	INSERT INTO #RUTA_KIT
	SELECT 'RECIBO', 1
	
	INSERT INTO #RUTA_KIT
	SELECT 'PRODUCCION', 1

	--INSERT INTO #RUTA_KIT
	--SELECT 'CORTE', 1

	INSERT INTO #RUTA_KIT
	SELECT 'PERFORACION', 1

	INSERT INTO #RUTA_KIT
	SELECT 'SHAVE', 1

	INSERT INTO #RUTA_KIT
	SELECT 'EMBOSSING', 1

	INSERT INTO #RUTA_KIT
	SELECT 'INSP. PERFO.', 1

	INSERT INTO #RUTA_KIT
	SELECT 'CERTIFICACION', 1

	INSERT INTO #RUTA_KIT
	SELECT 'LIBERACION', 1

	INSERT INTO #RUTA_KIT
	SELECT 'MFP', 1

	INSERT INTO #RUTA_KIT
	SELECT 'EMBARCADO', 1

	INSERT INTO #RUTA_KIT
	SELECT 'FACTURADO', 1

	SET NOCOUNT ON
	--SELECT DISTINCT D_PROCESO FROM @TBL_PROCESO_X_PATRON WHERE ESTATUS = 1
	SELECT * FROM #RUTA_KIT -- WHERE ESTATUS = 1
	ORDER BY ID

	--DROP TABLE #SALIDA_MATERIAL_MHI
	-- ////////////////////SE OBTIENEN LOS DATOS DE LOS PACKING DINAMICAMENTE QUE SE CONVERTIRAN EN LAS COLUMNAS DE LA TABLA//////////////////////////	
		--		DECLARE @cols1 AS NVARCHAR(MAX), @query1 AS NVARCHAR(MAX)
		--		select @cols1 = STUFF(( SELECT ',' + QUOTENAME(D_PROCESO) 
		--								FROM #RUTA_KIT 
		--								ORDER BY ID
		--								FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'' ) 									 										 			
											 			
		--		SET @query1 = N'SELECT ' + @cols1 + N' into [tempdb].[dbo].[RUTA_KIT_TEM]  from ( SELECT DISTINCT D_PROCESO FROM #RUTA_KIT WHERE ESTATUS = 1 ) x pivot ( COUNT(D_PROCESO) for D_PROCESO in (' + @cols1 + N') ) p ' 
		--		EXEC sp_executesql @query1;		
		
		--SET NOCOUNT ON
		--SELECT * FROM [tempdb].[dbo].RUTA_KIT_TEM

		--SET NOCOUNT OFF
		--DROP TABLE #RUTA_KIT
		--DROP TABLE [tempdb].[dbo].RUTA_KIT_TEM
	-- ////////////////////////////////////////////////
	/*
 EXEC	[dbo].[PG_LI_RUTA_KIT] 0,0, 'PMWGLFCCNPDX9', 'WKG', '0024'
 EXEC	[dbo].[PG_LI_RUTA_KIT] 0,0, 'PMJYFBRCNPDX9', 'WKG', '0024'
 EXEC	[dbo].[PG_LI_RUTA_KIT] 0,0, 'PMJYFBLCNPDX9', 'WKG', '0024'

 EXEC	[dbo].[PG_LI_RUTA_KIT] 0,0, 'PMWDZBRCNPDX9', 'WKZ', '0015'
    
*/
	-- ////////////////////////////////////////////////
GO


