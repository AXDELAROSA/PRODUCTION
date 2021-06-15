-- //////////////////////////////////////////////////////////////
-- // DATA BASE:		DATA02
-- // MODULE:			KIT_SORTED
-- // OPERATION:		TABLA
-- //////////////////////////////////////////////////////////////
-- // AUTHOR:			AX DE LA ROSA			
-- // CREATION DATE:	20210628
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02] 
GO


-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- // CLASE_EVENTO						SELECT * FROM CLASE_EVENTO
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CLASE_EVENTO]') AND type in (N'U'))
	DROP TABLE [dbo].[CLASE_EVENTO]
GO
CREATE TABLE [dbo].[CLASE_EVENTO] (
	[K_CLASE_EVENTO]	[INT]				NOT NULL,	--IDENTITY (1,1)	NOT NULL,
	-- =========================================
	[D_CLASE_EVENTO]	[VARCHAR] (100)		NOT NULL,
	[S_CLASE_EVENTO]	[VARCHAR] (10)		NOT NULL,
	[O_CLASE_EVENTO]	[INT]				NOT NULL DEFAULT 10,
	[C_CLASE_EVENTO]	[VARCHAR] (255)		NOT NULL DEFAULT '',
	[L_CLASE_EVENTO]	[INT]				NOT NULL DEFAULT 1
) ON [PRIMARY]
GO
-- //////////////////////////////////////////////////////////////
ALTER TABLE [dbo].[CLASE_EVENTO]
	ADD CONSTRAINT [PK_CLASE_EVENTO]
		PRIMARY KEY CLUSTERED ([K_CLASE_EVENTO])
GO

-- ===============================================
SET NOCOUNT ON
-- ===============================================
	INSERT INTO CLASE_EVENTO
		(	[K_CLASE_EVENTO]	,
			[D_CLASE_EVENTO]	,[S_CLASE_EVENTO]	,
			[O_CLASE_EVENTO]	,[C_CLASE_EVENTO]	,
			[L_CLASE_EVENTO]	)
	VALUES	
		(	10		,'CORTE'						,'CORTE'		,10		,'EVENTOS INICIALES, PROGRAMACIÓN Y CORTE.'								,1 ),
		(	20		,'MEDIO_PROCESO'				,'MPROC'		,20		,'EVENTOS DE PROCESOS ESPECIALES POR PATTERN.'							,1 ),
		(	25		,'MEDIO_PROCESO - ADICIONAL'	,'MP-AD'		,25		,'EVENTOS ADICIONALES DE PROCESOS ESPECIALES POR PATTERN.'				,1 ),
		(	30		,'FINAL'						,'FINAL'		,30		,'EVENTOS DE LIBERACIÓN, EMBARQUE Y FACTURACIÓN.'						,1 )
-- ===============================================
SET NOCOUNT OFF
-- ===============================================		
-- //////////////////////////////////////////////////////////////


-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- // SELECT * FROM [KIT_RUTA_EVENTO]
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[KIT_RUTA_EVENTO]') AND type in (N'U'))
	DROP TABLE [dbo].[KIT_RUTA_EVENTO]
GO
CREATE TABLE [dbo].[KIT_RUTA_EVENTO] (
	[K_KIT_RUTA_EVENTO]			[INT]				NOT NULL,--IDENTITY (1,1)	NOT NULL,
	-- =========================================
	[K_CLASE_EVENTO]			[INT]				NOT NULL,
	-- =========================================
	[D_KIT_RUTA_EVENTO]			[VARCHAR] (100)		NOT NULL,
	[S_KIT_RUTA_EVENTO]			[VARCHAR] (10)		NOT NULL,
	[O_KIT_RUTA_EVENTO]			[INT]				NOT NULL DEFAULT 10,
	[C_KIT_RUTA_EVENTO]			[VARCHAR] (255)		NOT NULL DEFAULT '',
	[L_KIT_RUTA_EVENTO]			[INT]				NOT NULL DEFAULT 1
) ON [PRIMARY]
GO
-- //////////////////////////////////////////////////////////////
ALTER TABLE [dbo].[KIT_RUTA_EVENTO]
	ADD CONSTRAINT [PK_KIT_RUTA_EVENTO]
		PRIMARY KEY CLUSTERED ([K_KIT_RUTA_EVENTO])
