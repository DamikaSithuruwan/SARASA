USE [DEVDBNEW]
GO

INSERT INTO [dbo].[InvDepartment]
           ([DepartmentCode]
           ,[DepartmentName]
           ,[Remark]
           ,[IsDelete]
           ,[GdCommission]
           ,[GroupOfCompanyID]
           ,[CreatedUser]
           ,[CreatedDate]
           ,[ModifiedUser]
           ,[ModifiedDate]
           ,[DataTransfer])
select distinct
          'C0000'
      ,'HIDE' 
           ,'' [Remark]
           ,0 [IsDelete]
           ,0
           ,103 [GroupOfCompanyID]
             ,'SARASA' [CreatedUser]
           ,Getdate() [CreatedDate]
           ,'SARASA'[ModifiedUser]
           ,Getdate() [ModifiedDate]
           ,0[DataTransfer]

