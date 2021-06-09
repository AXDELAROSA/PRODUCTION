-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			
-- // OPERACION:		MATERIAL PROGRAMADO LOG 
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	07/JUN/2021
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02]
GO

-- //////////////////////////////////////////////////////////////

-- //////////////////////////////////////////////////////////////
-- // DROPs
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MATERIAL_PROGRAMADO_LOG]') AND type in (N'U'))
	DROP TABLE [dbo].[MATERIAL_PROGRAMADO_LOG]
GO




-- //////////////////////////////////////////////////////////////
-- // MATERIAL_PROGRAMADO_LOG
-- //////////////////////////////////////////////////////////////

CREATE TABLE [dbo].[MATERIAL_PROGRAMADO_LOG] (
	[K_MATERIAL_PROGRAMADO_LOG]					[INT] IDENTITY (1,1)			NOT NULL,
	-- =================================
	[K_TIPO_EVENTO_KIT]			[INT]			NOT NULL,
	-- =================================		
	[SERIAL]					VARCHAR(100)	NOT NULL,
	[ITEM_NO]					VARCHAR(100)	NOT NULL,	
	[USUARIO_EVENTO]			VARCHAR(100)	NOT NULL,	-- CREAR USUARIO DE PEARL PARA CADA EVENTO
	[ESTACION]					VARCHAR(100)	NOT NULL,	-- NOMBRE DE LA COMPUTADORA
	[K_RESPONSABLE]				[INT]			NOT NULL,	-- QUIEN REALIZA EL ESCANEO
	[CODIGO_ETIQUETA]			VARCHAR(150)	NOT NULL,	-- CODIGO 2D
	[F_LOG]						DATETIME		NOT NULL
)ON [PRIMARY]	
GO

-- //////////////////////////////////////////////////////

ALTER TABLE [dbo].[MATERIAL_PROGRAMADO_LOG]
	ADD CONSTRAINT [PK_MATERIAL_PROGRAMADO_LOG]
		PRIMARY KEY CLUSTERED ([K_MATERIAL_PROGRAMADO_LOG])
GO

-- //////////////////////////////////////////////////////////////


--ALTER TABLE [dbo].[PIEL_LOG] ADD 
--	CONSTRAINT [FK_PIEL_LOG_01]  
--		FOREIGN KEY ([K_TIPO_PIEL_LOG]) 
--		REFERENCES [dbo].[TIPO_PIEL_LOG] ([K_TIPO_PIEL_LOG])
	--CONSTRAINT [FK_PIEL_LOG_02]  
	--	FOREIGN KEY ([K_TIPO_PIEL_LOG]) 
	--	REFERENCES [dbo].[TIPO_PIEL_LOG] ([K_TIPO_PIEL_LOG]),
	--CONSTRAINT [FK_PIEL_LOG_03]  
	--	FOREIGN KEY ([K_ESTATUS_PIEL_LOG]) 
	--	REFERENCES [dbo].[ESTATUS_PIEL_LOG] ([K_ESTATUS_PIEL_LOG])
GO


-- //////////////////////////////////////////////////////


ALTER TABLE [dbo].[MATERIAL_PROGRAMADO_LOG] 
	ADD		[K_USUARIO_ALTA]				[INT]		NOT NULL,
			[F_ALTA]						[DATETIME]	NOT NULL,
			[K_USUARIO_CAMBIO]				[INT]		NOT NULL,
			[F_CAMBIO]						[DATETIME]	NOT NULL,
			[L_BORRADO]						[INT]		NOT NULL,
			[K_USUARIO_BAJA]				[INT]		NULL,
			[F_BAJA]						[DATETIME]	NULL;
GO


--ALTER TABLE [dbo].[PIEL_LOG] ADD 
--	CONSTRAINT [FK_PIEL_LOG_USUARIO_ALTA]  
--		FOREIGN KEY ([K_USUARIO_ALTA]) 
--		REFERENCES [dbo].[USUARIO] ([K_USUARIO]),
--	CONSTRAINT [FK_PIEL_LOG_USUARIO_CAMBIO]  
--		FOREIGN KEY ([K_USUARIO_CAMBIO]) 
--		REFERENCES [dbo].[USUARIO] ([K_USUARIO]),
--	CONSTRAINT [FK_PIEL_LOG_USUARIO_BAJA]  
--		FOREIGN KEY ([K_USUARIO_BAJA]) 
--		REFERENCES [dbo].[USUARIO] ([K_USUARIO])
--GO





-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
