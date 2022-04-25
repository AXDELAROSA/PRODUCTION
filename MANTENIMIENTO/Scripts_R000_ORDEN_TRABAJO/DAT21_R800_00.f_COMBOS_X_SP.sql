-- //////////////////////////////////////////////////////////////
-- // DATA BASE:		DATA_02
-- // MODULE:			ORDEN_TRABAJO
-- // OPERATION:		CARGA COMBO
-- //////////////////////////////////////////////////////////////
-- // AUTHOR:			AX DE LA ROSA			
-- // CREATION DATE:	20210825
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02]
GO

-- //////////////////////////////////////////////////////////////
-- ////////			CONTENIDO DEL SP
--	[PG_CB_STATUS_ORDEN_TRABAJO]
--	[PG_CB_ESTACION_TRABAJO]
--	[PG_CB_SUB_ESTACION_TRABAJO]
-- //////////////////////////////////////////////////////////////


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> CB STATUS_ORDEN_TRABAJO
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CB_STATUS_ORDEN_TRABAJO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CB_STATUS_ORDEN_TRABAJO]
GO
--		 EXECUTE [dbo].[PG_CB_STATUS_ORDEN_TRABAJO] 0,0, 0
--		 EXECUTE [dbo].[PG_CB_STATUS_ORDEN_TRABAJO] 0,0, 1
CREATE PROCEDURE [dbo].[PG_CB_STATUS_ORDEN_TRABAJO]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO				INT,
	--============================
	@PP_L_CON_TODOS				INT
AS
	DECLARE @VP_TA_CATALOGO	AS TABLE
				(	TA_K_CATALOGO		INT,
					TA_D_CATALOGO		VARCHAR(50),
					TA_O_CATALOGO		INT,
					TA_L_DELETED		INT,	
					TA_L_ACTIVO			INT			 )

	INSERT INTO @VP_TA_CATALOGO
	SELECT	
			K_STATUS_ORDEN_TRABAJO,
			--CONCAT(S_ORDEN_TRABAJO_CODE,' // ',D_ORDEN_TRABAJO_CODE)	AS TA_D_CATALOGO,
			D_STATUS_ORDEN_TRABAJO,
			O_STATUS_ORDEN_TRABAJO,
			0,
			L_STATUS_ORDEN_TRABAJO
	FROM	STATUS_ORDEN_TRABAJO		(NOLOCK)
	ORDER BY D_STATUS_ORDEN_TRABAJO

	IF @PP_L_CON_TODOS IN ( 0 )
		INSERT INTO @VP_TA_CATALOGO
				( TA_K_CATALOGO,	TA_D_CATALOGO,	TA_O_CATALOGO, TA_L_DELETED, TA_L_ACTIVO	)
			VALUES
				( -1,				'( SELECCIONAR )',	-999,		   0,			 1				)

	IF @PP_L_CON_TODOS IN ( 1 )
		INSERT INTO @VP_TA_CATALOGO
				( TA_K_CATALOGO,	TA_D_CATALOGO,	TA_O_CATALOGO, TA_L_DELETED, TA_L_ACTIVO	)
			VALUES
				( -1,				'( TODOS )',	-999,		   0,			 1				)

	-- ==========================================		
	SELECT	TA_K_CATALOGO	AS K_COMBOBOX,
			(
				(CASE 
					WHEN (TA_L_ACTIVO=1 AND TA_L_DELETED=0) THEN '' 
					ELSE '<X> ' 
					END 
				) +		TA_D_CATALOGO 
			) AS D_COMBOBOX
	FROM	@VP_TA_CATALOGO
	ORDER BY TA_O_CATALOGO	--TA_D_CATALOGO ,	
	-- ////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> CB ESTACION_TRABAJO
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CB_ESTACION_TRABAJO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CB_ESTACION_TRABAJO]
GO
--		 EXECUTE [dbo].[PG_CB_ESTACION_TRABAJO] 0,0, 0
--		 EXECUTE [dbo].[PG_CB_ESTACION_TRABAJO] 0,0, 1
CREATE PROCEDURE [dbo].[PG_CB_ESTACION_TRABAJO]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO				INT,
	--============================
	@PP_L_CON_TODOS				INT
