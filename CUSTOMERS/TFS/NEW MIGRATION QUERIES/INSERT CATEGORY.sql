
delete [InvCategory]
dbcc checkident('[InvCategory]','reseed',0)



INSERT INTO [dbo].[InvCategory]
           ([InvDepartmentID]
           ,[CategoryCode]
           ,[CategoryName]
           ,[Remark]
           ,[IsNonExchangeable]
           ,[IsDelete]
           ,[GroupOfCompanyID]
           ,[CreatedUser]
           ,[CreatedDate]
           ,[ModifiedUser]
           ,[ModifiedDate]
           ,[DataTransfer])
   values(
		  '1','1','HIDE','',0,0,'103','SARASA',getdate(),'SARASA',getdate(),0)




INSERT INTO [dbo].[InvCategory]
           ([InvDepartmentID]
           ,[CategoryCode]
           ,[CategoryName]
           ,[Remark]
           ,[IsNonExchangeable]
           ,[IsDelete]
           ,[GroupOfCompanyID]
           ,[CreatedUser]
           ,[CreatedDate]
           ,[ModifiedUser]
           ,[ModifiedDate]
           ,[DataTransfer])          
select distinct DP.InvDepartmentID,DC.CATEGORYCODE,DC.CATEGORYNAME,'',0,0,'103','SARASA',GETDATE(),'SARASA',GETDATE(),0 
from Dependancy DC
join InvDepartment DP on DC.DEPARTMENTCODE=DP.DepartmentCode order by DP.InvDepartmentID