GO
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CI_KIT_RUTA_EVENTO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CI_KIT_RUTA_EVENTO]
GO
CREATE PROCEDURE [dbo].[PG_CI_KIT_RUTA_EVENTO]
	-- =========================================
	@PP_K_KIT_RUTA_EVENTO			INT				,
	-- =========================================
	@PP_D_KIT_RUTA_EVENTO			VARCHAR (100)	,
	@PP_S_KIT_RUTA_EVENTO			VARCHAR (10)	,
	@PP_O_KIT_RUTA_EVENTO			INT				,
	@PP_C_KIT_RUTA_EVENTO			VARCHAR (255)	,
	@PP_L_KIT_RUTA_EVENTO			INT				,
	-- =========================================
	@PP_K_CLASE_EVENTO				INT
AS	
	-- ===============================
	DECLARE @VP_EXISTE_RUTA_EVENTO			INT
	SELECT	@VP_EXISTE_RUTA_EVENTO	= COUNT(K_KIT_RUTA_EVENTO)
	FROM	KIT_RUTA_EVENTO
	WHERE	K_KIT_RUTA_EVENTO		= @PP_K_KIT_RUTA_EVENTO
	-- ===============================

	IF ( @VP_EXISTE_RUTA_EVENTO IS NULL OR @VP_EXISTE_RUTA_EVENTO = 0 )
		INSERT INTO KIT_RUTA_EVENTO
			(	[K_KIT_RUTA_EVENTO] ,
				[D_KIT_RUTA_EVENTO]	,[S_KIT_RUTA_EVENTO]	,
				[O_KIT_RUTA_EVENTO]	,[C_KIT_RUTA_EVENTO]	,
				[L_KIT_RUTA_EVENTO]	,[K_CLASE_EVENTO]		)
		VALUES	
			(	@PP_K_KIT_RUTA_EVENTO	,
				@PP_D_KIT_RUTA_EVENTO	,@PP_S_KIT_RUTA_EVENTO	,
				@PP_O_KIT_RUTA_EVENTO	,@PP_C_KIT_RUTA_EVENTO	,
				@PP_L_KIT_RUTA_EVENTO	,@PP_K_CLASE_EVENTO		)
	-- =========================================================
	ELSE
		UPDATE	KIT_RUTA_EVENTO
		SET		
				D_KIT_RUTA_EVENTO	= @PP_D_KIT_RUTA_EVENTO,
				S_KIT_RUTA_EVENTO	= @PP_S_KIT_RUTA_EVENTO,
				O_KIT_RUTA_EVENTO	= @PP_O_KIT_RUTA_EVENTO,
				C_KIT_RUTA_EVENTO	= @PP_C_KIT_RUTA_EVENTO,
				L_KIT_RUTA_EVENTO	= @PP_L_KIT_RUTA_EVENTO,
				K_CLASE_EVENTO		= @PP_K_CLASE_EVENTO
		WHERE	K_KIT_RUTA_EVENTO	= @PP_K_KIT_RUTA_EVENTO
	-- =========================================================
GO

-- ===============================================
SET NOCOUNT ON
-- ===============================================
--	CLASE CORTE
EXECUTE [dbo].[PG_CI_KIT_RUTA_EVENTO] 10	,'MATERIALES'					, 'MATER'									, 10, '', 1		, 10
EXECUTE [dbo].[PG_CI_KIT_RUTA_EVENTO] 20	,'EN CORTE'						, 'CORTE'									, 20, '', 1		, 10
EXECUTE [dbo].[PG_CI_KIT_RUTA_EVENTO] 30	,'INSP. CORTE'					, 'CRTE-LIBER'								, 30, '', 1		, 10

