SELECT RIGHT('0' + CAST(categorycode AS VARCHAR(2)), 2) FROM DEPENDANCY

update DEPENDANCY set categorycode=RIGHT('0' + CAST(categorycode AS VARCHAR(2)), 2)

select distinct departmentcode,concat(departmentcode,categorycode)as categorycode FROM DEPENDANCY

update DEPENDANCY set categorycode=concat(departmentcode,categorycode)

SELECT distinct RIGHT('00' + CAST(subcategorycode AS VARCHAR(3)), 3) FROM DEPENDANCY

update DEPENDANCY set subcategorycode=RIGHT('00' + CAST(subcategorycode AS VARCHAR(3)), 3)

select distinct departmentcode,categorycode,concat(categorycode,subcategorycode)as subcategorycode FROM DEPENDANCY

update DEPENDANCY set subcategorycode=concat(categorycode,subcategorycode)