USE [DEVDBNEW]
GO

INSERT INTO [dbo].[HeelMaster]
           ([HeelCode]
           ,[HeelName]
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
           ('001'--<MainSLEEVECode, nvarchar(15),>
           ,'DEFAULT'--<MainSLEEVEName, nvarchar(100),>
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

SELECT * FROM [HeelMaster]

INSERT INTO [dbo].[HeelMaster]
           ([HeelCode]
           ,[HeelName]
           ,[Remark]
           ,[IsDelete]
           ,[IsActive]
           ,[GroupOfCompanyID]
           ,[CreatedUser]
           ,[CreatedDate]
           ,[ModifiedUser]
           ,[ModifiedDate]
           ,[DataTransfer])

SELECT DISTINCT ROW_NUMBER() OVER(ORDER BY SLEEVE)+1,SLEEVE,'',0,1,
'103','SARASA',GETDATE(),'SARASA',GETDATE(),0 FROM #C

DROP TABLE #C


SELECT DISTINCT SLEEVE INTO #C FROM PRODUCTLIST WHERE SLEEVE IS NOT NULL AND SLEEVE<>''

UPDATE [HeelMaster] SET [HeelCode]=RIGHT('000' + CAST([HeelCode] AS VARCHAR(3)), 3)