USE [DEVDBNEW]
GO

INSERT INTO [dbo].[WaistMaster]
           ([WaistCode]
           ,[WaistName]
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
           ('0001'--<Main[SUB 2]Code, nvarchar(15),>
           ,'DEFAULT'--<Main[SUB 2]Name, nvarchar(100),>
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

SELECT * FROM [WaistMaster]

INSERT INTO [dbo].[WaistMaster]
           ([WaistCode]
           ,[WaistName]
           ,[Remark]
           ,[IsDelete]
           ,[IsActive]
           ,[GroupOfCompanyID]
           ,[CreatedUser]
           ,[CreatedDate]
           ,[ModifiedUser]
           ,[ModifiedDate]
           ,[DataTransfer])
           
SELECT DISTINCT ROW_NUMBER() OVER(ORDER BY [SUB 2])+1,[SUB 2],'',0,1,
'103','SARASA',GETDATE(),'SARASA',GETDATE(),0 FROM #C

DROP TABLE #C


SELECT DISTINCT [SUB 2] INTO #C FROM PRODUCTLIST WHERE [SUB 2] IS NOT NULL AND [SUB 2]<>''

UPDATE [WaistMaster] SET [WaistCode]=RIGHT('0000' + CAST([WaistCode] AS VARCHAR(3)), 4)