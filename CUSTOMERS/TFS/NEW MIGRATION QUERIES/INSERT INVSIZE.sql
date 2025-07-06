USE [DEVDBNEW]
GO

INSERT INTO [dbo].[InvSize]
           ([SizeCode]
           ,[SizeName]
           ,[Remark]
           ,[IsDelete]
           ,[GroupOfCompanyID]
           ,[CreatedUser]
           ,[CreatedDate]
           ,[ModifiedUser]
           ,[ModifiedDate]
           ,[DataTransfer])
     VALUES
           ('001'--<MainSIZECode, nvarchar(15),>
           ,'DEFAULT'--<MainSIZEName, nvarchar(100),>
           ,''--<Remark, nvarchar(150),>
           ,0--<IsDelete, bit,>
           ,'103'--<GroupOfCompanyID, int,>
           ,'SARASA'--<CreatedUser, nvarchar(50),>
           ,GETDATE()--<CreatedDate, datetime,>
           ,'SARASA'--<ModifiedUser, nvarchar(50),>
           ,GETDATE()--<ModifiedDate, datetime,>
           ,'0'--<DataTransfer, int,>
           )
GO

SELECT * FROM InvSize




INSERT INTO [dbo].[InvSize]
           ([SizeCode]
           ,[SizeName]
           ,[Remark]
           ,[IsDelete]
           ,[GroupOfCompanyID]
           ,[CreatedUser]
           ,[CreatedDate]
           ,[ModifiedUser]
           ,[ModifiedDate]
           ,[DataTransfer])
SELECT DISTINCT ROW_NUMBER() OVER(ORDER BY SIZE)+1,SIZE,'',0,
'103','SARASA',GETDATE(),'SARASA',GETDATE(),0 FROM #C

DROP TABLE #C


SELECT DISTINCT SIZE INTO #C FROM PRODUCTLIST WHERE SIZE IS NOT NULL AND SIZE<>''

UPDATE InvSize SET SizeCode=RIGHT('000' + CAST(SizeCode AS VARCHAR(3)), 3)