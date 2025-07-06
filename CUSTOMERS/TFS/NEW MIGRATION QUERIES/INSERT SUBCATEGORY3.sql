USE [DEVDBNEW]
GO

INSERT INTO [dbo].[InvSubCategory3]
           ([InvSubCategoryID]
           ,[InvCategoryID]
           ,[InvDepartmentID]
           ,[SubCategory3Code]
           ,[SubCategory3Name]
           ,[InvSubCategory2ID]
           ,[Remark]
           ,[IsDelete]
           ,[IsActive]
           ,[GroupOfCompanyID]
           ,[CreatedUser]
           ,[CreatedDate]
           ,[ModifiedUser]
           ,[ModifiedDate]
           ,[DataTransfer])
		   values(
		  '1','1','1','0','HIDE HIDE HIDE','1','',0,0,'103','SARASA',getdate(),'SARASA',getdate(),0)

INSERT INTO [dbo].[InvSubCategory3]
           ([InvSubCategoryID]
           ,[InvCategoryID]
           ,[InvDepartmentID]
           ,[SubCategory3Code]
           ,[SubCategory3Name]
           ,[InvSubCategory2ID]
           ,[Remark]
           ,[IsDelete]
           ,[IsActive]
           ,[GroupOfCompanyID]
           ,[CreatedUser]
           ,[CreatedDate]
           ,[ModifiedUser]
           ,[ModifiedDate]
           ,[DataTransfer])
SELECT SC.InvSubCategoryID,C.InvCategoryID,D.InvDepartmentID,ROW_NUMBER() OVER(ORDER BY SC.InvSubCategoryID),
CONCAT(D.DepartmentName,' ',SC.SubCategoryName,' ',SC2.SubCategory2Name) AS SUBCATEGORY3NAME,SC2.InvSubCategory2ID,
'',0,1,'103','SARASA',getdate(),'SARASA',getdate(),0
FROM [DEPENDANCY] DP
JOIN InvDepartment D ON DP.DEPARTMENTCODE=D.DepartmentCode
JOIN InvCategory C ON DP.CATEGORYCODE=C.CategoryCode
JOIN InvSubCategory SC ON DP.SUBCATEGORYCODE=SC.SubCategoryCode
JOIN InvSubCategory2 SC2 ON DP.SUBCATEGORY2CODE=SC2.SubCategory2Code

SELECT distinct SUBCATEGORY3CODE, RIGHT('000000' + CAST(SUBCATEGORY3CODE AS VARCHAR(3)), 6) FROM [InvSubCategory3]
ORDER BY SUBCATEGORY3CODE

UPDATE [InvSubCategory3] SET SUBCATEGORY3CODE=RIGHT('000000' + CAST(SUBCATEGORY3CODE AS VARCHAR(3)), 6)

