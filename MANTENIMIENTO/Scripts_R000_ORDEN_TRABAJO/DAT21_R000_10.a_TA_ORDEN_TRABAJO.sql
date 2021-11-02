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

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ORDEN_TRABAJO_DETALLE]') AND type in (N'U'))
	DROP TABLE [dbo].[ORDEN_TRABAJO_DETALLE]
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
EXECUTE [dbo].[PG_CI_STATUS_ORDEN_TRABAJO] 0,139,40, 'TERMINADA',					'', 'TRMIN',	40,1		-- TERMINADA
EXECUTE [dbo].[PG_CI_STATUS_ORDEN_TRABAJO] 0,139,50, 'RECHAZADA',					'', 'RCHAZ',	50,1		-- RECHAZADA: REQUIERE CAMBIOS O NO SE HIZO CORRECTAMENTE.
EXECUTE [dbo].[PG_CI_STATUS_ORDEN_TRABAJO] 0,139,60, 'CERRADA',						'', 'COMPL',	60,0		-- CERRADA COMPLETA, EL USUARIO ACEPTÓ EL SERVICIO.
EXECUTE [dbo].[PG_CI_STATUS_ORDEN_TRABAJO] 0,139,70, 'CERRADA PARCIAL',				'', 'PARCL',	70,0		-- CERRADA PARCIAL
-- =================================================================================
GO


-- ////////////////////////////////////////////////////////////////
-- //					TIPO_ORDEN_TRABAJO
-- ////////////////////////////////////////////////////////////////
CREATE TABLE [dbo].[TIPO_ORDEN_TRABAJO] (
	[K_TIPO_ORDEN_TRABAJO]				[INT] IDENTITY (1,1)	NOT NULL,
	-- ============================
	[D_TIPO_ORDEN_TRABAJO]				[VARCHAR] (500) NOT NULL
	-- ============================
) ON [PRIMARY]
GO


-- ////////////////////////////////////////////////////////////////
-- //					FALLA_ORDEN_TRABAJO
-- ////////////////////////////////////////////////////////////////
CREATE TABLE [dbo].[FALLA_TRABAJO_DETALLE] (
	[K_FALLA_ORDEN_TRABAJO]				[INT] IDENTITY (1,1)	NOT NULL,
	-- ============================
	[D_FALLA_ORDEN_TRABAJO]				[VARCHAR] (500) NOT NULL
	-- ============================
) ON [PRIMARY]
GO


-- ////////////////////////////////////////////////////////////////
-- //					ORDEN_TRABAJO_DETALLE
-- ////////////////////////////////////////////////////////////////
CREATE TABLE [dbo].[ORDEN_TRABAJO_DETALLE] (
	[K_ORDEN_TRABAJO_DETALLE]			[INT] IDENTITY (1,1)	NOT NULL,
	[K_ORDEN_TRABAJO]					[INT] NOT NULL,
	-- ============================
	[N_TECNICO_REALIZA]					[INT] NOT NULL,
	[D_TECNICO_REALIZA]					[VARCHAR] (500) NOT NULL,	
	-- ============================
	[DURACION_MINUTOS]					[INT] NOT NULL,
	[ACCION_REALIZADA]					[NVARCHAR](MAX) NOT NULL DEFAULT '',
	[C_ORDEN_TRABAJO]					[NVARCHAR](MAX) NOT NULL DEFAULT ''	
	-- ============================
) ON [PRIMARY]
GO


-- ////////////////////////////////////////////////////////////////
-- //					ORDEN_TRABAJO
-- ////////////////////////////////////////////////////////////////
CREATE TABLE [dbo].[ORDEN_TRABAJO] (
	[K_ORDEN_TRABAJO]						[INT] IDENTITY (1,1)	NOT NULL,
	-- ============================
	[K_USUARIO_SOLICITA]					[INT] NOT NULL,
	[K_USUARIO_RECIBE]						[INT] NOT NULL,
	-- ============================
	[K_ESTACION]							[INT] NOT NULL,
	[K_SUB_ESTACION]						[INT] NOT NULL,
	-- ============================
	[K_STATUS_ORDEN_TRABAJO]				[INT] NOT NULL	DEFAULT 1,
	-- ============================
	[D_ORDEN_TRABAJO]						[NVARCHAR](MAX) NOT NULL DEFAULT '',
	[F_ORDEN_TRABAJO]						[DATE] NOT NULL,
	-- ============================
	[DURACION_TOTAL_MINUTOS]				[INT] NOT NULL,
	-- ============================	
	[K_TIPO_ORDEN_TRABAJO]					[INT] NOT NULL	DEFAULT 1,
	[K_FALLA_ORDEN_TRABAJO]					[INT] NOT NULL	DEFAULT 1,
	-- ============================	
	[RUTA_ORDEN_TRABAJO]					[NVARCHAR](MAX) NULL
	-- ============================
	--[AREA_ORDEN_TRABAJO]					[VARCHAR](500) NOT NULL,
	--[D_USUARIO_SOLICITA]					[VARCHAR](500) NOT NULL,
	---- ============================
	--[D_TECNICO_REALIZA]					[VARCHAR](500) NOT NULL,
	--[D_USUARIO_RECIBE]					[VARCHAR](500) NOT NULL,
	---- ============================
	--[D_SISTEMA_ADICIONAL]					[VARCHAR](500) NOT NULL,
	--[K_SISTEMA_ADICIONAL]					[INT] NOT NULL	DEFAULT 0,
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