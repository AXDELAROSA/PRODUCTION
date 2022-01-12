-- //////////////////////////////////////////////////////////////
-- // DATA BASE:		DATA_02
-- // MODULE:			ORDEN_TRABAJO
-- // OPERATION:		TABLE
-- //////////////////////////////////////////////////////////////
-- // AUTHOR:			AX DE LA ROSA			
-- // CREATION DATE:	20211012
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02]
GO

-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- // DROPs
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ORDEN_TRABAJO]') AND type in (N'U'))
	DROP TABLE [dbo].[ORDEN_TRABAJO]
GO

--IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ORDEN_TRABAJO_DETALLE]') AND type in (N'U'))
--	DROP TABLE [dbo].[ORDEN_TRABAJO_DETALLE]
--GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MOTIVO_ORDEN_TRABAJO]') AND type in (N'U'))
	DROP TABLE [dbo].[MOTIVO_ORDEN_TRABAJO]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TIPO_ORDEN_TRABAJO]') AND type in (N'U'))
	DROP TABLE [dbo].[TIPO_ORDEN_TRABAJO]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SUB_ESTACION_TRABAJO]') AND type in (N'U'))
	DROP TABLE [dbo].[SUB_ESTACION_TRABAJO]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ESTACION_TRABAJO]') AND type in (N'U'))
	DROP TABLE [dbo].[ESTACION_TRABAJO]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[STATUS_ORDEN_TRABAJO]') AND type in (N'U'))
	DROP TABLE [dbo].[STATUS_ORDEN_TRABAJO]
GO


-- ////////////////////////////////////////////////////////////////
-- //					STATUS_ORDEN_TRABAJO				 
-- ////////////////////////////////////////////////////////////////
CREATE TABLE [dbo].[STATUS_ORDEN_TRABAJO] (
	[K_STATUS_ORDEN_TRABAJO]				[INT]			NOT NULL,
	[D_STATUS_ORDEN_TRABAJO]				[VARCHAR](100)	NOT NULL,
	[C_STATUS_ORDEN_TRABAJO]				[VARCHAR](255)	NOT NULL,
	[S_STATUS_ORDEN_TRABAJO]				[VARCHAR](10)	NOT NULL,
	[O_STATUS_ORDEN_TRABAJO]				[INT]			NOT NULL,
	[L_STATUS_ORDEN_TRABAJO]				[INT]			NOT NULL
) ON [PRIMARY]
GO
-- //////////////////////////////////////////////////////
ALTER TABLE [dbo].[STATUS_ORDEN_TRABAJO]
	ADD CONSTRAINT [PK_STATUS_ORDEN_TRABAJO]
		PRIMARY KEY CLUSTERED ([K_STATUS_ORDEN_TRABAJO])
GO
CREATE UNIQUE NONCLUSTERED 
	INDEX [UN_STATUS_ORDEN_TRABAJO_01_DESCRIPCION] 
	   ON [dbo].[STATUS_ORDEN_TRABAJO] ( [D_STATUS_ORDEN_TRABAJO] )
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CI_STATUS_ORDEN_TRABAJO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CI_STATUS_ORDEN_TRABAJO]
GO
-- //////////////////////////////////////////////////////////////
-- //				CI - STATUS_ORDEN_TRABAJO
-- //////////////////////////////////////////////////////////////
CREATE PROCEDURE [dbo].[PG_CI_STATUS_ORDEN_TRABAJO]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_K_STATUS_ORDEN_TRABAJO				INT,
	@PP_D_STATUS_ORDEN_TRABAJO				VARCHAR(100),
	@PP_C_STATUS_ORDEN_TRABAJO				VARCHAR(255),
	@PP_S_STATUS_ORDEN_TRABAJO				VARCHAR(10),
	@PP_O_STATUS_ORDEN_TRABAJO				INT,
	@PP_L_STATUS_ORDEN_TRABAJO				INT
AS				
	-- ===============================
DECLARE @VP_K_EXISTE	INT
	SELECT	@VP_K_EXISTE =	K_STATUS_ORDEN_TRABAJO
	FROM	STATUS_ORDEN_TRABAJO
	WHERE	K_STATUS_ORDEN_TRABAJO	= @PP_K_STATUS_ORDEN_TRABAJO
	-- ===========================
IF @VP_K_EXISTE IS NULL
	INSERT INTO STATUS_ORDEN_TRABAJO
			(	[K_STATUS_ORDEN_TRABAJO], [D_STATUS_ORDEN_TRABAJO], 
				[C_STATUS_ORDEN_TRABAJO], [S_STATUS_ORDEN_TRABAJO], 
				[O_STATUS_ORDEN_TRABAJO], [L_STATUS_ORDEN_TRABAJO]		)
	VALUES	
			(	@PP_K_STATUS_ORDEN_TRABAJO, @PP_D_STATUS_ORDEN_TRABAJO, 
				@PP_C_STATUS_ORDEN_TRABAJO, @PP_S_STATUS_ORDEN_TRABAJO,
				@PP_O_STATUS_ORDEN_TRABAJO, @PP_L_STATUS_ORDEN_TRABAJO	 )
