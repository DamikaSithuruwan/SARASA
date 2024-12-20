USE [Spos_Data]
GO
/****** Object:  StoredProcedure [dbo].[spTaxUpdate]    Script Date: 04/05/2023 11:31:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[spTaxUpdate]
@p_Loca 	CHAR(5),
@p_UnitNo 	Char(3),
@p_Receipt 	CHAR(10),
@p_BillType 	CHAR(1),
@p_Cashier 	CHAR(15),
@p_Floca 	CHAR(5),
@p_Table  	VARCHAR(10),
@p_OrderNo 	VARCHAR(15),
@p_Sman 	CHAR(10),
@p_Cust 	CHAR(15),
@p_Type		INT --0 Tax & Scharge / 1 Scharge / 2 Tax /3 --
				--4 Tax & Scharge remove/ 5 Service Charge Reomve / 6 Tax Remove /7 Suspend Tax
AS
Declare @l_RowNo INT
Declare @l_SaleTotal Decimal(18,4)
Declare @l_VatP Decimal(12,2)
Declare @l_TdlP Decimal(12,2)
Declare @l_SCharge Decimal(18,4)
Declare @l_Nbt Decimal(18,4)
Declare @l_Vat Decimal(18,4)
Declare @l_Tdl Decimal(18,4)

Declare @l_Error INT
Set @l_RowNo=0
Set @l_SaleTotal=0
Set @l_VatP=0
Set @l_TdlP=0
Set @l_SCharge=0
Set @l_Nbt=0
Set @l_Vat=0
Set @l_Tdl=0
set @p_Floca='--'

Set @l_Error=0
BEGIN TRAN
Declare @TaxCalcMethod int 
Set @TaxCalcMethod=0   --0 For Calcutate Sales Value Only / 1 For calcutate Accumilated Value (with scharge and other) 
--Delete xisting Updates
If (@p_Type=0 Or @p_Type=1 Or @p_Type=4 Or @p_Type=5 Or @p_Type=6) Delete FROM tbXItem Where Loca=@p_Loca And Receipt=@p_Receipt And UnitNo=@p_UnitNo And Iid In ('011','012')
If (@p_Type=2) Delete FROM tbXItem Where Loca=@p_Loca And Receipt=@p_Receipt And UnitNo=@p_UnitNo And Iid In ('012')
If (@p_Type=7) Update tbXItem Set TaxStat='X' Where Loca=@p_Loca And Receipt=@p_Receipt And UnitNo=@p_UnitNo And Iid In ('012') And Rtrim(ItemCode)='VAT' And Rtrim(Descrip) Like 'VAT%'
If @@Error <> 0  Set @l_Error=@@Error

--Service Charge Availability
If Exists(Select * from tbFuncLocation Where Loca=@p_Loca And FLoca=@p_Floca And SChargeAvailable=1 And IsNull(SCharge,0)>0 And (@p_Type=1))
Begin
	Select @l_RowNo=ISNULL(MAX(RowNo)+1,1) FROM tbXItem Where Loca=@p_Loca And Receipt=@p_Receipt And UnitNo=@p_UnitNo 
	If @@Error <> 0  Set @l_Error=@@Error
	Select @l_SaleTotal=ISNULL(Sum(Case Iid When '001' Then Nett When '002' Then -Nett When '003' Then Nett When '004' Then -Nett When '006' Then -Nett Else 0 End),0) FROM tbXItem Where Loca=@p_Loca And Receipt=@p_Receipt And UnitNo=@p_UnitNo And SaleType='S' 
	If @@Error <> 0  Set @l_Error=@@Error
	Select @l_VatP=IsNull(SCharge,0) from tbFuncLocation Where Loca=@p_Loca And FLoca=@p_Floca 
	If @@Error <> 0  Set @l_Error=@@Error
	Set @l_SCharge=@l_SaleTotal*@l_VatP/100
	If (@l_SCharge<>0)
	Begin
		INSERT INTO tbXItem(
	  		ItemCode,  RefCode,  Descrip,  Cost,  Price,  Qty,  Amount,  IDI1,  IDis1,
	  		IDiscount1,  IDI2,  IDis2,  IDiscount2,  IDI3,  IDis3,  IDiscount3,  IDI4,
	  		IDis4,  IDiscount4,  IDI5,  IDis5,  IDiscount5,  Rate,  SDStat,  SDNo,
	  		SDID,  SDIs,  SDiscount,  Tax,  Nett,  Loca,  IId,  Receipt,  Salesman,
	  		Cust,  Cashier,  StartTime,EndTime,  RecDate,  BillType,  Unit,  UnitNo,
			RowNo,RecallStat,SaleType,RecallNo,PriceLevel,Pcs,PackSize,ExpDate,ItemType,ConFact,PackScale,
			FLoca,TableNo,TerminalNo,OrderNo,OrderBy,TaxPcnt,TaxAmount,TaxStat)
		VALUES ('SCG','','BANK TAX ' + Convert(Varchar(6),@l_VatP) + '%',0,@l_SaleTotal,1,@l_SaleTotal,0,'',0
			,0,'',0,0,'',0,0,'',0,0,'',0,@l_VatP,'F',0,0,'',0,@l_SCharge,@l_SCharge,@p_Loca
			,'011',@p_Receipt,@p_Sman ,@p_Cust,@p_Cashier,GetDate(),GetDate(),GetDate(),@p_BillType,'NOS',@p_UnitNo
			,@l_RowNo,'F','S','',0,0,1,'',0,1,1
			,@p_Floca,@p_Table,@p_UnitNo,@p_OrderNo,@p_Sman,@l_VatP,@l_SCharge,'T')
		If @@Error <> 0  Set @l_Error=@@Error 
	End
End

--TDL Charge Availability
If Exists(Select * from tbFuncLocation Where Loca=@p_Loca And FLoca=@p_Floca And TaxAvailable=1 And IsNull(Tdl,0)>0 And (@p_Type=0 Or @p_Type=2 Or @p_Type=5))
Begin
	Select @l_RowNo=ISNULL(MAX(RowNo)+1,1) FROM tbXItem Where Loca=@p_Loca And Receipt=@p_Receipt And UnitNo=@p_UnitNo 
	If @@Error <> 0  Set @l_Error=@@Error
	Select @l_SaleTotal=ISNULL(Sum(Case Iid When '001' Then Nett When '002' Then -Nett When '003' Then Nett When '004' Then -Nett When '006' Then -Nett Else 0 End),0) FROM tbXItem x 
	left join (select ItemCode,isTax from tbItem group by ItemCode,isTax) i on x.ItemCode=i.ItemCode Where Loca=@p_Loca And Receipt=@p_Receipt And UnitNo=@p_UnitNo And SaleType='S' And isnull(isTax,0)=1
	If @@Error <> 0  Set @l_Error=@@Error	
	Select @l_TdlP=IsNull(Tdl,0) from tbFuncLocation Where Loca=@p_Loca And FLoca=@p_Floca 
	If @@Error <> 0  Set @l_Error=@@Error
	Set @l_Tdl=@l_SaleTotal*@l_TdlP/100
	If (@l_Tdl<>0)
	Begin
		INSERT INTO tbXItem(
	  		ItemCode,  RefCode,  Descrip,  Cost,  Price,  Qty,  Amount,  IDI1,  IDis1,
	  		IDiscount1,  IDI2,  IDis2,  IDiscount2,  IDI3,  IDis3,  IDiscount3,  IDI4,
	  		IDis4,  IDiscount4,  IDI5,  IDis5,  IDiscount5,  Rate,  SDStat,  SDNo,
	  		SDID,  SDIs,  SDiscount,  Tax,  Nett,  Loca,  IId,  Receipt,  Salesman,
	  		Cust,  Cashier,  StartTime,EndTime,  RecDate,  BillType,  Unit,  UnitNo,
			RowNo,RecallStat,SaleType,RecallNo,PriceLevel,Pcs,PackSize,ExpDate,ItemType,ConFact,PackScale,
			FLoca,TableNo,TerminalNo,OrderNo,OrderBy,TaxPcnt,TaxAmount,TaxStat)
		VALUES ('TDL','','TDL ' + Convert(Varchar(6),@l_TdlP) + '%',0,@l_SaleTotal,1,@l_SaleTotal,0,'',0
			,0,'',0,0,'',0,0,'',0,0,'',0,@l_TdlP,'F',0,0,'',0,@l_Tdl,@l_Tdl,@p_Loca
			,'012',@p_Receipt,@p_Sman ,@p_Cust,@p_Cashier,GetDate(),GetDate(),GetDate(),@p_BillType,'NOS',@p_UnitNo
			,@l_RowNo,'F','S','',0,0,1,'',0,1,1
			,@p_Floca,@p_Table,@p_UnitNo,@p_OrderNo,@p_Sman,@l_TdlP,@l_Tdl,'T')
		If @@Error <> 0  Set @l_Error=@@Error 
	End
End

--NBT Charge Availability
If Exists(Select * from tbFuncLocation Where Loca=@p_Loca And FLoca=@p_Floca And TaxAvailable=1 And IsNull(Tax,0)>0 And (@p_Type=0 Or @p_Type=2 Or @p_Type=5))
Begin
	Select @l_RowNo=ISNULL(MAX(RowNo)+1,1) FROM tbXItem Where Loca=@p_Loca And Receipt=@p_Receipt And UnitNo=@p_UnitNo 
	If @@Error <> 0  Set @l_Error=@@Error
	Select @l_SaleTotal=ISNULL(Sum(Case Iid When '001' Then Nett When '002' Then -Nett When '003' Then Nett When '004' Then -Nett When '006' Then -Nett Else 0 End),0) FROM tbXItem x 
	left join (select ItemCode,isNbt from tbItem group by ItemCode,isNbt) i on x.ItemCode=i.ItemCode Where Loca=@p_Loca And Receipt=@p_Receipt And UnitNo=@p_UnitNo And SaleType='S' and isnull(isNbt,0)=1
	If @@Error <> 0  Set @l_Error=@@Error
	if (@TaxCalcMethod=1) Set @l_SaleTotal=@l_SaleTotal+@l_SCharge
	Select @l_VatP=IsNull(Tax,0) from tbFuncLocation Where Loca=@p_Loca And FLoca=@p_Floca 
	If @@Error <> 0  Set @l_Error=@@Error
	Set @l_Nbt=@l_SaleTotal*@l_VatP/100
	If (@l_Nbt<>0)
	Begin
		INSERT INTO tbXItem(
	  		ItemCode,  RefCode,  Descrip,  Cost,  Price,  Qty,  Amount,  IDI1,  IDis1,
	  		IDiscount1,  IDI2,  IDis2,  IDiscount2,  IDI3,  IDis3,  IDiscount3,  IDI4,
	  		IDis4,  IDiscount4,  IDI5,  IDis5,  IDiscount5,  Rate,  SDStat,  SDNo,
	  		SDID,  SDIs,  SDiscount,  Tax,  Nett,  Loca,  IId,  Receipt,  Salesman,
	  		Cust,  Cashier,  StartTime,EndTime,  RecDate,  BillType,  Unit,  UnitNo,
			RowNo,RecallStat,SaleType,RecallNo,PriceLevel,Pcs,PackSize,ExpDate,ItemType,ConFact,PackScale,
			FLoca,TableNo,TerminalNo,OrderNo,OrderBy,TaxPcnt,TaxAmount,TaxStat)
		VALUES ('NBT','','NBT ' + Convert(Varchar(6),@l_VatP) + '%',0,@l_SaleTotal,1,@l_SaleTotal,0,'',0
			,0,'',0,0,'',0,0,'',0,0,'',0,@l_VatP,'F',0,0,'',0,@l_Nbt,@l_Nbt,@p_Loca
			,'012',@p_Receipt,@p_Sman ,@p_Cust,@p_Cashier,GetDate(),GetDate(),GetDate(),@p_BillType,'NOS',@p_UnitNo
			,@l_RowNo,'F','S','',0,0,1,'',0,1,1
			,@p_Floca,@p_Table,@p_UnitNo,@p_OrderNo,@p_Sman,@l_VatP,@l_Nbt,'T')
		If @@Error <> 0  Set @l_Error=@@Error 
	End
End

--VAT Charge Availability
If Exists(Select * from tbFuncLocation Where Loca=@p_Loca And FLoca=@p_Floca And TaxAvailable=1 And IsNull(Tax2,0)>0 And (@p_Type=0 Or @p_Type=2 Or @p_Type=5))
Begin
	Select @l_RowNo=ISNULL(MAX(RowNo)+1,1) FROM tbXItem Where Loca=@p_Loca And Receipt=@p_Receipt And UnitNo=@p_UnitNo 
	If @@Error <> 0  Set @l_Error=@@Error
	Select @l_SaleTotal=ISNULL(Sum(Case Iid When '001' Then Nett When '002' Then -Nett When '003' Then Nett When '004' Then -Nett When '006' Then -Nett Else 0 End),0) FROM tbXItem Where Loca=@p_Loca And Receipt=@p_Receipt And UnitNo=@p_UnitNo And SaleType='S' 
	If @@Error <> 0  Set @l_Error=@@Error
	if (@TaxCalcMethod=1) Set @l_SaleTotal=@l_SaleTotal+@l_SCharge+@l_Nbt
	Select @l_VatP=IsNull(Tax2,0) from tbFuncLocation Where Loca=@p_Loca And FLoca=@p_Floca 
	If @@Error <> 0  Set @l_Error=@@Error
	Set @l_Vat=@l_SaleTotal*@l_VatP/100
	If (@l_Vat<>0)
	Begin
		INSERT INTO tbXItem(
	  		ItemCode,  RefCode,  Descrip,  Cost,  Price,  Qty,  Amount,  IDI1,  IDis1,
	  		IDiscount1,  IDI2,  IDis2,  IDiscount2,  IDI3,  IDis3,  IDiscount3,  IDI4,
	  		IDis4,  IDiscount4,  IDI5,  IDis5,  IDiscount5,  Rate,  SDStat,  SDNo,
	  		SDID,  SDIs,  SDiscount,  Tax,  Nett,  Loca,  IId,  Receipt,  Salesman,
	  		Cust,  Cashier,  StartTime,EndTime,  RecDate,  BillType,  Unit,  UnitNo,
			RowNo,RecallStat,SaleType,RecallNo,PriceLevel,Pcs,PackSize,ExpDate,ItemType,ConFact,PackScale,
			FLoca,TableNo,TerminalNo,OrderNo,OrderBy,TaxPcnt,TaxAmount,TaxStat)
		VALUES ('VAT','','VAT ' + Convert(Varchar(6),@l_VatP) + '%',0,@l_SaleTotal,1,@l_SaleTotal,0,'',0
			,0,'',0,0,'',0,0,'',0,0,'',0,@l_VatP,'F',0,0,'',0,@l_Vat,@l_Vat,@p_Loca
			,'012',@p_Receipt,@p_Sman ,@p_Cust,@p_Cashier,GetDate(),GetDate(),GetDate(),@p_BillType,'NOS',@p_UnitNo
			,@l_RowNo,'F','S','',0,0,1,'',0,1,1
			,@p_Floca,@p_Table,@p_UnitNo,@p_OrderNo,@p_Sman,@l_VatP,@l_Vat,'T')
		If @@Error <> 0  Set @l_Error=@@Error 
	End
End

---=======================================================================================================

/* TAX CALCUTATE FOR RUNNING AMOUNT

--Service Charge Availability
If Exists(Select * from tbFuncLocation Where Loca=@p_Loca And FLoca=@p_Floca And SChargeAvailable=1 And IsNull(SCharge,0)>0 And (@p_Type=0 Or @p_Type=1 Or @p_Type=6))
Begin
	Select @l_RowNo=ISNULL(MAX(RowNo)+1,1) FROM tbXItem Where Loca=@p_Loca And Receipt=@p_Receipt And UnitNo=@p_UnitNo 
	If @@Error <> 0  Set @l_Error=@@Error
	Select @l_SaleTotal=ISNULL(Sum(Case Iid When '001' Then Nett When '002' Then -Nett When '003' Then Nett When '004' Then -Nett When '006' Then -Nett Else 0 End),0) FROM tbXItem Where Loca=@p_Loca And Receipt=@p_Receipt And UnitNo=@p_UnitNo And SaleType='S' 
	If @@Error <> 0  Set @l_Error=@@Error
	Select @l_VatP=IsNull(SCharge,0) from tbFuncLocation Where Loca=@p_Loca And FLoca=@p_Floca 
	If @@Error <> 0  Set @l_Error=@@Error
	Set @l_SCharge=@l_SaleTotal*@l_VatP/100
	If (@l_SCharge<>0)
	Begin
		INSERT INTO tbXItem(
	  		ItemCode,  RefCode,  Descrip,  Cost,  Price,  Qty,  Amount,  IDI1,  IDis1,
	  		IDiscount1,  IDI2,  IDis2,  IDiscount2,  IDI3,  IDis3,  IDiscount3,  IDI4,
	  		IDis4,  IDiscount4,  IDI5,  IDis5,  IDiscount5,  Rate,  SDStat,  SDNo,
	  		SDID,  SDIs,  SDiscount,  Tax,  Nett,  Loca,  IId,  Receipt,  Salesman,
	  		Cust,  Cashier,  StartTime,EndTime,  RecDate,  BillType,  Unit,  UnitNo,
			RowNo,RecallStat,SaleType,RecallNo,PriceLevel,Pcs,PackSize,ExpDate,ItemType,ConFact,PackScale,
			FLoca,TableNo,TerminalNo,OrderNo,OrderBy,TaxPcnt,TaxAmount,TaxStat)
		VALUES ('SCG','','SERVICE CHARGE ' + Convert(Varchar(6),@l_VatP) + '%',0,@l_SaleTotal,1,@l_SaleTotal,0,'',0
			,0,'',0,0,'',0,0,'',0,0,'',0,@l_VatP,'F',0,0,'',0,@l_SCharge,@l_SCharge,@p_Loca
			,'011',@p_Receipt,@p_Sman ,@p_Cust,@p_Cashier,GetDate(),GetDate(),GetDate(),@p_BillType,'NOS',@p_UnitNo
			,@l_RowNo,'F','S','',0,0,1,'',0,1,1
			,@p_Floca,@p_Table,@p_UnitNo,@p_OrderNo,@p_Sman,@l_VatP,@l_SCharge,'T')
		If @@Error <> 0  Set @l_Error=@@Error 
	End
End

--TDL Charge Availability
If Exists(Select * from tbFuncLocation Where Loca=@p_Loca And FLoca=@p_Floca And TaxAvailable=1 And IsNull(Tdl,0)>0 And (@p_Type=0 Or @p_Type=2 Or @p_Type=5))
Begin
	Select @l_RowNo=ISNULL(MAX(RowNo)+1,1) FROM tbXItem Where Loca=@p_Loca And Receipt=@p_Receipt And UnitNo=@p_UnitNo 
	If @@Error <> 0  Set @l_Error=@@Error
	Select @l_SaleTotal=ISNULL(Sum(Case Iid When '001' Then Nett When '002' Then -Nett When '003' Then Nett When '004' Then -Nett When '006' Then -Nett Else 0 End),0) FROM tbXItem Where Loca=@p_Loca And Receipt=@p_Receipt And UnitNo=@p_UnitNo And SaleType='S' 
	If @@Error <> 0  Set @l_Error=@@Error	
	Select @l_TdlP=IsNull(Tdl,0) from tbFuncLocation Where Loca=@p_Loca And FLoca=@p_Floca 
	If @@Error <> 0  Set @l_Error=@@Error
	Set @l_Tdl=@l_SaleTotal*@l_TdlP/100
	If (@l_Tdl<>0)
	Begin
		INSERT INTO tbXItem(
	  		ItemCode,  RefCode,  Descrip,  Cost,  Price,  Qty,  Amount,  IDI1,  IDis1,
	  		IDiscount1,  IDI2,  IDis2,  IDiscount2,  IDI3,  IDis3,  IDiscount3,  IDI4,
	  		IDis4,  IDiscount4,  IDI5,  IDis5,  IDiscount5,  Rate,  SDStat,  SDNo,
	  		SDID,  SDIs,  SDiscount,  Tax,  Nett,  Loca,  IId,  Receipt,  Salesman,
	  		Cust,  Cashier,  StartTime,EndTime,  RecDate,  BillType,  Unit,  UnitNo,
			RowNo,RecallStat,SaleType,RecallNo,PriceLevel,Pcs,PackSize,ExpDate,ItemType,ConFact,PackScale,
			FLoca,TableNo,TerminalNo,OrderNo,OrderBy,TaxPcnt,TaxAmount,TaxStat)
		VALUES ('TDL','','TDL ' + Convert(Varchar(6),@l_TdlP) + '%',0,@l_SaleTotal,1,@l_SaleTotal,0,'',0
			,0,'',0,0,'',0,0,'',0,0,'',0,@l_TdlP,'F',0,0,'',0,@l_Tdl,@l_Tdl,@p_Loca
			,'012',@p_Receipt,@p_Sman ,@p_Cust,@p_Cashier,GetDate(),GetDate(),GetDate(),@p_BillType,'NOS',@p_UnitNo
			,@l_RowNo,'F','S','',0,0,1,'',0,1,1
			,@p_Floca,@p_Table,@p_UnitNo,@p_OrderNo,@p_Sman,@l_TdlP,@l_Tdl,'T')
		If @@Error <> 0  Set @l_Error=@@Error 
	End
End

--NBT Charge Availability
If Exists(Select * from tbFuncLocation Where Loca=@p_Loca And FLoca=@p_Floca And TaxAvailable=1 And IsNull(Tax,0)>0 And (@p_Type=0 Or @p_Type=2 Or @p_Type=5))
Begin
	Select @l_RowNo=ISNULL(MAX(RowNo)+1,1) FROM tbXItem Where Loca=@p_Loca And Receipt=@p_Receipt And UnitNo=@p_UnitNo 
	If @@Error <> 0  Set @l_Error=@@Error
	Select @l_SaleTotal=ISNULL(Sum(Case Iid When '001' Then Nett When '002' Then -Nett When '003' Then Nett When '004' Then -Nett When '006' Then -Nett Else 0 End),0) FROM tbXItem Where Loca=@p_Loca And Receipt=@p_Receipt And UnitNo=@p_UnitNo And SaleType='S' 
	If @@Error <> 0  Set @l_Error=@@Error
	Set @l_SaleTotal=@l_SaleTotal+@l_SCharge
	Select @l_VatP=IsNull(Tax,0) from tbFuncLocation Where Loca=@p_Loca And FLoca=@p_Floca 
	If @@Error <> 0  Set @l_Error=@@Error
	Set @l_Nbt=@l_SaleTotal*@l_VatP/100
	If (@l_Nbt<>0)
	Begin
		INSERT INTO tbXItem(
	  		ItemCode,  RefCode,  Descrip,  Cost,  Price,  Qty,  Amount,  IDI1,  IDis1,
	  		IDiscount1,  IDI2,  IDis2,  IDiscount2,  IDI3,  IDis3,  IDiscount3,  IDI4,
	  		IDis4,  IDiscount4,  IDI5,  IDis5,  IDiscount5,  Rate,  SDStat,  SDNo,
	  		SDID,  SDIs,  SDiscount,  Tax,  Nett,  Loca,  IId,  Receipt,  Salesman,
	  		Cust,  Cashier,  StartTime,EndTime,  RecDate,  BillType,  Unit,  UnitNo,
			RowNo,RecallStat,SaleType,RecallNo,PriceLevel,Pcs,PackSize,ExpDate,ItemType,ConFact,PackScale,
			FLoca,TableNo,TerminalNo,OrderNo,OrderBy,TaxPcnt,TaxAmount,TaxStat)
		VALUES ('NBT','','NBT ' + Convert(Varchar(6),@l_VatP) + '%',0,@l_SaleTotal,1,@l_SaleTotal,0,'',0
			,0,'',0,0,'',0,0,'',0,0,'',0,@l_VatP,'F',0,0,'',0,@l_Nbt,@l_Nbt,@p_Loca
			,'012',@p_Receipt,@p_Sman ,@p_Cust,@p_Cashier,GetDate(),GetDate(),GetDate(),@p_BillType,'NOS',@p_UnitNo
			,@l_RowNo,'F','S','',0,0,1,'',0,1,1
			,@p_Floca,@p_Table,@p_UnitNo,@p_OrderNo,@p_Sman,@l_VatP,@l_Nbt,'T')
		If @@Error <> 0  Set @l_Error=@@Error 
	End
End

--VAT Charge Availability
If Exists(Select * from tbFuncLocation Where Loca=@p_Loca And FLoca=@p_Floca And TaxAvailable=1 And IsNull(Tax2,0)>0 And (@p_Type=0 Or @p_Type=2 Or @p_Type=5))
Begin
	Select @l_RowNo=ISNULL(MAX(RowNo)+1,1) FROM tbXItem Where Loca=@p_Loca And Receipt=@p_Receipt And UnitNo=@p_UnitNo 
	If @@Error <> 0  Set @l_Error=@@Error
	Select @l_SaleTotal=ISNULL(Sum(Case Iid When '001' Then Nett When '002' Then -Nett When '003' Then Nett When '004' Then -Nett When '006' Then -Nett Else 0 End),0) FROM tbXItem Where Loca=@p_Loca And Receipt=@p_Receipt And UnitNo=@p_UnitNo And SaleType='S' 
	If @@Error <> 0  Set @l_Error=@@Error
	Set @l_SaleTotal=@l_SaleTotal+@l_SCharge+@l_Nbt
	Select @l_VatP=IsNull(Tax2,0) from tbFuncLocation Where Loca=@p_Loca And FLoca=@p_Floca 
	If @@Error <> 0  Set @l_Error=@@Error
	Set @l_Vat=@l_SaleTotal*@l_VatP/100
	If (@l_Vat<>0)
	Begin
		INSERT INTO tbXItem(
	  		ItemCode,  RefCode,  Descrip,  Cost,  Price,  Qty,  Amount,  IDI1,  IDis1,
	  		IDiscount1,  IDI2,  IDis2,  IDiscount2,  IDI3,  IDis3,  IDiscount3,  IDI4,
	  		IDis4,  IDiscount4,  IDI5,  IDis5,  IDiscount5,  Rate,  SDStat,  SDNo,
	  		SDID,  SDIs,  SDiscount,  Tax,  Nett,  Loca,  IId,  Receipt,  Salesman,
	  		Cust,  Cashier,  StartTime,EndTime,  RecDate,  BillType,  Unit,  UnitNo,
			RowNo,RecallStat,SaleType,RecallNo,PriceLevel,Pcs,PackSize,ExpDate,ItemType,ConFact,PackScale,
			FLoca,TableNo,TerminalNo,OrderNo,OrderBy,TaxPcnt,TaxAmount,TaxStat)
		VALUES ('VAT','','VAT ' + Convert(Varchar(6),@l_VatP) + '%',0,@l_SaleTotal,1,@l_SaleTotal,0,'',0
			,0,'',0,0,'',0,0,'',0,0,'',0,@l_VatP,'F',0,0,'',0,@l_Vat,@l_Vat,@p_Loca
			,'012',@p_Receipt,@p_Sman ,@p_Cust,@p_Cashier,GetDate(),GetDate(),GetDate(),@p_BillType,'NOS',@p_UnitNo
			,@l_RowNo,'F','S','',0,0,1,'',0,1,1
			,@p_Floca,@p_Table,@p_UnitNo,@p_OrderNo,@p_Sman,@l_VatP,@l_Vat,'T')
		If @@Error <> 0  Set @l_Error=@@Error 
	End
End
*/
---UPDATE tbXItem Set Tax=(Tax+((Nett+Tax)*(@p_Discount/@p_Amount))) Where Loca=@p_Loca And Receipt=@p_Receipt And UnitNo=@p_UnitNo And BillType=@p_BillType And RecallStat='F' And (Iid='001' or Iid='002' Or Iid='003' Or Iid='004')
--If @@Error <> 0  Set @l_Error=@@Error
--UPDATE tbXItem Set TaxStat=CASE WHEN TaxStat='F' THEN 'T' ELSE '*' END Where Loca=@p_Loca And Receipt=@p_Receipt And UnitNo=@p_UnitNo And BillType=@p_BillType And RecallStat='F'

If @l_Error<> 0 
    ROLLBACK TRAN
Else
  	COMMIT TRAN







