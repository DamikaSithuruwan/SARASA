select * from productlist
select distinct brandid,colorid,sizeid,modelid,patternid,warrantyid,heelid,waistid from invproductmaster

update pm set pm.brand=ISNULL(pl.brand,'DEFAULT') from productlist pl
join invproductmaster pm on pl.ITEMCODE=pm.ReferenceCode1

update pm set pm.Color=ISNULL(pl.COLOR,'DEFAULT') from productlist pl
join invproductmaster pm on pl.ITEMCODE=pm.ReferenceCode1

update pm set pm.Size=ISNULL(pl.SIZE,'DEFAULT') from productlist pl
join invproductmaster pm on pl.ITEMCODE=pm.ReferenceCode1

update pm set pm.Model=ISNULL(pl.TYPE,'DEFAULT') from productlist pl
join invproductmaster pm on pl.ITEMCODE=pm.ReferenceCode1

update pm set pm.pattern=ISNULL(pl.PATTERN,'DEFAULT') from productlist pl
join invproductmaster pm on pl.ITEMCODE=pm.ReferenceCode1

update pm set pm.warranty=ISNULL(pl.[CUT AND FIT],'DEFAULT') from productlist pl
join invproductmaster pm on pl.ITEMCODE=pm.ReferenceCode1

update pm set pm.heel=ISNULL(pl.SLEEVE,'DEFAULT') from productlist pl
join invproductmaster pm on pl.ITEMCODE=pm.ReferenceCode1

update pm set pm.waist=ISNULL(pl.[SUB 2],'DEFAULT') from productlist pl
join invproductmaster pm on pl.ITEMCODE=pm.ReferenceCode1
-----------------------------------------------------------------------------------------------------

update pm set pm.brandid=bm.mainbrandmasterid from  MainBrandMaster bm 
join invproductmaster pm on bm.mainbrandname=pm.brand

update pm set pm.ColorID=cm.MainColorMasterID from  MainColorMaster cm 
join invproductmaster pm on cm.MainColorName=pm.Color

update pm set pm.sizeid=sz.invsizeid from  InvSize sz 
join invproductmaster pm on sz.sizename=pm.size

update pm set pm.modelid=mm.modelmasterid from  modelmaster mm 
join invproductmaster pm on mm.modelname=pm.model

update pm set pm.patternid=pms.patternmasterid from  PatternMaster pms 
join invproductmaster pm on pms.patternname=pm.pattern

update pm set pm.warrantyid=wm.warrantymasterid from  warrantymaster wm 
join invproductmaster pm on wm.warrantyname=pm.warranty

update pm set pm.heelid=hm.heelmasterid from  heelmaster hm 
join invproductmaster pm on hm.heelname=pm.heel

update pm set pm.waistid=wm.waistmasterid from  WaistMaster wm 
join invproductmaster pm on wm.waistname=pm.waist

select * from WaistMaster

update invproductmaster set WaistID=1 where WaistID=0

update invproductmaster set DataTransfer=0