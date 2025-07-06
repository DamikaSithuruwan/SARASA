
delete [InvSubCategory]
dbcc checkident('InvSubCategory','reseed',0)


INSERT INTO [dbo].[InvSubCategory]
           ([InvCategoryID]
           ,[SubCategoryCode]
           ,[SubCategoryName]
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


INSERT INTO [dbo].[InvSubCategory]
           ([InvCategoryID]
           ,[SubCategoryCode]
           ,[SubCategoryName]
           ,[Remark]
           ,[IsDelete]
           ,[GroupOfCompanyID]
           ,[CreatedUser]
           ,[CreatedDate]
           ,[ModifiedUser]
           ,[ModifiedDate]
           ,[DataTransfer])

select distinct C.InvCategoryID,DC.SUBCATEGORYCODE,DC.SUBCATEGORYNAME,'',0,'103','SARASA',GETDATE(),'SARASA',GETDATE(),0 from Dependancy DC
join InvCategory C on DC.CATEGORYCODE=C.CategoryCode order by C.InvCategoryID