ELSE
	UPDATE STATUS_ORDEN_TRABAJO
	SET
			[D_STATUS_ORDEN_TRABAJO]		= @PP_D_STATUS_ORDEN_TRABAJO, 
			[C_STATUS_ORDEN_TRABAJO]		= @PP_C_STATUS_ORDEN_TRABAJO, 
			[S_STATUS_ORDEN_TRABAJO]		= @PP_S_STATUS_ORDEN_TRABAJO, 
			[O_STATUS_ORDEN_TRABAJO]		= @PP_O_STATUS_ORDEN_TRABAJO, 
			[L_STATUS_ORDEN_TRABAJO]		= @PP_L_STATUS_ORDEN_TRABAJO
	WHERE	[K_STATUS_ORDEN_TRABAJO]		= @PP_K_STATUS_ORDEN_TRABAJO

GO

EXECUTE [dbo].[PG_CI_STATUS_ORDEN_TRABAJO] 0,139,00, 'CANCELADA',					'', 'CANCL',	00,0		-- ACTUALIZA QUIEN LA GENERA
-- =================================================================================
EXECUTE [dbo].[PG_CI_STATUS_ORDEN_TRABAJO] 0,139,10, 'CREADA',						'', 'CREAD',	10,1		-- ESTATUS INICIAL
EXECUTE [dbo].[PG_CI_STATUS_ORDEN_TRABAJO] 0,139,20, 'ENVIADA',						'', 'ENVDA',	20,1		-- ENVIADA: DESDE TPO_CUSTOMER O POR REPARACIÓN DE DADOS.
EXECUTE [dbo].[PG_CI_STATUS_ORDEN_TRABAJO] 0,139,30, 'ASIGNADA',					'', 'ASIGN',	30,1		-- ASIGNADA A UN TÉCNICO.
EXECUTE [dbo].[PG_CI_STATUS_ORDEN_TRABAJO] 0,139,35, 'TERMINADA (PARCIAL)',			'', 'TRMIP',	35,1		-- TERMINADA PARCIAL
EXECUTE [dbo].[PG_CI_STATUS_ORDEN_TRABAJO] 0,139,40, 'TERMINADA',					'', 'TRMIN',	40,1		-- TERMINADA
EXECUTE [dbo].[PG_CI_STATUS_ORDEN_TRABAJO] 0,139,45, 'TERMINADA (RCHZDA)',			'', 'TRMI2',	45,1		-- TERMINADA DESPUES DE SER RECHAZADA.
EXECUTE [dbo].[PG_CI_STATUS_ORDEN_TRABAJO] 0,139,50, 'RECHAZADA',					'', 'RCHAZ',	50,1		-- RECHAZADA: REQUIERE CAMBIOS O NO SE HIZO CORRECTAMENTE.
EXECUTE [dbo].[PG_CI_STATUS_ORDEN_TRABAJO] 0,139,60, 'ACEPTADA',					'', 'ACEPT',	60,1		-- CERRADA COMPLETA, EL USUARIO ACEPTÓ EL SERVICIO.
EXECUTE [dbo].[PG_CI_STATUS_ORDEN_TRABAJO] 0,139,70, 'CERRADA PARCIAL',				'', 'PARCL',	70,0		-- CERRADA PARCIAL
-- =================================================================================
GO
--select * from bd_general.dbo.USUARIO_PEARL	

-- ////////////////////////////////////////////////////////////////
-- //					ESTACION_TRABAJO
-- ////////////////////////////////////////////////////////////////
CREATE TABLE [dbo].[ESTACION_TRABAJO] (
	[K_ESTACION_TRABAJO]				[INT] NOT NULL,
	-- ============================
	[D_ESTACION_TRABAJO]				[VARCHAR] (500) NOT NULL,
	-- ============================
	[L_ESTACION_TRABAJO]				[INT] NOT NULL DEFAULT 1
) ON [PRIMARY]
GO


-- ////////////////////////////////////////////////////////////////
-- //					SUB_ESTACION_TRABAJO
-- ////////////////////////////////////////////////////////////////
CREATE TABLE [dbo].[SUB_ESTACION_TRABAJO] (
	[K_SUB_ESTACION_TRABAJO]				[INT] NOT NULL,
	-- ============================
	[K_ESTACION_TRABAJO]					[INT] NOT NULL,
	[D_SUB_ESTACION_TRABAJO]				[VARCHAR] (500) NOT NULL,
	-- ============================
	[L_SUB_ESTACION_TRABAJO]				[INT] NOT NULL DEFAULT 1
) ON [PRIMARY]
GO


