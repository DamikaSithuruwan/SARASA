USE [easyway]
GO
/****** Object:  StoredProcedure [dbo].[SP_ResetValue]    Script Date: 02/01/2024 21:01:21 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
ALTER PROCEDURE [dbo].[SP_ResetValue]
@Id 		TinyInt,
@Type 		TinyInt,
@IgnoreMinus	TinyInt,
@LocaCode	Varchar(5),
@ItemFrom	Varchar(15),
@ItemTo		Varchar(15),
@CDate		Varchar(10),
@UserName	Varchar(15)
As
If (@Id=99)
Begin
	If Not Exists (Select Top 1 ItemCode From [tb_Value|X] Where UserId<>@UserName) 
		Truncate Table [tb_Value|X]
	Else
		Delete From [tb_Value|X] Where UserId=@UserName
	Return
End


Declare @Sql Varchar(1000)
Declare @Object Varchar(20)
Declare @ObjectIdx Varchar(21)
Declare @ObjectStk Varchar(21)

Set @Object='tb_' + Rtrim(@UserName) 
Set @ObjectIdx=@Object + 'Idx'
Set @ObjectStk=@Object + 'Stk'

--Idx For Price Change
Set @Sql ='if exists (select * from dbo.sysobjects where id = object_id(N''[dbo].[' + Rtrim(@ObjectIdx) + ']'') and OBJECTPROPERTY(id, N''IsUserTable'') = 1) drop table [dbo].[' + rtrim(@ObjectIdx) + ']'
Exec (@Sql)
Set @Sql ='Create Table ' + Rtrim(@ObjectIdx)  + ' ([LocaCode] Varchar(5) Null ,[ItemCode] Varchar(25) Null , [Idx] Int Not Null Default(0))'
Exec (@Sql)
If (@Id=1) --Category
Begin
	If (@Type=1)
	Begin
		Set @Sql ='Insert Into ' + Rtrim(@ObjectIdx)  + ' ([LocaCode],[ItemCode],[Idx]) Select ''' + @LocaCode + ''',ItemCode, Max(Idx) From tb_PriceChange Where LocaCode='''+ @LocaCode + ''' And (CType=''ITC'' Or CType=''ITU'' Or CType=''PCH'') And CDate < DateAdd(d, 1, ''' + @CDate + ''')' 
		Set @Sql = Rtrim(@Sql) + ' And tb_PriceChange.ItemCode In (Select Item_Code From tb_Item Where tb_Item.Cat_Code Between '''+ @ItemFrom + ''' And  ''' + @ItemTo + ''') Group By ItemCode'
	End
	Else
	Begin
		Set @Sql ='Insert Into ' + Rtrim(@ObjectIdx)  + ' ([LocaCode],[ItemCode],[Idx]) Select ''' + @LocaCode + ''',ItemCode, Max(Idx) From tb_PriceChange Where LocaCode='''+ @LocaCode + ''' And (CType=''ITC'' Or CType=''ITU'' Or CType=''PCH'') And CDate < DateAdd(d, 1, ''' + @CDate + ''')' 
		Set @Sql = Rtrim(@Sql) + ' And tb_PriceChange.ItemCode In (Select Item_Code From tb_Item Where tb_Item.Cat_Code  In (Select Code From tb_TempSelect Where UserName='''+ @UserName + ''' And [Id]=''CVL''  And LocaCode=''' + @LocaCode + ''')) Group By ItemCode'
	End
End
Else If (@Id=2) --SubCategory
Begin
	If (@Type=1)
	Begin
		Set @Sql ='Insert Into ' + Rtrim(@ObjectIdx)  + ' ([LocaCode],[ItemCode],[Idx]) Select ''' + @LocaCode + ''',ItemCode, Max(Idx) From tb_PriceChange Where LocaCode='''+ @LocaCode + ''' And (CType=''ITC'' Or CType=''ITU'' Or CType=''PCH'') And CDate < DateAdd(d, 1, ''' + @CDate + ''')' 
		Set @Sql = Rtrim(@Sql) + ' And tb_PriceChange.ItemCode In (Select Item_Code From tb_Item Where tb_Item.SubCat_Code Between '''+ @ItemFrom + ''' And  ''' + @ItemTo + ''') Group By ItemCode'
	End
	Else
	Begin
		Set @Sql ='Insert Into ' + Rtrim(@ObjectIdx)  + ' ([LocaCode],[ItemCode],[Idx]) Select ''' + @LocaCode + ''',ItemCode, Max(Idx) From tb_PriceChange Where LocaCode='''+ @LocaCode + ''' And (CType=''ITC'' Or CType=''ITU'' Or CType=''PCH'') And CDate < DateAdd(d, 1, ''' + @CDate + ''')' 
		Set @Sql = Rtrim(@Sql) + ' And tb_PriceChange.ItemCode In (Select Item_Code From tb_Item Where tb_Item.SubCat_Code In (Select Code From tb_TempSelect Where UserName='''+ @UserName + ''' And [Id]=''SVL''  And LocaCode=''' + @LocaCode + ''')) Group By ItemCode'
	End
End
Else If (@Id=3) --Supplier
Begin
	If (@Type=1)
	Begin
		Set @Sql ='Insert Into ' + Rtrim(@ObjectIdx)  + ' ([LocaCode],[ItemCode],[Idx]) Select ''' + @LocaCode + ''',ItemCode, Max(Idx) From tb_PriceChange Where LocaCode='''+ @LocaCode + ''' And (CType=''ITC'' Or CType=''ITU'' Or CType=''PCH'') And CDate < DateAdd(d, 1, ''' + @CDate + ''')' 
		Set @Sql = Rtrim(@Sql) + ' And tb_PriceChange.ItemCode In (Select Item_Code From tb_Item Where tb_Item.Supp_Code Between '''+ @ItemFrom + ''' And  ''' + @ItemTo + ''') Group By ItemCode'	
	End
	Else
	Begin
		Set @Sql ='Insert Into ' + Rtrim(@ObjectIdx)  + ' ([LocaCode],[ItemCode],[Idx]) Select ''' + @LocaCode + ''',ItemCode, Max(Idx) From tb_PriceChange Where LocaCode='''+ @LocaCode + ''' And (CType=''ITC'' Or CType=''ITU'' Or CType=''PCH'') And CDate < DateAdd(d, 1, ''' + @CDate + ''')' 
		Set @Sql = Rtrim(@Sql) + ' And tb_PriceChange.ItemCode In (Select Item_Code From tb_Item Where tb_Item.Supp_Code In (Select Code From tb_TempSelect Where UserName='''+ @UserName + ''' And [Id]=''PVL''  And LocaCode=''' + @LocaCode + ''')) Group By ItemCode'	
	End
End
Else If (@Id=4) --Item
Begin
	If (@Type=1)
	Begin
		Set @Sql ='Insert Into ' + Rtrim(@ObjectIdx)  + ' ([LocaCode],[ItemCode],[Idx]) Select ''' + @LocaCode + ''',ItemCode, Max(Idx) From tb_PriceChange Where LocaCode='''+ @LocaCode + ''' And (CType=''ITC'' Or CType=''ITU'' Or CType=''PCH'') And CDate < DateAdd(d, 1, ''' + @CDate + ''')' 
		Set @Sql = Rtrim(@Sql) + ' And tb_PriceChange.ItemCode Between '''+ @ItemFrom + ''' And  ''' + @ItemTo + ''' Group By ItemCode'
	End
	Else
	Begin
		Set @Sql ='Insert Into ' + Rtrim(@ObjectIdx)  + ' ([LocaCode],[ItemCode],[Idx]) Select ''' + @LocaCode + ''',ItemCode, Max(Idx) From tb_PriceChange Where LocaCode='''+ @LocaCode + ''' And (CType=''ITC'' Or CType=''ITU'' Or CType=''PCH'') And CDate < DateAdd(d, 1, ''' + @CDate + ''')' 
		Set @Sql = Rtrim(@Sql) + ' And tb_PriceChange.ItemCode In (Select Code From tb_TempSelect Where UserName='''+ @UserName + ''' And [Id]=''IVL''  And LocaCode=''' + @LocaCode + ''') Group By ItemCode'	
	End
End
Exec (@Sql)


--Price Change
Set @Sql ='if exists (select * from dbo.sysobjects where id = object_id(N''[dbo].[' + Rtrim(@Object) + ']'') and OBJECTPROPERTY(id, N''IsUserTable'') = 1) drop table [dbo].[' + rtrim(@Object) + ']'
Exec (@Sql)
Set @Sql ='Create Table ' + Rtrim(@Object)  + ' ([LocaCode] Varchar(5) Null ,[ItemCode] Varchar(25) Null ,[Stock] Decimal(18,4) Not Null Default(0),[CostPrice] Money Not Null Default(0),[NewCostPrice] Money Not Null Default(0),[NewERetPrice] Money Not Null Default(0),[NewPRetPrice] Money Not Null Default(0),[NewEWholePrice] Money Not Null Default(0))'
Exec (@Sql)
Set @Sql ='Insert Into ' + Rtrim(@Object)  + ' ([LocaCode],[ItemCode],[Stock],[CostPrice],[NewCostPrice],[NewERetPrice],[NewPRetPrice],[NewEWholePrice])'
Set @Sql =Rtrim(@Sql) + ' Select tb_PriceChange.LocaCode,tb_PriceChange.ItemCode,0,tb_PriceChange.NewCostPrice,tb_PriceChange.NewAvgCost,tb_PriceChange.NewERetPrice,tb_PriceChange.NewPRetPrice,tb_PriceChange.NewEWholePrice From tb_PriceChange' 
Set @Sql =Rtrim(@Sql) + ' Inner Join ' + Rtrim(@ObjectIdx) + ' As Idx On tb_PriceChange.ItemCode=Idx.ItemCode And tb_PriceChange.LocaCode=Idx.LocaCode And tb_PriceChange.Idx=Idx.Idx'
Exec (@Sql)
Set @Sql ='Truncate Table ' + Rtrim(@ObjectIdx) 
Exec (@Sql)
Set @Sql ='Drop Table ' + Rtrim(@ObjectIdx) 
Exec (@Sql)

--Stock 
Set @Sql ='if exists (select * from dbo.sysobjects where id = object_id(N''[dbo].[' + Rtrim(@ObjectStk) + ']'') and OBJECTPROPERTY(id, N''IsUserTable'') = 1) drop table [dbo].[' + rtrim(@ObjectStk) + ']'
Exec (@Sql)
Set @Sql ='Create Table ' + Rtrim(@ObjectStk)  + ' ([LocaCode] Varchar(5) Null ,[ItemCode] Varchar(25) Null ,[Stock] Decimal(18,4) Not Null Default(0))'
Exec (@Sql)
If (@Id=1) --Category
Begin
	If (@Type=1)
	Begin
		Set @Sql ='Insert Into ' + Rtrim(@ObjectStk)  + ' ([ItemCode],[LocaCode],[Stock]) Select tb_Stock.ItemCode,tb_Stock.LocaCode,Sum(Case [Id] When ''OPB'' Then (PackSize*Qty)'
		Set @Sql =Rtrim(@Sql) + ' When ''PCH'' Then (PackSize*Qty) When ''PRN'' Then -(PackSize*Qty) When ''INV'' Then -(PackSize*Qty) When ''MKR'' Then (PackSize*Qty)'
		Set @Sql =Rtrim(@Sql) + ' When ''DMG'' Then -(PackSize*Qty) When ''PRD'' Then -(PackSize*Qty) When ''DSC'' Then -(PackSize*Qty) When ''ADD'' Then (PackSize*Qty)' 
		Set @Sql =Rtrim(@Sql) + ' When ''TOG'' Then -(PackSize*Qty) When ''AOD'' Then -(PackSize*Qty) When ''IN1'' Then (PackSize*Qty) When ''IN2'' Then (PackSize*Qty) Else 0 End) From tb_Stock'
		Set @Sql =Rtrim(@Sql) + ' Where tb_Stock.LocaCode=''' + @LocaCode + ''' And tb_Stock.Status=1 And tb_Stock.ItemCode In (Select Item_Code From tb_Item Where tb_Item.Cat_Code Between ''' + @ItemFrom + ''' And  ''' + @ItemTo + ''')'
		Set @Sql =Rtrim(@Sql) + ' And tb_Stock.PDate <= ''' + @CDate + '''  Group By tb_Stock.LocaCode,tb_Stock.ItemCode'
	End
	Else
	Begin
		Set @Sql ='Insert Into ' + Rtrim(@ObjectStk)  + ' ([ItemCode],[LocaCode],[Stock]) Select tb_Stock.ItemCode,tb_Stock.LocaCode,Sum(Case [Id] When ''OPB'' Then (PackSize*Qty)'
		Set @Sql =Rtrim(@Sql) + ' When ''PCH'' Then (PackSize*Qty) When ''PRN'' Then -(PackSize*Qty) When ''INV'' Then -(PackSize*Qty) When ''MKR'' Then (PackSize*Qty)'
		Set @Sql =Rtrim(@Sql) + ' When ''DMG'' Then -(PackSize*Qty) When ''PRD'' Then -(PackSize*Qty) When ''DSC'' Then -(PackSize*Qty) When ''ADD'' Then (PackSize*Qty)' 
		Set @Sql =Rtrim(@Sql) + ' When ''TOG'' Then -(PackSize*Qty) When ''AOD'' Then -(PackSize*Qty) When ''IN1'' Then (PackSize*Qty) When ''IN2'' Then (PackSize*Qty) Else 0 End) From tb_Stock'
		Set @Sql =Rtrim(@Sql) + ' Where tb_Stock.LocaCode=''' + @LocaCode + ''' And tb_Stock.Status=1 And tb_Stock.ItemCode In (Select Item_Code From tb_Item Where tb_Item.Cat_Code  In (Select Code From tb_TempSelect Where UserName='''+ @UserName + ''' And [Id]=''CVL''  And LocaCode=''' + @LocaCode + '''))'
		Set @Sql =Rtrim(@Sql) + ' And tb_Stock.PDate <= ''' + @CDate + '''  Group By tb_Stock.LocaCode,tb_Stock.ItemCode'
	End
End
Else If (@Id=2) --SubCategory
Begin
	If (@Type=1)
	Begin
		Set @Sql ='Insert Into ' + Rtrim(@ObjectStk)  + ' ([ItemCode],[LocaCode],[Stock]) Select tb_Stock.ItemCode,tb_Stock.LocaCode,Sum(Case [Id] When ''OPB'' Then (PackSize*Qty)'
		Set @Sql =Rtrim(@Sql) + ' When ''PCH'' Then (PackSize*Qty) When ''PRN'' Then -(PackSize*Qty) When ''INV'' Then -(PackSize*Qty) When ''MKR'' Then (PackSize*Qty)'
		Set @Sql =Rtrim(@Sql) + ' When ''DMG'' Then -(PackSize*Qty) When ''PRD'' Then -(PackSize*Qty) When ''DSC'' Then -(PackSize*Qty) When ''ADD'' Then (PackSize*Qty)' 
		Set @Sql =Rtrim(@Sql) + ' When ''TOG'' Then -(PackSize*Qty) When ''AOD'' Then -(PackSize*Qty) When ''IN1'' Then (PackSize*Qty) When ''IN2'' Then (PackSize*Qty) Else 0 End) From tb_Stock'
		Set @Sql =Rtrim(@Sql) + ' Where tb_Stock.LocaCode=''' + @LocaCode + ''' And tb_Stock.Status=1 And tb_Stock.ItemCode In (Select Item_Code From tb_Item Where tb_Item.SubCat_Code Between ''' + @ItemFrom + ''' And  ''' + @ItemTo + ''')'
		Set @Sql =Rtrim(@Sql) + ' And tb_Stock.PDate <= ''' + @CDate + '''  Group By tb_Stock.LocaCode,tb_Stock.ItemCode'
	End
	Else
	Begin
		Set @Sql ='Insert Into ' + Rtrim(@ObjectStk)  + ' ([ItemCode],[LocaCode],[Stock]) Select tb_Stock.ItemCode,tb_Stock.LocaCode,Sum(Case [Id] When ''OPB'' Then (PackSize*Qty)'
		Set @Sql =Rtrim(@Sql) + ' When ''PCH'' Then (PackSize*Qty) When ''PRN'' Then -(PackSize*Qty) When ''INV'' Then -(PackSize*Qty) When ''MKR'' Then (PackSize*Qty)'
		Set @Sql =Rtrim(@Sql) + ' When ''DMG'' Then -(PackSize*Qty) When ''PRD'' Then -(PackSize*Qty) When ''DSC'' Then -(PackSize*Qty) When ''ADD'' Then (PackSize*Qty)' 
		Set @Sql =Rtrim(@Sql) + ' When ''TOG'' Then -(PackSize*Qty) When ''AOD'' Then -(PackSize*Qty) When ''IN1'' Then (PackSize*Qty) When ''IN2'' Then (PackSize*Qty) Else 0 End) From tb_Stock'
		Set @Sql =Rtrim(@Sql) + ' Where tb_Stock.LocaCode=''' + @LocaCode + ''' And tb_Stock.Status=1 And tb_Stock.ItemCode In (Select Item_Code From tb_Item Where tb_Item.SubCat_Code  In (Select Code From tb_TempSelect Where UserName='''+ @UserName + ''' And [Id]=''SVL''  And LocaCode=''' + @LocaCode + '''))'
		Set @Sql =Rtrim(@Sql) + ' And tb_Stock.PDate <= ''' + @CDate + '''  Group By tb_Stock.LocaCode,tb_Stock.ItemCode'
	End
End
Else If (@Id=3) --Supplier
Begin
	If (@Type=1)
	Begin
		Set @Sql ='Insert Into ' + Rtrim(@ObjectStk)  + ' ([ItemCode],[LocaCode],[Stock]) Select tb_Stock.ItemCode,tb_Stock.LocaCode,Sum(Case [Id] When ''OPB'' Then (PackSize*Qty)'
		Set @Sql =Rtrim(@Sql) + ' When ''PCH'' Then (PackSize*Qty) When ''PRN'' Then -(PackSize*Qty) When ''INV'' Then -(PackSize*Qty) When ''MKR'' Then (PackSize*Qty)'
		Set @Sql =Rtrim(@Sql) + ' When ''DMG'' Then -(PackSize*Qty) When ''PRD'' Then -(PackSize*Qty) When ''DSC'' Then -(PackSize*Qty) When ''ADD'' Then (PackSize*Qty)' 
		Set @Sql =Rtrim(@Sql) + ' When ''TOG'' Then -(PackSize*Qty) When ''AOD'' Then -(PackSize*Qty) When ''IN1'' Then (PackSize*Qty) When ''IN2'' Then (PackSize*Qty) Else 0 End) From tb_Stock'
		Set @Sql =Rtrim(@Sql) + ' Where tb_Stock.LocaCode=''' + @LocaCode + ''' And tb_Stock.Status=1 And tb_Stock.ItemCode In (Select Item_Code From tb_Item Where tb_Item.Supp_Code Between ''' + @ItemFrom + ''' And  ''' + @ItemTo + ''')'
		Set @Sql =Rtrim(@Sql) + ' And tb_Stock.PDate <= ''' + @CDate + '''  Group By tb_Stock.LocaCode,tb_Stock.ItemCode'
	End
	Else
	Begin
		Set @Sql ='Insert Into ' + Rtrim(@ObjectStk)  + ' ([ItemCode],[LocaCode],[Stock]) Select tb_Stock.ItemCode,tb_Stock.LocaCode,Sum(Case [Id] When ''OPB'' Then (PackSize*Qty)'
		Set @Sql =Rtrim(@Sql) + ' When ''PCH'' Then (PackSize*Qty) When ''PRN'' Then -(PackSize*Qty) When ''INV'' Then -(PackSize*Qty) When ''MKR'' Then (PackSize*Qty)'
		Set @Sql =Rtrim(@Sql) + ' When ''DMG'' Then -(PackSize*Qty) When ''PRD'' Then -(PackSize*Qty) When ''DSC'' Then -(PackSize*Qty) When ''ADD'' Then (PackSize*Qty)' 
		Set @Sql =Rtrim(@Sql) + ' When ''TOG'' Then -(PackSize*Qty) When ''AOD'' Then -(PackSize*Qty) When ''IN1'' Then (PackSize*Qty) When ''IN2'' Then (PackSize*Qty) Else 0 End) From tb_Stock'
		Set @Sql =Rtrim(@Sql) + ' Where tb_Stock.LocaCode=''' + @LocaCode + ''' And tb_Stock.Status=1 And tb_Stock.ItemCode In (Select Item_Code From tb_Item Where tb_Item.Supp_Code In (Select Code From tb_TempSelect Where UserName='''+ @UserName + ''' And [Id]=''PVL''  And LocaCode=''' + @LocaCode + '''))'
		Set @Sql =Rtrim(@Sql) + ' And tb_Stock.PDate <= ''' + @CDate + '''  Group By tb_Stock.LocaCode,tb_Stock.ItemCode'
	End
End
Else If (@Id=4) --Item
Begin
	If (@Type=1)
	Begin
		Set @Sql ='Insert Into ' + Rtrim(@ObjectStk)  + ' ([ItemCode],[LocaCode],[Stock]) Select tb_Stock.ItemCode,tb_Stock.LocaCode,Sum(Case [Id] When ''OPB'' Then (PackSize*Qty)'
		Set @Sql =Rtrim(@Sql) + ' When ''PCH'' Then (PackSize*Qty) When ''PRN'' Then -(PackSize*Qty) When ''INV'' Then -(PackSize*Qty) When ''MKR'' Then (PackSize*Qty)'
		Set @Sql =Rtrim(@Sql) + ' When ''DMG'' Then -(PackSize*Qty) When ''PRD'' Then -(PackSize*Qty) When ''DSC'' Then -(PackSize*Qty) When ''ADD'' Then (PackSize*Qty)' 
		Set @Sql =Rtrim(@Sql) + ' When ''TOG'' Then -(PackSize*Qty) When ''AOD'' Then -(PackSize*Qty) When ''IN1'' Then (PackSize*Qty) When ''IN2'' Then (PackSize*Qty) Else 0 End) From tb_Stock'
		Set @Sql =Rtrim(@Sql) + ' Where tb_Stock.LocaCode=''' + @LocaCode + ''' And tb_Stock.Status=1 And tb_Stock.ItemCode Between ''' + @ItemFrom + ''' And  ''' + @ItemTo + ''''
		Set @Sql =Rtrim(@Sql) + ' And tb_Stock.PDate <= ''' + @CDate + '''  Group By tb_Stock.LocaCode,tb_Stock.ItemCode'
	End
	Else
	Begin
		Set @Sql ='Insert Into ' + Rtrim(@ObjectStk)  + ' ([ItemCode],[LocaCode],[Stock]) Select tb_Stock.ItemCode,tb_Stock.LocaCode,Sum(Case [Id] When ''OPB'' Then (PackSize*Qty)'
		Set @Sql =Rtrim(@Sql) + ' When ''PCH'' Then (PackSize*Qty) When ''PRN'' Then -(PackSize*Qty) When ''INV'' Then -(PackSize*Qty) When ''MKR'' Then (PackSize*Qty)'
		Set @Sql =Rtrim(@Sql) + ' When ''DMG'' Then -(PackSize*Qty) When ''PRD'' Then -(PackSize*Qty) When ''DSC'' Then -(PackSize*Qty) When ''ADD'' Then (PackSize*Qty)' 
		Set @Sql =Rtrim(@Sql) + ' When ''TOG'' Then -(PackSize*Qty) When ''AOD'' Then -(PackSize*Qty) When ''IN1'' Then (PackSize*Qty) When ''IN2'' Then (PackSize*Qty) Else 0 End) From tb_Stock'
		Set @Sql =Rtrim(@Sql) + ' Where tb_Stock.LocaCode=''' + @LocaCode + ''' And tb_Stock.Status=1 And tb_Stock.ItemCode  In (Select Code From tb_TempSelect Where UserName='''+ @UserName + ''' And [Id]=''IVL''  And LocaCode=''' + @LocaCode + ''')'
		Set @Sql =Rtrim(@Sql) + ' And tb_Stock.PDate <= ''' + @CDate + '''  Group By tb_Stock.LocaCode,tb_Stock.ItemCode'
	End
End

Exec (@Sql)


--Remove Zeero/Minus Stock
if (@IgnoreMinus=1) 
Begin
	Set @Sql= 'Delete From ' + Rtrim(@ObjectStk) + ' Where Stock<=0'
	Exec (@Sql)
End

--Clear Useless Records
Set @Sql= 'Delete From ' + Rtrim(@Object) + ' Where ItemCode Not In (Select ItemCode From ' + @ObjectStk + ')'
Exec (@Sql)

--Reset Stock For Value
Set @Sql ='Update p Set p.Stock=s.Stock From ' + @Object + ' As p Join ' + @ObjectStk + ' As s On p.ItemCode=s.ItemCode And p.LocaCode=s.LocaCode'
Exec (@Sql)
Set @Sql ='Truncate Table ' + Rtrim(@ObjectStk) 
Exec (@Sql)
Set @Sql ='Drop Table ' + Rtrim(@ObjectStk) 
Exec (@Sql)

--Insert Common Object
If Not Exists (Select Top 1 ItemCode From [tb_Value|X] Where UserId<>@UserName) 
Begin
	Truncate Table [tb_Value|X]
End
Else
Begin
	Delete From [tb_Value|X] Where UserId=@UserName
End

Set @Sql='Insert Into [tb_Value|X] ([LocaCode],[ItemCode],[Stock],[CostPrice],[NewCostPrice],[NewERetPrice],[NewPRetPrice],[NewEWholePrice],[UserId])'
Set @Sql =Rtrim(@Sql) + ' Select [LocaCode],[ItemCode],[Stock],[CostPrice],[NewCostPrice],[NewEWholePrice],[NewPRetPrice],[NewERetPrice],''' + @UserName + ''' From ' + Rtrim(@Object)  
Exec (@Sql)

Set @Sql ='Truncate Table ' + Rtrim(@Object) 
Exec (@Sql)
Set @Sql ='Drop Table ' + Rtrim(@Object) 
Exec (@Sql)
