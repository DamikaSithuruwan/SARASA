
INSERT INTO [dbo].[MainBrandMaster]
           ([MainBrandCode]
           ,[MainBrandName]
           ,[Remark]
           ,[IsDelete]
           ,[BrandName]
           ,[IsActive]
           ,[GroupOfCompanyID]
           ,[CreatedUser]
           ,[CreatedDate]
           ,[ModifiedUser]
           ,[ModifiedDate]
           ,[DataTransfer])
     VALUES
           ('001'--<MainBrandCode, nvarchar(15),>
           ,'DEFAULT'--<MainBrandName, nvarchar(100),>
           ,''--<Remark, nvarchar(150),>
           ,0--<IsDelete, bit,>
           ,'DEFAULT'--<BrandName, nvarchar(max),>
           ,1--<IsActive, bit,>
           ,'103'--<GroupOfCompanyID, int,>
           ,'SARASA'--<CreatedUser, nvarchar(50),>
           ,GETDATE()--<CreatedDate, datetime,>
           ,'SARASA'--<ModifiedUser, nvarchar(50),>
           ,GETDATE()--<ModifiedDate, datetime,>
           ,'0'--<DataTransfer, int,>
           )

INSERT INTO [dbo].[MainBrandMaster]
           ([MainBrandCode]
           ,[MainBrandName]
           ,[Remark]
           ,[IsDelete]
           ,[BrandName]
           ,[IsActive]
           ,[GroupOfCompanyID]
           ,[CreatedUser]
           ,[CreatedDate]
           ,[ModifiedUser]
           ,[ModifiedDate]
           ,[DataTransfer])
SELECT DISTINCT ROW_NUMBER() OVER(ORDER BY BRAND)+1,BRAND,'',0,BRAND,
1,'103','SARASA',GETDATE(),'SARASA',GETDATE(),0 FROM #B



SELECT DISTINCT BRAND INTO #B FROM PRODUCTLIST WHERE BRAND IS NOT NULL AND BRAND<>''



SELECT distinct MAINBRANDCODE, RIGHT('000' + CAST(MAINBRANDCODE AS VARCHAR(3)), 3) FROM [MainBrandMaster]
ORDER BY MAINBRANDCODE

UPDATE [MainBrandMaster] SET MAINBRANDCODE=RIGHT('000' + CAST(MAINBRANDCODE AS VARCHAR(3)), 3)