-- ////////////////////////////////////////////////////////////////
-- //					TIPO_ORDEN_TRABAJO
-- ////////////////////////////////////////////////////////////////
CREATE TABLE [dbo].[TIPO_ORDEN_TRABAJO] (
	[K_TIPO_ORDEN_TRABAJO]				[INT] NOT NULL,
	-- ============================
	[D_TIPO_ORDEN_TRABAJO]				[VARCHAR] (500) NOT NULL,
	-- ============================
	[L_TIPO_ORDEN_TRABAJO]				[INT] NOT NULL DEFAULT 1,
	-- ============================
	[CLASE_TIPO]						[INT] NOT NULL DEFAULT 1
) ON [PRIMARY]
GO


-- ////////////////////////////////////////////////////////////////
-- //					MOTIVO_ORDEN_TRABAJO
-- ////////////////////////////////////////////////////////////////
CREATE TABLE [dbo].[MOTIVO_ORDEN_TRABAJO] (
	[K_MOTIVO_ORDEN_TRABAJO]				[INT] NOT NULL,
	-- ============================
	[D_MOTIVO_ORDEN_TRABAJO]				[VARCHAR] (500) NOT NULL,
	-- ============================
	[L_MOTIVO_ORDEN_TRABAJO]				[INT] NOT NULL DEFAULT 1,
	-- ============================
	[CLASE_MOTIVO]							[INT] NOT NULL DEFAULT 1,
) ON [PRIMARY]
GO


---- ////////////////////////////////////////////////////////////////
---- //					ORDEN_TRABAJO_DETALLE
---- ////////////////////////////////////////////////////////////////
--CREATE TABLE [dbo].[ORDEN_TRABAJO_DETALLE] (
--	[K_ORDEN_TRABAJO_DETALLE]			[INT] IDENTITY (1,1)	NOT NULL,
--	[K_ORDEN_TRABAJO]					[INT] NOT NULL,
--	-- ============================
--	[N_TECNICO_REALIZA]					[INT] NOT NULL	DEFAULT 0,
--	[D_TECNICO_REALIZA]					[VARCHAR] (500) NOT NULL DEFAULT '',
--	-- ============================
--	[DURACION_MINUTOS]					[INT] NOT NULL DEFAULT 0,
--	[ACCION_REALIZADA]					[NVARCHAR](MAX) NOT NULL DEFAULT '',
--	[C_ORDEN_TRABAJO]					[NVARCHAR](MAX) NOT NULL DEFAULT ''	
--	-- ============================
--) ON [PRIMARY]
--GO


-- ////////////////////////////////////////////////////////////////
-- //					ORDEN_TRABAJO
-- ////////////////////////////////////////////////////////////////
CREATE TABLE [dbo].[ORDEN_TRABAJO] (
	[K_ORDEN_TRABAJO]						[INT] IDENTITY (1,1)	NOT NULL,
	-- ============================
	[K_USUARIO_SOLICITA]					[INT] NOT NULL,
	[K_USUARIO_RECIBE]						[INT] NOT NULL DEFAULT 0,
	-- ============================
	[K_STATUS_ORDEN_TRABAJO]				[INT] NOT NULL DEFAULT 1,
	-- ============================
	[K_ESTACION]							[INT] NOT NULL DEFAULT 0,
	[K_SUB_ESTACION]						[INT] NOT NULL DEFAULT 0,
	-- ============================
	[D_ORDEN_TRABAJO]						[NVARCHAR](MAX) NOT NULL DEFAULT '',
	[F_ORDEN_TRABAJO]						[DATE] NOT NULL,
	-- ============================
	[DURACION_TOTAL_MINUTOS]				[INT] NOT NULL,
	-- ============================	
	[K_TIPO_ORDEN_TRABAJO]					[INT] NOT NULL	DEFAULT 0,
	[K_MOTIVO_ORDEN_TRABAJO]				[INT] NOT NULL	DEFAULT 0,
	-- ============================	
	[RUTA_ORDEN_TRABAJO]					[NVARCHAR](MAX) NULL,
	-- ============================
	[N_TECNICO_REALIZA]						[INT] NOT NULL	DEFAULT 0,
	[D_TECNICO_REALIZA]						[VARCHAR] (500) NOT NULL DEFAULT '',
	-- ============================
	--[DURACION_MINUTOS]						[INT] NOT NULL DEFAULT 0,
	[ACCION_REALIZADA]						[NVARCHAR](MAX) NOT NULL DEFAULT '',
	[C_ORDEN_TRABAJO]						[NVARCHAR](MAX) NOT NULL DEFAULT ''
) ON [PRIMARY]
GO
-- //////////////////////////////////////////////////////
ALTER TABLE [dbo].[ORDEN_TRABAJO]
	ADD CONSTRAINT [PK_ORDEN_TRABAJO]
		PRIMARY KEY CLUSTERED ([K_ORDEN_TRABAJO])	
