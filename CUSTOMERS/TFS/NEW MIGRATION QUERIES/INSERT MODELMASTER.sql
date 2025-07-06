USE [DEVDBNEW]
GO

INSERT INTO [dbo].[ModelMaster]
           ([ModelCode]
           ,[ModelName]
           ,[Remark]
           ,[IsDelete]
           ,[IsActive]
           ,[GroupOfCompanyID]
           ,[CreatedUser]
           ,[CreatedDate]
           ,[ModifiedUser]
           ,[ModifiedDate]
           ,[DataTransfer])
     VALUES
           ('002'--<ModelCode, nvarchar(15),>
           ,'NON CLOTHING'--<ModelName, nvarchar(100),>
           ,''--<Remark, nvarchar(150),>
           ,0--<IsDelete, bit,>
           ,1--<IsActive, bit,>
           ,'103'--<GroupOfCompanyID, int,>
           ,'SARASA'--<CreatedUser, nvarchar(50),>
           ,GETDATE()--<CreatedDate, datetime,>
           ,'SARASA'--<ModifiedUser, nvarchar(50),>
           ,GETDATE()--<ModifiedDate, datetime,>
           ,0--<DataTransfer, int,>
           )
GO

SELECT * FROM [ModelMaster]