--	CLASE MEDIO_PROCESO
EXECUTE [dbo].[PG_CI_KIT_RUTA_EVENTO] 200	,'SKIVING'						, 'SIVIN'									, 200, '', 1	, 20
EXECUTE [dbo].[PG_CI_KIT_RUTA_EVENTO] 210	,'RECUT'						, 'RECUT'									, 210, '', 1	, 20
EXECUTE [dbo].[PG_CI_KIT_RUTA_EVENTO] 220	,'LAMINACION'					, 'LAMIN'									, 220, '', 1	, 20
EXECUTE [dbo].[PG_CI_KIT_RUTA_EVENTO] 230	,'PERFORACION'					, 'PERFO'									, 230, '', 1	, 20
EXECUTE [dbo].[PG_CI_KIT_RUTA_EVENTO] 240	,'QUILTING'						, 'QUILT'									, 240, '', 1	, 20
EXECUTE [dbo].[PG_CI_KIT_RUTA_EVENTO] 250	,'EMBOSSING'					, 'EMBOS'									, 250, '', 1	, 20
--------------------------------------------------------------------------------------------------------------------------------------------
EXECUTE [dbo].[PG_CI_KIT_RUTA_EVENTO] 300	,'INSP. PERFO.'					, 'INSP-PERFO'								, 300, '', 1	, 25

--	CLASE FINAL
EXECUTE [dbo].[PG_CI_KIT_RUTA_EVENTO] 400	,'CERTIFICACION'				, 'CERTIF'									, 400, '', 1	, 30
EXECUTE [dbo].[PG_CI_KIT_RUTA_EVENTO] 410	,'LIBERACION QC'				, 'QC-LIBER'								, 410, '', 1	, 30
EXECUTE [dbo].[PG_CI_KIT_RUTA_EVENTO] 420	,'MFP'			,				'PROD-TERMI'								, 420, '', 1	, 30
EXECUTE [dbo].[PG_CI_KIT_RUTA_EVENTO] 430	,'EMBARCADO'					, 'EMBAR'									, 430, '', 1	, 30
EXECUTE [dbo].[PG_CI_KIT_RUTA_EVENTO] 440	,'FACTURADO'					, 'FACTUR'									, 440, '', 1	, 30

GO
-- ===============================================
SET NOCOUNT OFF
-- ===============================================
-- //////////////////////////////////////////////////////////////


---- //////////////////////////////////////////////////////////////
---- // KIT_RUTA_EVENTO
---- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[KIT_RUTA]') AND type in (N'U'))
		DROP TABLE [dbo].[KIT_RUTA]	
GO
CREATE TABLE [dbo].[KIT_RUTA] (	
	[K_KIT_RUTA]						[INT]			IDENTITY (1,1)	NOT NULL,
	-- =========================================
	[CUS_NO]							[VARCHAR](6)	NOT NULL,
	[MODELNO]							[VARCHAR](3)	NOT NULL,
	[VERSIONNO]							[VARCHAR](4)	NOT NULL,
	[ITEM_NO]							[VARCHAR](15)	NOT NULL,
	-- =========================================	
	--[K_KIT_RUTA]						[INT]			NOT NULL,
	[K_KIT_RUTA_EVENTO]					[INT]			NOT NULL,
	--[D_KIT_RUTA_EVENTO]					[VARCHAR](50)	NOT NULL,
	[O_KIT_RUTA_EVENTO]					[INT]			NOT NULL,
	-- =========================================
	--[K_QUOTE_KIT_SORTED]				[INT]			NOT NULL
) ON [PRIMARY]
GO
-- //////////////////////////////////////////////////////////////
ALTER TABLE [dbo].[KIT_RUTA]
	ADD CONSTRAINT [PK_KIT_RUTA]
		PRIMARY KEY CLUSTERED ([K_KIT_RUTA])
GO