GO
ALTER TABLE [dbo].[ORDEN_TRABAJO] ADD 
	CONSTRAINT [FK_STATUS_ORDEN_TRABAJO_01] 
		FOREIGN KEY ( K_STATUS_ORDEN_TRABAJO ) 
		REFERENCES [dbo].[STATUS_ORDEN_TRABAJO] (K_STATUS_ORDEN_TRABAJO )
GO
-- //////////////////////////////////////////////////////
ALTER TABLE [dbo].[ORDEN_TRABAJO] 
	ADD		[K_USUARIO_ALTA]			[INT] NOT NULL,
			[F_ALTA]					[DATETIME] NOT NULL,
			[K_USUARIO_CAMBIO]			[INT] NOT NULL,
			[F_CAMBIO]					[DATETIME] NOT NULL,
			[L_BORRADO]					[INT] NOT NULL,
			[K_USUARIO_BAJA]			[INT] NULL,
			[F_BAJA]					[DATETIME] NULL;
GO
---- //////////////////////////////////////////////////////////////
---- //////////////////////////////////////////////////////////////
---- //////////////////////////////////////////////////////////////

--UPDATE	TPO_CUSTOMER_DET_SET_COTIZADO
--SET		K_STATUS_SET_COTIZADO	= 1
--WHERE	K_STATUS_SET_COTIZADO	= 2

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CI_ESTACION_TRABAJO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CI_ESTACION_TRABAJO]
GO
-- //////////////////////////////////////////////////////////////
-- //				CI - ESTACION_TRABAJO
-- //////////////////////////////////////////////////////////////
CREATE PROCEDURE [dbo].[PG_CI_ESTACION_TRABAJO]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_K_ESTACION_TRABAJO				INT,
	@PP_D_ESTACION_TRABAJO				VARCHAR(100),
	@PP_L_ESTACION_TRABAJO				INT
AS				
	-- ===============================
DECLARE @VP_K_EXISTE	INT
	SELECT	@VP_K_EXISTE =	K_ESTACION_TRABAJO
	FROM	ESTACION_TRABAJO
	WHERE	K_ESTACION_TRABAJO	= @PP_K_ESTACION_TRABAJO
	-- ===========================
IF @VP_K_EXISTE IS NULL
	INSERT INTO ESTACION_TRABAJO
			(	[K_ESTACION_TRABAJO], [D_ESTACION_TRABAJO], 
				[L_ESTACION_TRABAJO]		)
	VALUES	
			(	@PP_K_ESTACION_TRABAJO, @PP_D_ESTACION_TRABAJO,
				@PP_L_ESTACION_TRABAJO	 )
ELSE
	UPDATE ESTACION_TRABAJO
	SET
			[D_ESTACION_TRABAJO]		= @PP_D_ESTACION_TRABAJO,
			[L_ESTACION_TRABAJO]		= @PP_L_ESTACION_TRABAJO
	WHERE	[K_ESTACION_TRABAJO]		= @PP_K_ESTACION_TRABAJO
GO

