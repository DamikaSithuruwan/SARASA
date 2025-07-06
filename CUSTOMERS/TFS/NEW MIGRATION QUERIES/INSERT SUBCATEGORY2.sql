USE [DEVDBNEW]
GO

delete [InvSubCategory2]
dbcc checkident('InvSubCategory2','reseed',0)

INSERT INTO [dbo].[InvSubCategory2]
           ([InvSubCategoryID]
           ,[SubCategory2Code]
           ,[SubCategory2Name]
           ,[Remark]
           ,[IsDelete]
           ,[GroupOfCompanyID]
           ,[CreatedUser]
           ,[CreatedDate]
           ,[ModifiedUser]
           ,[ModifiedDate]
           ,[DataTransfer])
	   values(
		  '1','1','HIDE','',0,'103','SARASA',getdate(),'SARASA',getdate(),0)


INSERT INTO [dbo].[InvSubCategory2]
           ([InvSubCategoryID]
           ,[SubCategory2Code]
           ,[SubCategory2Name]
           ,[Remark]
           ,[IsDelete]
           ,[GroupOfCompanyID]
           ,[CreatedUser]
           ,[CreatedDate]
           ,[ModifiedUser]
           ,[ModifiedDate]
           ,[DataTransfer])

select distinct S.InvSubCategoryID,DC.[SUBCATEGORY2CODE],DC.[SubCategory2Name],'',0,'103','SARASA',GETDATE(),'SARASA',GETDATE(),0 from Dependancy DC
join InvSubCategory S on DC.SUBCATEGORYCODE=S.SubCategoryCode order by S.InvSubCategoryID