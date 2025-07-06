USE [DEVDBNEW]
GO

INSERT INTO [dbo].[WarrantyMaster]
           ([WarrantyCode]
           ,[WarrantyName]
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
           ('001'--<Main[CUT AND FIT]Code, nvarchar(15),>
           ,'DEFAULT'--<Main[CUT AND FIT]Name, nvarchar(100),>
           ,''--<Remark, nvarchar(150),>
           ,0--<IsDelete, bit,>
           ,1
           ,'103'--<GroupOfCompanyID, int,>
           ,'SARASA'--<CreatedUser, nvarchar(50),>
           ,GETDATE()--<CreatedDate, datetime,>
           ,'SARASA'--<ModifiedUser, nvarchar(50),>
           ,GETDATE()--<ModifiedDate, datetime,>
           ,'0'--<DataTransfer, int,>
           )
GO

SELECT * FROM [WarrantyMaster]

INSERT INTO [dbo].[WarrantyMaster]
           ([WarrantyCode]
           ,[WarrantyName]
           ,[Remark]
           ,[IsDelete]
           ,[IsActive]
           ,[GroupOfCompanyID]
           ,[CreatedUser]
           ,[CreatedDate]
           ,[ModifiedUser]
           ,[ModifiedDate]
           ,[DataTransfer])

SELECT DISTINCT ROW_NUMBER() OVER(ORDER BY [CUT AND FIT])+1,[CUT AND FIT],'',0,1,
'103','SARASA',GETDATE(),'SARASA',GETDATE(),0 FROM #C

DROP TABLE #C


SELECT DISTINCT [CUT AND FIT] INTO #C FROM PRODUCTLIST WHERE [CUT AND FIT] IS NOT NULL AND [CUT AND FIT]<>''

UPDATE [WarrantyMaster] SET [WarrantyCode]=RIGHT('000' + CAST([WarrantyCode] AS VARCHAR(3)), 3)