-- =================================================================================
EXECUTE [dbo].[PG_CI_ESTACION_TRABAJO] 0, 0, 0,		'(NO APLICA)'					, 1
EXECUTE [dbo].[PG_CI_ESTACION_TRABAJO] 0, 0, 1,		'Prensa 1'						, 1
EXECUTE [dbo].[PG_CI_ESTACION_TRABAJO] 0, 0, 2,		'Prensa 2'						, 1
EXECUTE [dbo].[PG_CI_ESTACION_TRABAJO] 0, 0, 3,		'Prensa 3'						, 1
EXECUTE [dbo].[PG_CI_ESTACION_TRABAJO] 0, 0, 4,		'Prensa 4'						, 1
EXECUTE [dbo].[PG_CI_ESTACION_TRABAJO] 0, 0, 5,		'Prensa 5'						, 1
EXECUTE [dbo].[PG_CI_ESTACION_TRABAJO] 0, 0, 6,		'Prensa 6'						, 1
EXECUTE [dbo].[PG_CI_ESTACION_TRABAJO] 0, 0, 7,		'Prensa 7'						, 1
EXECUTE [dbo].[PG_CI_ESTACION_TRABAJO] 0, 0, 8,		'Prensa 8'						, 1
EXECUTE [dbo].[PG_CI_ESTACION_TRABAJO] 0, 0, 9,		'Edificio'						, 1
EXECUTE [dbo].[PG_CI_ESTACION_TRABAJO] 0, 0, 10,	'Engomadora 1'					, 1
EXECUTE [dbo].[PG_CI_ESTACION_TRABAJO] 0, 0, 11,	'Laminadora'					, 1
EXECUTE [dbo].[PG_CI_ESTACION_TRABAJO] 0, 0, 12,	'Maquina de costura'			, 1
EXECUTE [dbo].[PG_CI_ESTACION_TRABAJO] 0, 0, 13,	'Perforadora 1'					, 1
EXECUTE [dbo].[PG_CI_ESTACION_TRABAJO] 0, 0, 14,	'Perforadora 2'					, 1
EXECUTE [dbo].[PG_CI_ESTACION_TRABAJO] 0, 0, 15,	'Perforadora 3'					, 1
EXECUTE [dbo].[PG_CI_ESTACION_TRABAJO] 0, 0, 16,	'Perforadora 4'					, 1
EXECUTE [dbo].[PG_CI_ESTACION_TRABAJO] 0, 0, 17,	'Perforadora 5'					, 1
EXECUTE [dbo].[PG_CI_ESTACION_TRABAJO] 0, 0, 18,	'Perforadora 6'					, 1
EXECUTE [dbo].[PG_CI_ESTACION_TRABAJO] 0, 0, 19,	'Perforadora 7'					, 1
EXECUTE [dbo].[PG_CI_ESTACION_TRABAJO] 0, 0, 20,	'Prensa clicker'				, 1
EXECUTE [dbo].[PG_CI_ESTACION_TRABAJO] 0, 0, 21,	'Rebajadora 1'					, 1
EXECUTE [dbo].[PG_CI_ESTACION_TRABAJO] 0, 0, 22,	'Rebajadora 2'					, 1
EXECUTE [dbo].[PG_CI_ESTACION_TRABAJO] 0, 0, 23,	'Rectificadora'					, 1
EXECUTE [dbo].[PG_CI_ESTACION_TRABAJO] 0, 0, 24,	'Herramental'					, 1
-- =================================================================================
GO



IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CI_SUB_ESTACION_TRABAJO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CI_SUB_ESTACION_TRABAJO]
GO
-- //////////////////////////////////////////////////////////////
-- //				CI - SUB_ESTACION_TRABAJO
-- //////////////////////////////////////////////////////////////
CREATE PROCEDURE [dbo].[PG_CI_SUB_ESTACION_TRABAJO]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_K_SUB_ESTACION_TRABAJO			INT,
	@PP_K_ESTACION_TRABAJO				INT,
	@PP_D_SUB_ESTACION_TRABAJO			VARCHAR(100),
	@PP_L_SUB_ESTACION_TRABAJO			INT
AS				
	-- ===============================
DECLARE @VP_K_EXISTE	INT
	SELECT	@VP_K_EXISTE =	K_SUB_ESTACION_TRABAJO
	FROM	SUB_ESTACION_TRABAJO
	WHERE	K_SUB_ESTACION_TRABAJO	= @PP_K_SUB_ESTACION_TRABAJO
	-- ===========================
IF @VP_K_EXISTE IS NULL
	INSERT INTO SUB_ESTACION_TRABAJO
			(	[K_SUB_ESTACION_TRABAJO], [K_ESTACION_TRABAJO],
				[D_SUB_ESTACION_TRABAJO], 
				[L_SUB_ESTACION_TRABAJO]		)
	VALUES	
			(	@PP_K_SUB_ESTACION_TRABAJO, @PP_K_ESTACION_TRABAJO,
				@PP_D_SUB_ESTACION_TRABAJO,
				@PP_L_SUB_ESTACION_TRABAJO	 )
ELSE
	UPDATE SUB_ESTACION_TRABAJO
	SET
			[K_ESTACION_TRABAJO]			= @PP_K_ESTACION_TRABAJO,
			[D_SUB_ESTACION_TRABAJO]		= @PP_D_SUB_ESTACION_TRABAJO,
			[L_SUB_ESTACION_TRABAJO]		= @PP_L_SUB_ESTACION_TRABAJO
	WHERE	[K_SUB_ESTACION_TRABAJO]		= @PP_K_SUB_ESTACION_TRABAJO
