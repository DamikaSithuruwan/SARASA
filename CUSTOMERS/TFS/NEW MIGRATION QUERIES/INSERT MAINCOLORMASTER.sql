USE [DEVDBNEW]
GO

INSERT INTO [dbo].[MainColorMaster]
           ([MainColorCode]
           ,[MainColorName]
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
           ('001'--<MainCOLORCode, nvarchar(15),>
           ,'DEFAULT'--<MainCOLORName, nvarchar(100),>
           ,''--<Remark, nvarchar(150),>
           ,0--<IsDelete, bit,>
           ,1--<IsActive, bit,>
           ,'103'--<GroupOfCompanyID, int,>
           ,'SARASA'--<CreatedUser, nvarchar(50),>
           ,GETDATE()--<CreatedDate, datetime,>
           ,'SARASA'--<ModifiedUser, nvarchar(50),>
           ,GETDATE()--<ModifiedDate, datetime,>
           ,'0'--<DataTransfer, int,>
           )
GO

SELECT * FROM MainColorMaster

INSERT INTO [dbo].[MainColorMaster]
           ([MainColorCode]
           ,[MainColorName]
           ,[Remark]
           ,[IsDelete]
           ,[IsActive]
           ,[GroupOfCompanyID]
           ,[CreatedUser]
           ,[CreatedDate]
           ,[ModifiedUser]
           ,[ModifiedDate]
           ,[DataTransfer])
SELECT DISTINCT ROW_NUMBER() OVER(ORDER BY COLOR)+1,COLOR,'',0,
1,'103','SARASA',GETDATE(),'SARASA',GETDATE(),0 FROM #C

DROP TABLE #C


SELECT DISTINCT COLOR INTO #C FROM PRODUCTLIST WHERE COLOR IS NOT NULL AND COLOR<>''

UPDATE [MainColorMaster] SET [MainColorCode]=RIGHT('000' + CAST([MainColorCode] AS VARCHAR(3)), 3)