AS
	DECLARE @VP_TA_CATALOGO	AS TABLE
				(	TA_K_CATALOGO		INT,
					TA_D_CATALOGO		VARCHAR(50),
					TA_O_CATALOGO		INT,
					TA_L_DELETED		INT,	
					TA_L_ACTIVO			INT			 )

	INSERT INTO @VP_TA_CATALOGO
	SELECT	
			K_ESTACION_TRABAJO,
			D_ESTACION_TRABAJO,
			0,
			0,
			L_ESTACION_TRABAJO
	FROM	ESTACION_TRABAJO		(NOLOCK)
	ORDER BY D_ESTACION_TRABAJO

	IF @PP_L_CON_TODOS IN ( 0 )
		INSERT INTO @VP_TA_CATALOGO
				( TA_K_CATALOGO,	TA_D_CATALOGO,	TA_O_CATALOGO, TA_L_DELETED, TA_L_ACTIVO	)
			VALUES
				( -1,				'( SELECCIONAR )',	-999,		   0,			 1				)

	IF @PP_L_CON_TODOS IN ( 1 )
		INSERT INTO @VP_TA_CATALOGO
				( TA_K_CATALOGO,	TA_D_CATALOGO,	TA_O_CATALOGO, TA_L_DELETED, TA_L_ACTIVO	)
			VALUES
				( -1,				'( TODOS )',	-999,		   0,			 1				)

	-- ==========================================		
	SELECT	TA_K_CATALOGO	AS K_COMBOBOX,
			(
				(CASE 
					WHEN (TA_L_ACTIVO=1 AND TA_L_DELETED=0) THEN '' 
					ELSE '<X> ' 
					END 
				) +		TA_D_CATALOGO 
			) AS D_COMBOBOX
	FROM	@VP_TA_CATALOGO
	ORDER BY TA_D_CATALOGO ,	TA_O_CATALOGO
	-- ////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> CB SUB_ESTACION_TRABAJO
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CB_SUB_ESTACION_TRABAJO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CB_SUB_ESTACION_TRABAJO]
GO
--		 EXECUTE [dbo].[PG_CB_SUB_ESTACION_TRABAJO] 0,0, 0	,0	
--		 EXECUTE [dbo].[PG_CB_SUB_ESTACION_TRABAJO] 0,0, 1	,0	
--		 EXECUTE [dbo].[PG_CB_SUB_ESTACION_TRABAJO] 0,0, 0	,1
--		 EXECUTE [dbo].[PG_CB_SUB_ESTACION_TRABAJO] 0,0, 1	,1
--		 EXECUTE [dbo].[PG_CB_SUB_ESTACION_TRABAJO] 0,0, 0	,2
--		 EXECUTE [dbo].[PG_CB_SUB_ESTACION_TRABAJO] 0,0, 1	,2
CREATE PROCEDURE [dbo].[PG_CB_SUB_ESTACION_TRABAJO]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO				INT,
	--============================
	@PP_L_CON_TODOS				INT,
	@PP_K_ESTACION_TRABAJO		INT
AS
	DECLARE @VP_TA_CATALOGO	AS TABLE
				(	TA_K_CATALOGO		INT,
					TA_D_CATALOGO		VARCHAR(50),
					TA_O_CATALOGO		INT,
					TA_L_DELETED		INT,	
					TA_L_ACTIVO			INT			 )

	INSERT INTO @VP_TA_CATALOGO
	SELECT	
			K_SUB_ESTACION_TRABAJO,
			D_SUB_ESTACION_TRABAJO,
			0,
			0,
			L_SUB_ESTACION_TRABAJO
	FROM	SUB_ESTACION_TRABAJO	(NOLOCK)
	WHERE	K_ESTACION_TRABAJO		= @PP_K_ESTACION_TRABAJO
	ORDER BY D_SUB_ESTACION_TRABAJO

	IF @PP_L_CON_TODOS IN ( 0 )
		INSERT INTO @VP_TA_CATALOGO
				( TA_K_CATALOGO,	TA_D_CATALOGO,	TA_O_CATALOGO, TA_L_DELETED, TA_L_ACTIVO	)
			VALUES
				( -1,				'( SELECCIONAR )',	-999,		   0,			 1				)

	IF @PP_L_CON_TODOS IN ( 1 )
		INSERT INTO @VP_TA_CATALOGO
				( TA_K_CATALOGO,	TA_D_CATALOGO,	TA_O_CATALOGO, TA_L_DELETED, TA_L_ACTIVO	)
			VALUES
				( -1,				'( TODOS )',	-999,		   0,			 1				)

	-- ==========================================		
	SELECT	TA_K_CATALOGO	AS K_COMBOBOX,
			(
				(CASE 
					WHEN (TA_L_ACTIVO=1 AND TA_L_DELETED=0) THEN '' 
					ELSE '<X> ' 
					END 
				) +		TA_D_CATALOGO 
			) AS D_COMBOBOX
	FROM	@VP_TA_CATALOGO
	ORDER BY TA_D_CATALOGO ,	TA_O_CATALOGO
	-- ////////////////////////////////////////////////////
GO

-- ///////////////////////////////////////////////////////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////