GO
-- =================================================================================
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 00,0, '(NO APLICA)'	, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 01,1, 'MESA 01'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 02,1, 'MESA 02'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 03,1, 'MESA 03'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 04,1, 'MESA 04'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 05,1, 'MESA 05'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 06,1, 'MESA 06'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 07,1, 'MESA 07'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 08,1, 'MESA 08'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 09,1, 'MESA 09'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 10,1, 'MESA 10'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 11,1, 'MESA 11'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 12,1, 'MESA 12'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 13,2, 'MESA 13'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 14,2, 'MESA 14'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 15,2, 'MESA 15'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 16,2, 'MESA 16'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 17,2, 'MESA 17'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 18,2, 'MESA 18'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 19,2, 'MESA 19'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 20,2, 'MESA 20'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 21,2, 'MESA 21'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 22,2, 'MESA 22'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 23,2, 'MESA 23'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 24,2, 'MESA 24'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 25,3, 'MESA 25'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 26,3, 'MESA 26'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 27,3, 'MESA 27'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 28,3, 'MESA 28'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 29,3, 'MESA 29'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 30,3, 'MESA 30'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 31,3, 'MESA 31'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 32,3, 'MESA 32'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 33,3, 'MESA 33'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 34,3, 'MESA 34'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 35,3, 'MESA 35'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 36,3, 'MESA 36'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 37,4, 'MESA 37'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 38,4, 'MESA 38'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 39,4, 'MESA 39'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 40,4, 'MESA 40'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 41,4, 'MESA 41'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 42,4, 'MESA 42'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 43,4, 'MESA 43'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 44,4, 'MESA 44'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 45,4, 'MESA 45'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 46,4, 'MESA 46'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 47,4, 'MESA 47'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 48,4, 'MESA 48'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 49,5, 'MESA 49'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 50,5, 'MESA 50'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 51,5, 'MESA 51'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 52,5, 'MESA 52'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 53,5, 'MESA 53'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 54,5, 'MESA 54'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 55,5, 'MESA 55'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 56,5, 'MESA 56'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 57,5, 'MESA 57'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 58,5, 'MESA 58'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 59,5, 'MESA 59'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 60,5, 'MESA 60'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 61,6, 'MESA 61'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 62,6, 'MESA 62'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 63,6, 'MESA 63'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 64,6, 'MESA 64'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 65,6, 'MESA 65'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 66,6, 'MESA 66'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 67,6, 'MESA 67'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 68,6, 'MESA 68'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 69,6, 'MESA 69'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 70,6, 'MESA 70'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 71,6, 'MESA 71'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 72,6, 'MESA 72'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 73,7, 'MESA 73'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 74,7, 'MESA 74'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 75,7, 'MESA 75'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 76,7, 'MESA 76'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 77,7, 'MESA 77'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 78,7, 'MESA 78'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 79,7, 'MESA 79'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 80,7, 'MESA 80'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 81,7, 'MESA 81'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 82,7, 'MESA 82'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 83,7, 'MESA 83'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 84,7, 'MESA 84'		, 1
EXECUTE [dbo].[PG_CI_SUB_ESTACION_TRABAJO] 0, 0, 85,8, 'MESA 85'		, 1
-- =================================================================================
GO


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO]
GO
-- //////////////////////////////////////////////////////////////
-- //				CI - MOTIVO_ORDEN_TRABAJO
-- //////////////////////////////////////////////////////////////
CREATE PROCEDURE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_K_MOTIVO_ORDEN_TRABAJO			INT,
	@PP_D_MOTIVO_ORDEN_TRABAJO			VARCHAR(100),
	@PP_L_MOTIVO_ORDEN_TRABAJO			INT,
	@PP_CLASE_MOTIVO					INT
AS				
	-- ===============================
DECLARE @VP_K_EXISTE	INT
	SELECT	@VP_K_EXISTE =	K_MOTIVO_ORDEN_TRABAJO
	FROM	MOTIVO_ORDEN_TRABAJO
	WHERE	K_MOTIVO_ORDEN_TRABAJO	= @PP_K_MOTIVO_ORDEN_TRABAJO
	-- ===========================
IF @VP_K_EXISTE IS NULL
	INSERT INTO MOTIVO_ORDEN_TRABAJO
			(	[K_MOTIVO_ORDEN_TRABAJO],	[D_MOTIVO_ORDEN_TRABAJO], 
				[L_MOTIVO_ORDEN_TRABAJO],	[CLASE_MOTIVO]	)
	VALUES	
			(	@PP_K_MOTIVO_ORDEN_TRABAJO, @PP_D_MOTIVO_ORDEN_TRABAJO,
				@PP_L_MOTIVO_ORDEN_TRABAJO,	@PP_CLASE_MOTIVO	)
ELSE
	UPDATE MOTIVO_ORDEN_TRABAJO
	SET
			[D_MOTIVO_ORDEN_TRABAJO]		= @PP_D_MOTIVO_ORDEN_TRABAJO,
			[L_MOTIVO_ORDEN_TRABAJO]		= @PP_L_MOTIVO_ORDEN_TRABAJO,
			[CLASE_MOTIVO]					= @PP_CLASE_MOTIVO
	WHERE	[K_MOTIVO_ORDEN_TRABAJO]		= @PP_K_MOTIVO_ORDEN_TRABAJO
