USE [DEVDBNEW]
GO

INSERT INTO [dbo].[PatternMaster]
           ([PatternCode]
           ,[PatternName]
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
           ('001'--<MainPATTERNCode, nvarchar(15),>
           ,'DEFAULT'--<MainPATTERNName, nvarchar(100),>
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

SELECT * FROM [PatternMaster]

INSERT INTO [dbo].[PatternMaster]
           ([PatternCode]
           ,[PatternName]
           ,[Remark]
           ,[IsDelete]
           ,[IsActive]
           ,[GroupOfCompanyID]
           ,[CreatedUser]
           ,[CreatedDate]
           ,[ModifiedUser]
           ,[ModifiedDate]
           ,[DataTransfer])

SELECT DISTINCT ROW_NUMBER() OVER(ORDER BY PATTERN)+1,PATTERN,'',0,1,
'103','SARASA',GETDATE(),'SARASA',GETDATE(),0 FROM #C

DROP TABLE #C


SELECT DISTINCT PATTERN INTO #C FROM PRODUCTLIST WHERE PATTERN IS NOT NULL AND PATTERN<>''

UPDATE [PatternMaster] SET [PatternCode]=RIGHT('000' + CAST([PatternCode] AS VARCHAR(3)), 3)