GO
-- =================================================================================
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 0,'(NO APLICA)', 1					, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 19,'Dado vencido', 1				, 2			------	PROBLEMAS DE DADOS
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 20,'Muesca dañada', 1				, 2			------	PROBLEMAS DE DADOS
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 21,'Dado quebrado', 1				, 2			------	PROBLEMAS DE DADOS
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 22,'Placa', 1						, 2			------	PROBLEMAS DE DADOS
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 23,'Gomas', 1						, 2			------	PROBLEMAS DE DADOS
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 24,'Filo', 1						, 2			------	PROBLEMAS DE DADOS
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 25,'Dado recorrido', 1				, 2			------	PROBLEMAS DE DADOS
--------------------------------------------------------------------------------------------------------------------------
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 1,'Aire evaporativo sin base', 1	, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 2,'Banda floja', 1					, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 3,'Baquelitas resecas', 1			, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 4,'Base quebrada', 1				, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 5,'Bloqueo', 1						, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 6,'Bomba de agua dañada', 1		, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 7,'Boton danado', 1				, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 8,'Buje suelto', 1					, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 9,'Cabezal desnivelado', 1			, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 10,'Cable suelto', 1				, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 11,'Cadena dañada', 1				, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 12,'Cadena salida', 1				, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 13,'Caja eléctrica sin tapa', 1	, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 14,'Cambio de plafones', 1			, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 15,'Carrito dañado', 1				, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 16,'Chainblock atorado', 1			, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 17,'Chainblock dañado', 1			, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 18,'Chapa floja', 1				, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 26,'Desanivelada', 1				, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 27,'Ductos de aire sucio', 1		, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 28,'Evaporativo dañado', 1			, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 29,'Fabricar base', 1				, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 30,'Fabricar tope', 1				, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 31,'Falla de botón', 1				, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 32,'Falla de corte', 1				, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 33,'Falla de costura', 1			, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 34,'Falla de fusible', 1			, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 35,'Falla de lampara', 1			, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 36,'Falla de máquina', 1			, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 37,'Falla de polea', 1				, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 38,'Falla de prensa', 1			, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 39,'Falla de rebajadora', 1		, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 40,'Falla de sello', 1				, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 41,'Falla de sensor', 1			, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 42,'Falla de tabla', 1				, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 43,'Falla de zinc', 1				, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 44,'Falla eléctrica', 1			, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 45,'Filo dañado', 1				, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 46,'Foco fundido', 1				, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 47,'Fuga de aceite', 1				, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 48,'Guarda caída', 1				, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 49,'Guarda dañada', 1				, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 50,'Humo en calentones', 1			, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 51,'Intalación eléctrica', 1		, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 52,'Lampara fundida', 1			, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 53,'Manometro dañado', 1			, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 54,'Máquina lenta', 1				, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 55,'Mejora de Zinc', 1				, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 56,'Mesa quebrada', 1				, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 57,'Minisplit no enfria', 1		, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 58,'Motor dañado', 1				, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 59,'Navaja dañada', 1				, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 60,'Navaja terminada', 1			, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 61,'No corta', 1					, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 62,'No mete placas', 1				, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 63,'No prende', 1					, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 64,'Obstrucción de material', 1	, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 65,'Palanca dañada', 1				, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 66,'Partes flojas', 1				, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 67,'Pieza atorada', 1				, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 68,'Pieza jalada', 1				, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 69,'Piezas pegadas', 1				, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 70,'Piezas rayadas', 1				, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 71,'Plafón dañado', 1				, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 72,'PM', 1							, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 73,'Puerta dañada', 1				, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 74,'Puerta floja', 1				, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 75,'Rectificado', 1				, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 76,'Reparación de evaporativos', 1	, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 77,'Resetear contador', 1			, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 78,'Rollo de papel', 1				, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 79,'Ruido', 1						, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 80,'Sello dañado', 1				, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 81,'Sello despegado', 1			, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 82,'Sensor no funciona', 1			, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 83,'Sensor obstruido', 1			, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 84,'Sensor sucio', 1				, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 85,'Sensor tapado', 1				, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 86,'Serpentina dañada', 1			, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 87,'Servicio', 1					, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 88,'Servomotor activado', 1		, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 89,'Setup', 1						, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 90,'Sproket dañados', 1			, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 91,'Suciedad', 1					, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 92,'Sujetador dañado', 1			, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 93,'Tabla atorada', 1				, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 94,'Tabla dañada', 1				, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 95,'Tope suelto', 1				, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 96,'Tornillo capado', 1			, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 97,'Tornillo flojo', 1				, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 98,'Trampa de grasa', 1			, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 99,'Valvula de aire dañada', 1		, 1
EXECUTE [dbo].[PG_CI_MOTIVO_ORDEN_TRABAJO] 0, 0, 100,'Vibración', 1					, 1
-- =================================================================================
GO


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CI_TIPO_ORDEN_TRABAJO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO]
GO
-- //////////////////////////////////////////////////////////////
-- //				CI - TIPO_ORDEN_TRABAJO
-- //////////////////////////////////////////////////////////////
CREATE PROCEDURE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_K_TIPO_ORDEN_TRABAJO			INT,
	@PP_D_TIPO_ORDEN_TRABAJO			VARCHAR(100),
	@PP_L_TIPO_ORDEN_TRABAJO			INT,
	@PP_CLASE_TIPO						INT
AS				
	-- ===============================
DECLARE @VP_K_EXISTE	INT
	SELECT	@VP_K_EXISTE =	K_TIPO_ORDEN_TRABAJO
	FROM	TIPO_ORDEN_TRABAJO
	WHERE	K_TIPO_ORDEN_TRABAJO	= @PP_K_TIPO_ORDEN_TRABAJO
	-- ===========================
IF @VP_K_EXISTE IS NULL
	INSERT INTO TIPO_ORDEN_TRABAJO
			(	[K_TIPO_ORDEN_TRABAJO],	[D_TIPO_ORDEN_TRABAJO], 
				[L_TIPO_ORDEN_TRABAJO],	[CLASE_TIPO]		)
	VALUES	
			(	@PP_K_TIPO_ORDEN_TRABAJO, @PP_D_TIPO_ORDEN_TRABAJO,
				@PP_L_TIPO_ORDEN_TRABAJO, @PP_CLASE_TIPO	 )
ELSE
	UPDATE TIPO_ORDEN_TRABAJO
	SET
			[D_TIPO_ORDEN_TRABAJO]		= @PP_D_TIPO_ORDEN_TRABAJO,
			[L_TIPO_ORDEN_TRABAJO]		= @PP_L_TIPO_ORDEN_TRABAJO,
			[CLASE_TIPO]				= @PP_CLASE_TIPO
	WHERE	[K_TIPO_ORDEN_TRABAJO]		= @PP_K_TIPO_ORDEN_TRABAJO
GO
-- =================================================================================
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 0,'(NO APLICA)', 1					, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 1,'Fabricación Dado', 1				, 2
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 2,'Mantenimiento Dado', 1			, 2
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 3,'Reparación Dado', 1				, 1
--------------------------------------------------------------------------			, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 10,'Ajuste', 1						, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 11,'Banda floja', 1					, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 12,'Bomba dañada', 1					, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 13,'Cable suelto', 1					, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 14,'Cadena dañada', 1				, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 15,'Carrito dañado', 1				, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 16,'Chumacera dañada', 1				, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 17,'Desgaste de filo', 1				, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 18,'Desgaste de navaja', 1			, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 19,'Fabricación', 1					, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 20,'Falla de amortiguador', 1		, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 21,'Falla de chainblock', 1			, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 22,'Falla de corte', 1				, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 23,'Falla de costura', 1				, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 24,'Falla de drenaje', 1				, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 25,'Falla de evaporativo', 1			, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 26,'Falla de fusible', 1				, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 27,'Falla de instalaciones', 1		, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 28,'Falla de lampara', 1				, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 29,'Falla de máquina', 1				, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 30,'Falla de mesa', 1				, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 31,'Falla de minisplt', 1			, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 32,'Falla de nivel', 1				, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 33,'Falla de operador', 1			, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 34,'Falla de palanca', 1				, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 35,'Falla de perforadora', 1			, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 36,'Falla de PM', 1					, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 37,'Falla de prensa', 1				, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 38,'Falla de push botón', 1			, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 39,'Falla de rebajadora', 1			, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 40,'Falla de sensor', 1				, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 41,'Falla de servomotor', 1			, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 42,'Falla de setup', 1				, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 43,'Falla de tabla', 1				, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 44,'Falla de tope', 1				, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 45,'Falla eléctrica', 1				, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 46,'Falla mecánica', 1				, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 47,'Falta de lubricación', 1			, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 48,'Falta de PM', 1					, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 49,'Falta de tornillos', 1			, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 50,'Fuga de aceite', 1				, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 51,'Guarda dañada', 1				, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 52,'Lámpara fundida', 1				, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 53,'Manejo de scrap', 1				, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 54,'Manómetro dañado', 1				, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 55,'Mejora', 1						, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 56,'Mesa dañada', 1					, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 57,'Motor dañado', 1					, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 58,'Otro', 1							, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 59,'Papel mal cortado', 1			, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 60,'Pieza atorada', 1				, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 61,'Plafón dañado', 1				, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 62,'Rectificado', 1					, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 63,'Sello  despegado', 1				, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 64,'Sello dañado', 1					, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 65,'Sensor sucio', 1					, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 66,'Servicio', 1						, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 67,'Setup', 1						, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 68,'Suciedad', 1						, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 69,'Tabla atorada', 1				, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 70,'Tabla dañada', 1					, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 71,'Termino de ciclos de corte', 1	, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 72,'Tornillo flojo', 1				, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 73,'Tubería dañada', 1				, 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_TRABAJO] 0, 0, 74,'Vibración', 1					, 1
-- =================================================================================
GO