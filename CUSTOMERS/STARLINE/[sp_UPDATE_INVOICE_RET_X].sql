USE [Easyway]
GO
/****** Object:  StoredProcedure [dbo].[sp_UPDATE_INVOICE_RET_X]    Script Date: 2024-08-10 9:45:20 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[sp_UPDATE_INVOICE_RET_X]
@SerialNo 			Varchar(20),
@RefNo				Varchar(30),
@IDate				Datetime , 
@CustCode			Varchar(10),
@CustName			Varchar(50),
@RepCode			Varchar(10),
@RepName			Varchar(50),
@PType				SmallInt, 
@GrossAmount		Money,
@TotDiscount		Money,
@SubTotDiscount		Money,
@Tax				Money,
@NetAmount			Money,
@UserName			Varchar(15),
@LocaCode			Varchar(5),
@Status				Int,
@UnitNo				Varchar(2),
@Mode1				Varchar(20),
@Mode2				Varchar(20),
@Mode3				Varchar(20),
@Mode4				Varchar(20),
@ModeBal			Varchar(20),
@Amt1				Money,
@Amt2				Money,
@Amt3				Money,
@Amt4				Money,
@AmtBal				Money,
@Rem1				Varchar(20),
@Rem2				Varchar(20),
@Rem3				Varchar(20),
@Rem4				Varchar(20),
@Bank1				Varchar(50),
@Bank2				Varchar(50),
@Bank3				Varchar(50),
@Bank4				Varchar(50),
@ChqDat1			Varchar(10),
@ChqDat2			Varchar(10),
@ChqDat3			Varchar(10),
@ChqDat4			Varchar(10),
@Disc				Varchar(10),
@IsSusVat			TinyInt,
@VehicleNo 			Varchar(20),
@DocCharges			Money,
@Remark				Varchar(50),
@DilDate			Datetime,
@Nbt				Money,
@ToDelevery			Int,
@QutNo              Varchar(20)
 AS
Declare @DFR 		As	Char(2)
Declare @NextIdx 	As	Char(13)
Declare @DocNo		As	Char(15)
Declare	@ReceNo		As	Char(15)
Declare @P1			As 	SmallInt
Declare @P2			As 	SmallInt
Declare @P3			As 	SmallInt
Declare @P4			As 	SmallInt
Declare @PB			As 	SmallInt
Declare @PMode		As 	SmallInt
Declare	@Balance	As	Money
Declare @MlSrl		As  Char(1)
Declare @TmpDate	As 	Char(10)
Declare @VatNo		As	Varchar(15)
Declare @VatP as varchar(10)
Declare @InvPrc AS decimal(18,4)

--set some_column = replace(some_column, '.', '')

GetNextId: 
Set @DFR= ''
Set @NextIdx= 0
Set @P1=1
Set @P2=1
Set @P3=1
Set @P4=1
Set @PB=1
Set @PMode=1
Set @Balance=0
set @VatP = (select vatPercentage from tb_Location where Loca_Code=@LocaCode)
 

SET @NetAmount = (@NetAmount - @DocCharges)

-- set item type and sinhala description on temp table
Update tb_TempInv Set tb_TempInv.ItemType =tb_Item.Use_Exp,tb_TempInv.SinhalaDescrip=tb_Item.SinhalaDescrip  
From tb_TempInv Join tb_Item On tb_TempInv.ItemCode=tb_Item.Item_Code
Where tb_TempInv.LocaCode= @LocaCode	And tb_TempInv.SerialNo	= @SerialNo And tb_TempInv.[ID]	= 'INV' And tb_TempInv.UnitNo=@UnitNo
	
--RefQty Upto update through Invoice
Update   tb_TempInv Set tb_TempInv.RefQty=1 From tb_TempInv Where    tb_TempInv.LocaCode	= @LocaCode	And
		 tb_TempInv.SerialNo	= @SerialNo And 	
		 tb_TempInv.[ID]		= 'INV'		And
		 Isnull(tb_TempInv.RefQty,0)=0		And
		 tb_TempInv.UnitNo		=@UnitNo

Update   tb_TempInv Set tb_TempInv.SinhalaDescrip=tb_PriceLevel.Description2 From tb_PriceLevel Join tb_TempInv On tb_TempInv.ItemCode=tb_PriceLevel.ItemCode And tb_TempInv.RefQty=tb_PriceLevel.Qty Where    tb_TempInv.LocaCode	= @LocaCode	And
		 tb_TempInv.SerialNo	= @SerialNo And
		 tb_TempInv.[ID]		= 'INV'		And
		 tb_TempInv.RefQty		<>1			And
		 tb_PriceLevel.[Status] =1			And
		 tb_TempInv.UnitNo		=@UnitNo
		 
--STARLINE (LINK FILE UPDATE)
		Update   tb_TempInv Set tb_TempInv.Rem1 =tb_Item.L1_Code,tb_TempInv.Rem2=tb_Item.L2_Code,tb_TempInv.Rem3=tb_Item.L3_Code From tb_TempInv Join tb_Item  On tb_TempInv.ItemCode=tb_item.Item_Code
		Where    tb_TempInv.LocaCode	= @LocaCode	And
				 tb_TempInv.SerialNo	= @SerialNo And
				 tb_TempInv.[ID]		= 'INV'		And
				 tb_TempInv.UnitNo		=@UnitNo
				 
				 
Select  @VatNo=Isnull(Rtrim(Country),'') From tb_Customer Where Cust_Code=@CustCode
		 
If @Status=1 
	Begin

		--'Costing Type
		/*
		Update   tb_TempInv Set tb_TempInv.Cost2=Cost  Where    tb_TempInv.LocaCode	= @LocaCode	And
					 tb_TempInv.SerialNo	= @SerialNo      And
					 tb_TempInv.[ID]		= 'INV'
		Update   tb_TempInv Set tb_TempInv.Cost=tb_ItemDet.AvgCost From tb_ItemDet Join tb_TempInv On tb_TempInv.ItemCode=tb_itemDet.Item_Code And tb_TempInv.LocaCode=tb_ItemDet.Loca_Code	Where    tb_TempInv.LocaCode	= @LocaCode	And
					 tb_TempInv.SerialNo	= @SerialNo      And
					 tb_TempInv.[ID]		= 'INV'
		*/
		Update   tb_TempInv Set tb_TempInv.Cost2=tb_ItemDet.AvgCost/(PackSize*RefQty) From tb_ItemDet Join tb_TempInv On tb_TempInv.ItemCode=tb_itemDet.Item_Code And tb_TempInv.LocaCode=tb_ItemDet.Loca_Code	Where    tb_TempInv.LocaCode	= @LocaCode	And
					 tb_TempInv.SerialNo	= @SerialNo      And
					 tb_TempInv.[ID]		= 'INV'			 And
					 tb_TempInv.UnitNo		=@UnitNo
		
	

		Select @DFR = Ref_Code,@MlSrl=Isnull(MlSrl,'0') FROM tb_Location WHERE Loca_Code = @LocaCode
		
		UPDATE tb_System SET INV=INV+1 WHERE LocaCode=@LocaCode
			
		Select @NextIdx = Cast(INV As Char(6)) FROM tb_System WHERE LocaCode = @LocaCode

		Set @NextIdx = Replicate('0',6-Len(Rtrim(@NextIdx))) + Rtrim(@NextIdx)
	
		IF (@DFR Is Null)
			Begin
			Set  @DocNo= 'C'+ Rtrim(@NextIdx)	
			End 
		ELSE
			Begin
			Set  @DocNo= 'C'+ @DFR +  Rtrim(@NextIdx)	
			End
		
		IF Exists(Select SerialNo From tb_InvSumm Where SerialNo=@DocNo And LocaCode=@LocaCode  And [Id]='INV' And IType='1') Goto GetNextId
	End 
Else
	Begin
		Set @DocNo=@SerialNo
	End
	
--To Define Cash/Credit
If Rtrim(@Mode1)<> '' Set @P1=Convert(int,Rtrim(left(@Mode1,2)))
If Rtrim(@Mode2)<> '' Set @P2=Convert(int,Rtrim(left(@Mode2,2)))
If Rtrim(@Mode3)<> '' Set @P3=Convert(int,Rtrim(left(@Mode3,2)))
If Rtrim(@Mode4)<> '' Set @P4=Convert(int,Rtrim(left(@Mode4,2)))
If Rtrim(@ModeBal)<> '' Set @PB=Convert(int,Rtrim(left(@ModeBal,2)))

--Reset Total Discount
If @GrossAmount<0  Set @SubTotDiscount=@SubTotDiscount*-1

If  (@P1=2 Or @P2=2 Or @P3=2 Or @P4=2 )  Or  (@NetAmount<0  And  @P1=18)  Set @PMode=2 Else Set @PMode=1 --If Credit Or Credit Note Then Mode To Credit

--To Set Balance
Set @Balance=0
If  ((@NetAmount+@DocCharges)<0  And (@P1=18) )
	Set @Balance=@NetAmount+@DocCharges
Else
Begin
	If @P1=2  Set @Balance=@Balance+@Amt1
	If @P2=2  Set @Balance=@Balance+@Amt2
	If @P3=2  Set @Balance=@Balance+@Amt3
	If @P4=2  Set @Balance=@Balance+@Amt4
End

Insert Into tb_InvSumm	 
			([SerialNo]	,[LocaCode]		,[RefNo]			,[IDate]	,[CustCode]	,[CustName]	,[QutNo]	,[TourCode]	,[PType]	,[IType]	
			,[PMode]	,[GAmount]		,[SubTotDiscount]	,[Tax]		,[NetAmount],[Advance]	,[PModeAdv]	,[Balance]	,[UnitNo]
			,[Id]		,[Status]		,[TrDate]			,[UserName]	,[Discount]	,[Returns] 	,[RepCode]	,[RepName]	,[TotOuts]	
			,[TotPdChq]	,[TotRtChq]		,[Disc]				,[Pay1]					,[Pay2]					,[Pay3]					,[Pay4]		
			,[Rem1]		,[Rem2]			,[Rem3]				,[Rem4]		,[Amt1]		,[Amt2]		,[Amt3]		,[Amt4]		
			,[BalPay]					,[BalAmt]			,[VatNo]	,[IsSusVat]	,[VehicleNumber],[WarrantyReferenceNo],[DilDate],[vatp],[InvoiceRemark]
			,[ChqDate1],[ChqDate2]		,[ChqDate3]			,[ChqDate4]	,[ChqBank1]	,[ChqBank2]	,[ChqBank3]	,[ChqBank4]	,[Vat],[Nbt]	,[ToDelivery])
Values 		(@DocNo		,@LocaCode		,@RefNo 			,@IDate 	,@CustCode 	,@CustName 	,@QutNo 		,''			,@PType		,2
			,@PMode 	,@GrossAmount	,@SubTotDiscount	,(@Tax+@Nbt) 		,@NetAmount ,0 			,0			,@NetAmount	,@UnitNo
			,'INV' 		,@Status 		, GetDate() 		,@UserName	,@TotDiscount,@DocCharges,@RepCode	,@RepName	,0		
			,0			,0				,@Disc				,Rtrim(@Mode1)			,Rtrim(@Mode2)			,Rtrim(@Mode3)			,Rtrim(@Mode4)
			,@Rem1		,@Rem2			,@Rem3				,@Rem4		,CASE When Rtrim(@Mode1)='1 . Cash' THEN (@Amt1+@AmtBal) ELSE @Amt1 END,CASE When Rtrim(@Mode2)='1 . Cash' THEN (@Amt2+@AmtBal) ELSE @Amt2 END,CASE When Rtrim(@Mode3)='1 . Cash' THEN (@Amt3+@AmtBal) ELSE @Amt3 END,CASE When Rtrim(@Mode4)='1 . Cash' THEN (@Amt4+@AmtBal) ELSE @Amt4 END
			,Rtrim(@ModeBal)			,@AmtBal			,@VatNo		,@IsSusVat,@VehicleNo,@DocNo,@DilDate,@VatP,@Remark
			,@ChqDat1	,@ChqDat2		,@ChqDat3			,@ChqDat4	,@Bank1		,@Bank2		,@Bank3		,@Bank4		,@Tax, @Nbt		,@ToDelevery)

Insert Into tb_InvDet	
			([SerialNo]	,[LocaCode]	,[InvLocaCode]  ,[RefNo]		,[CustCode]		,[ItemCode]	,[ItemDescrip]	,[Scale]		,[Unit]			
			,[Cost]		,[Rate]		,[Qty]			,[GAmount]		,[Discp]		,[Discount]		,[Tax]		,[NetAmount]	,[TrDate]	
			,[ID]		,[Status]	,[LnNo] 		,[PackSize]		,[IDate]		,[DiscountForTot]	
			,[AodDate]	,[RepCode]	,[ConFact]		,[ConFactUnit]	,[Rem1]			,[Rem2]			,[Rem3]		,[Rem4]			,[BatchNo]
			,[Cost2]	,[Warrenty]	,[CsCode]		,[CSName]								
			,[IsSusVat]	,[RefSize]	,[RefQty]		,[SinhalaDescrip],[UsdRate]		,[ItemSerialNo]				
			,[BarcodeSerial]		,[IType]		,[UnitNo]		,[ItemRemark]	,[VatP],[Vat],[Nbt])
			
Select 		@DocNo		,@LocaCode	,Isnull(InvLocaCode,@LocaCode)	,@RefNo			,@CustCode   	,ItemCode   ,ItemDescript 	,Scale			,Unit		
			,Cost		,Rate		,Qty*RefQty     ,Amount+Discount,DiscP      	,Discount 	,(Tax+Nbt)	        ,Amount			,GetDate()	
			,Id			,@Status 	,IdNo			,PackSize		,@IDate			,
			Case When abs(@SubTotDiscount)>0 and abs(@GrossAmount)>0 and abs(Amount)>0 then (Convert(Float,@SubTotDiscount)/Convert(Float,@GrossAmount))*Convert(Float,Amount) Else 0	End
			,AodDate	,@RepCode	,Isnull(ConFact,1),Isnull(ConFactUnit,'NOS')	,[Rem1]			,[Rem2]		,[Rem3]			,''				,Rtrim(Isnull(ItemSerialNo,''))
			,Cost2		,Warrenty	,Case When ITemType=3 Then ItemSerialNo Else '' End	,Case When ITemType=3 Then CSName Else '' End	
			,@IsSusVat	,RefQty		,Qty			,SinhalaDescrip	,1				,Case When ItemType=2 Then Case Rtrim(Isnull(ItemSerialNo,'')) When '' Then Null Else ItemSerialNo End Else Null End
			,BarcodeSerial			,2				,@UnitNo ,ItemRemark		,@VatP,Tax,Nbt
			
From  tb_TempInv	Where   LocaCode	= @LocaCode	And
				SerialNo	= @SerialNo      	And
				ID		= 'INV'		And
				UnitNo		=@UnitNo
		
							
If @Status= 1
	Begin
	--Delivery  Note Update	
	If (@ToDelevery=1)
	Begin		
		Insert Into tb_DeliveryItem ([SerialNo],[RefNo],[LocaCode],[IDate],[CustomerCode],[CustomerName],[ItemCode],[RefCode],[Descript],[Unit],[PackSize]
		,[Qty],[Balance],[Price],[DeliveryDate],[Remark],[RowNo],[OrderStatus],[Id])
		Select @DocNo,@RefNo,@LocaCode,@IDate,@CustCode,@CustName,ItemCode,ItemSerialNo,ItemDescript,Unit,PackSize, Qty,Qty, Rate,@DilDate,'',IdNo,1,'INV'
		From tb_TempInv	Where   LocaCode	= @LocaCode	And	SerialNo= @SerialNo And	ID	= 'INV'	And	UnitNo	=@UnitNo			
	End			
	Declare @RepStat	As 	TinyInt
	Select @RepStat=Isnull(Rep,1) From tb_SalesRep Where Rep_Code=@RepCode
	--Update Combine Items stock
	Insert Into tb_Stock	
				([SerialNo]	,[LocaCode]		,[RefNo]	,[PDate]	,[SuppCode]	,[RepCode]	,[TourCode]	,[ItemCode]		,[Scale]	,[PackSize]	,[Qty]								,[Balance]	
				,[Rate]						,[Cost]					,[RealCost]	,[ID]		,[Type]		,[CrDate]		,[Status]	,[CSCode]	,[CSName]				,[ExpDate]	,[BatchNo]		,[BarcodeSerial]	,[IType])                                             
	Select 		@DocNo		,@LocaCode		,@RefNo		,@IDate		,@CustCode	,@RepCode	,''			,c.ComItem_Code	,'Each'		,1			,Sum(-t.Qty*c.Com_Qty*t.RefQty) 	,Sum(-t.Qty*c.Com_Qty*t.RefQty)	
				,c.ComCost_Price			,c.ComCost_Price  		,c.Com_Rate	,'IN2'		,@RepStat	,GetDate()		,1			,''			,''						,Null		,''				,''					,2
	From tb_TempInv As t Join tb_itemDetCom as c On t.ItemCode=c.Item_Code
				Where   t.LocaCode	= @LocaCode	And
					t.SerialNo	= @SerialNo       And
					t.ID		= 'INV'  	And
					t.UnitNo	=@UnitNo  And
					c.Status		=1
				Group By c.ComItem_Code,c.Com_Rate,c.ComCost_Price
				
	Insert Into tb_Stock	
				([SerialNo]	,[LocaCode]		,[RefNo]	,[PDate]	,[SuppCode]	,[RepCode]		,[TourCode]	,[ItemCode]		,[Scale]	,[PackSize]	,[Qty]		,[Balance]	
				,[Rate]									,[Cost]		,[RealCost]					,[ID]		,[Type]			,[CrDate]	,[Status]	,[CSCode]	,[CSName]				
				,[ExpDate]					,[BatchNo]	,[BarcodeSerial]		,[IType])                                             
	Select 		@DocNo		,@LocaCode		,@RefNo		,@IDate		,@CustCode	,@RepCode		,''			,ItemCode		,Scale		,PackSize	,Sum(Qty) 	,Sum(Qty)	
				,Sum(Discount + Amount)/Sum(Qty*RefQty)	,Cost		,Sum(Amount)/Sum(Qty*RefQty),'IN1'		,@RepStat		,GetDate()	,1			,''			,''						
				,Null						,''			,''						,2
	From tb_TempInv 	Where   LocaCode	= @LocaCode	And
					SerialNo	= @SerialNo       And
					ID		= 'INV'  	And
					UnitNo	=@UnitNo  And
					ItemCode in (Select Item_Code From tb_itemDetCom Where [Status]=1)
				Group By ItemCode,Scale,PackSize,Cost
	--Combine End

	--Update Stock
	Insert Into tb_Stock	
				([SerialNo]	,[LocaCode]					,[RefNo]	,[PDate]	,[SuppCode]	,[RepCode]	,[TourCode]	,[ItemCode]	,[Scale]	,[PackSize]	,[Qty]				,[Balance]			,[Rate]
				,[Cost]		,[RealCost]					,[Type]		,[ID]		,[CrDate]	,[Status]	,[CSCode]
				,[CSName]	,[ExpDate]		
				,[BatchNo]								,[BarcodeSerial]		,[IType])
	Select 		@DocNo		,@LocaCode					,@RefNo		,@IDate		,@CustCode	,@RepCode	,''			,ItemCode	,Scale		,PackSize	,Sum(Qty*RefQty) 	,Sum(Qty*RefQty)	,Sum(Discount + Amount)/Sum(Qty*RefQty)
				,Cost		,Sum(Amount)/Sum(Qty*RefQty),@RepStat	,'INV'		,GetDate()	,1			,Case When ItemType= 3 Then ItemSerialNo Else '' End
				,''			,Case ItemType When 2 Then Case Rtrim(Isnull(ItemSerialNo,'')) When '' Then Null Else ItemSerialNo End Else Null End
				,Rtrim(Isnull(ItemSerialNo,''))			,''						,2
	From tb_TempInv Where   LocaCode	= @LocaCode	And
							SerialNo	= @SerialNo      And
							ID		= 'INV'	And
							UnitNo	=@UnitNo
				Group By ItemCode,Scale,PackSize,Cost,[Type],Case ItemType When 3  Then ItemSerialNo Else '' End
				,Case ItemType When 2 Then Case Rtrim(Isnull(ItemSerialNo,'')) When '' Then Null Else ItemSerialNo End Else Null End,Rtrim(Isnull(ItemSerialNo,''))
				
	Insert Into tb_ItemSerialTmp ([Idx],[ItemCode],[Descrip],[BatchNo],[LocaCode],[RefNo],[Qty],[UserName],[Status],[Id],[RefDate],[CostPrice],[RetPrice],[SuppCode])
			Select IDNo,ItemCode,Rtrim(ItemDescript),RTRIM(ItemSerialNo),LocaCode,@DocNo,-Qty,@UserName,1,'INV',@IDate,Cost,Rate,@CustCode
			From tb_TempInv Where LocaCode	= @LocaCode	And SerialNo= @SerialNo And	[ID]= 'INV' And ItemType=4 And UnitNo	=@UnitNo
			


	Insert Into tb_InvQty 	([ItemCode]	,[LocaCode]	,[Qty]		,[Cr_Date]	,[Itype])
	Select 			ItemCode	,@LocaCode	,Sum(Qty*RefQty)	,GetDate()	,'1'
	From tb_TempInv 	Where   LocaCode	= @LocaCode	And
					SerialNo	= @SerialNo       And
					[ID]		= 'INV'		And
					UnitNo		=@UnitNo
				Group By ItemCode
	--##############################################################################################################
	--For Update Payment Details For Invoice
	Insert Into tb_Payment 	([SerialNo]	,[ReceiptNo]	,[RefNo]	,[CustCode]	,[CustName]	,[InvoiceDate]	,[Amount]	,[Balance]	,[GrossAmount],[CreditNote]	,[DebitNote]			
	,[Id],[Status],[Type]		,[PMode]	,[UserId]	,[Tr_Date]	,[LocaCode]	,[RepCode]	,[Discount]				,[IDiscount]	,[Tax]	,[IType],[Nbt],[Vat])
	Values (@DocNo	,@DocNo,@RefNo,@CustCode,@CustName,@IDate,(@NetAmount+@DocCharges),@Balance,@GrossAmount,0,0,'INV',1,@PType,@PMode,@UserName	,GetDate()	,@LocaCode	,@RepCode	,@SubTotDiscount+@TotDiscount	,@TotDiscount	,(@Tax+@Nbt)	,'2',@Nbt,@Tax)


	If  (@P1<>2 Or @P2<>2 Or @P3<>2  Or @P4<>2)
	Begin
		NextReceipt:			
		--Set @DFR	= ''
		Set @NextIdx	= 0

		UPDATE tb_System SET PMT=PMT+1 WHERE LocaCode=@LocaCode
	
		Select @NextIdx = Cast(PMT As Char(6)) FROM tb_System WHERE LocaCode = @LocaCode

		Set @NextIdx = Replicate('0',6-Len(Rtrim(@NextIdx))) + Rtrim(@NextIdx)
		
		IF (@DFR Is Null)
			Begin
			Set  @ReceNo= Rtrim(@NextIdx)	
			End 
		ELSE
			Begin
			Set  @ReceNo= @DFR +  Rtrim(@NextIdx)	
			End
			

			IF Exists(Select SerialNo From tb_Payment Where SerialNo=@ReceNo And LocaCode=@LocaCode  And [Id]='PMT')  Or Len(Rtrim(@NextIdx)) < 6 Goto NextReceipt
	
	-- Handle DOCUMENT CHARGES
	If (@DocCharges<>0)
	BEGIN
		Insert Into tb_Payment 	([SerialNo]	,[ReceiptNo],[RefNo],[CustCode]	,[CustName]	,[InvoiceDate],[Amount],[Balance],[Bank],[ChqDate],[Id],[Status],[Type],[PMode],[UserId],[Tr_Date],[LocaCode],[RepCode],[ChqNo],[Itype],[PayStat])
		Values		(@ReceNo	,@DocNo     ,@RefNo ,@CustCode	,@CustName  ,@IDate	,case when @NetAmount<0 then @DocCharges else -@DocCharges end	,0,@Bank1,@ChqDat1,'DOC',1,@PType,98,@UserName	,GetDate(),@LocaCode,@RepCode,@Rem1,'1',0)
	END		
	
	-- payment  records when minus		
	Declare @CreditNote Money
	If (@NetAmount<0) --before @NetAmount<0 -> my one(@NetAmount<0  And (@P1=18) )      --Credit Note & refund
	BEGIN 	
		-- Payment 1 of credit note and gift voucher
		-- if it is a credit note , CRN is isssued 
		if(Abs(@Amt1)>0)
		BEGIN
			IF   (@P1=18) --Credit Note
			Begin				
				Set @CreditNote=Abs(@NetAmount)
				Exec Sp_UPDATE_CREDIT_NOTE   @LocaCode ,@SerialNo ,@DocNo,@UserName,@IDate ,@CreditNote ,@CustCode,@CustName ,'Goods Return','0','0',1,'','','1900-01-01','INV',@RepCode
			End	
			
			IF   (@P1=6) --Gift Voucher
			Begin
				Update tb_GiftVoucher Set tb_GiftVoucher.Rec='F',tb_GiftVoucher.RecDate=Null   Where tb_GiftVoucher.VouCode=@Rem1
				Insert Into tb_GiftVoucherSale([VouCode],[Loca],[SDate],[UnitNo],[ZNo],[Receipt],[Cashier],[Id],[Status],[TrnsDate],[Amount],[Discount])
				Values (Rtrim(@Rem1),@LocaCode,@IDate,1,0,@ReceNo,@UserName,'010',1,GetDate(),@Amt1,0)
			End				
		END
		if(Abs(@Amt2)>0)
		BEGIN
			IF   (@P2=18) --Credit Note
			Begin				
				Set @CreditNote=Abs(@NetAmount)
				Exec Sp_UPDATE_CREDIT_NOTE   @LocaCode ,@SerialNo ,@DocNo,@UserName,@IDate ,@CreditNote ,@CustCode,@CustName ,'Goods Return','0','0',1,'','','1900-01-01','INV',@RepCode
			End	
			
			IF   (@P2=6) --Gift Voucher
			Begin
				Update tb_GiftVoucher Set tb_GiftVoucher.Rec='F',tb_GiftVoucher.RecDate=Null   Where tb_GiftVoucher.VouCode=@Rem2
				Insert Into tb_GiftVoucherSale([VouCode],[Loca],[SDate],[UnitNo],[ZNo],[Receipt],[Cashier],[Id],[Status],[TrnsDate],[Amount],[Discount])
				Values (Rtrim(@Rem2),@LocaCode,@IDate,1,0,@ReceNo,@UserName,'010',1,GetDate(),@Amt2,0)
			End	
		END
		if(Abs(@Amt3)>0)
		BEGIN
			IF   (@P3=18) --Credit Note
			Begin				
				Set @CreditNote=Abs(@NetAmount)
				Exec Sp_UPDATE_CREDIT_NOTE   @LocaCode ,@SerialNo ,@DocNo,@UserName,@IDate ,@CreditNote ,@CustCode,@CustName ,'Goods Return','0','0',1,'','','1900-01-01','INV',@RepCode
			End	
			
			IF   (@P3=6) --Gift Voucher
			Begin
				Update tb_GiftVoucher Set tb_GiftVoucher.Rec='F',tb_GiftVoucher.RecDate=Null   Where tb_GiftVoucher.VouCode=@Rem3
				Insert Into tb_GiftVoucherSale([VouCode],[Loca],[SDate],[UnitNo],[ZNo],[Receipt],[Cashier],[Id],[Status],[TrnsDate],[Amount],[Discount])
				Values (Rtrim(@Rem3),@LocaCode,@IDate,1,0,@ReceNo,@UserName,'010',1,GetDate(),@Amt3,0)
			End	
		END
		if(Abs(@Amt4)>0)
		BEGIN
			IF   (@P4=18) --Credit Note
			Begin				
				Set @CreditNote=Abs(@NetAmount)
				Exec Sp_UPDATE_CREDIT_NOTE   @LocaCode ,@SerialNo ,@DocNo,@UserName,@IDate ,@CreditNote ,@CustCode,@CustName ,'Goods Return','0','0',1,'','','1900-01-01','INV',@RepCode
			End	
			
			IF   (@P4=6) --Gift Voucher
			Begin
				Update tb_GiftVoucher Set tb_GiftVoucher.Rec='F',tb_GiftVoucher.RecDate=Null   Where tb_GiftVoucher.VouCode=@Rem4
				Insert Into tb_GiftVoucherSale([VouCode],[Loca],[SDate],[UnitNo],[ZNo],[Receipt],[Cashier],[Id],[Status],[TrnsDate],[Amount],[Discount])
				Values (Rtrim(@Rem4),@LocaCode,@IDate,1,0,@ReceNo,@UserName,'010',1,GetDate(),@Amt4,0)
			End	
		END
		
		
		


		
	End

	If @P1<>2  And @Amt1<>0 --Update Payment 1
		BEGIN
	
			Insert Into tb_Payment 	([SerialNo]	,[ReceiptNo]	,[RefNo]	,[CustCode]	,[CustName]	,[InvoiceDate]	,[Amount]	,[Balance]			,[Bank]		,[ChqDate]			
						,[Id]		,[Status]		,[Type]		,[PMode]	,[UserId]	,[Tr_Date]	,[LocaCode]	,[RepCode]	,[ChqNo]	,[IType],[PayStat])
			Values			(@ReceNo	,@DocNo          	,@RefNo      	,@CustCode	,@CustName    	,@IDate	,@Amt1		,@NetAmount-@Amt1		,@Bank1	,@ChqDat1
						,'PMT'		,1		,@PType	,@P1		,@UserName	,GetDate()	,@LocaCode	,@RepCode	,@Rem1	,'1',0)

			IF   (@P1=13) --Credit Note Settle
			Begin						
				--Set @TmpDate=Left(Ltrim(Convert(Varchar(10),@IDate,112)),4) + '-' + Right(Left(Ltrim(Convert(Varchar(10),@IDate,112)),7),2) + '-' +  Right(Rtrim(Convert(Varchar(10),@IDate,112)),2)
				Set @TmpDate=Right(Rtrim(Convert(Varchar(10),@IDate,112)),2)+'/'+ Right(Left(Ltrim(Convert(Varchar(10),@IDate,112)),6),2) +'/'+Left(Ltrim(Convert(Varchar(10),@IDate,112)),4)
				Exec SpUPDATECREDITNOTE   @LocaCode,@Rem1 ,@DocNo ,'0',@UserName,@CustCode,@TmpDate ,@Amt1,1 ,@CustName
			End
			IF   (@P1=6) --Gift Voucher
			Begin
				If (abs(@Amt1)>0) Update tb_GiftVoucher Set tb_GiftVoucher.Rec='T',tb_GiftVoucher.RecDate=@IDate   Where tb_GiftVoucher.VouCode=@Rem1 Else Update tb_GiftVoucher Set tb_GiftVoucher.Rec='F',tb_GiftVoucher.RecDate=Null   Where tb_GiftVoucher.VouCode=@Rem1
				Insert Into tb_GiftVoucherSale([VouCode],[Loca],[SDate],[UnitNo],[ZNo],[Receipt],[Cashier],[Id],[Status],[TrnsDate],[Amount],[Discount])
				Values (Rtrim(@Rem1),@LocaCode,@IDate,1,0,@ReceNo,@UserName,'010',1,GetDate(),@Amt1,0)
			End		
			IF   (@P1=19) --Advance Set Off
			Begin
				If (abs(@Amt1)>0) Exec Sp_AdvanceSettle @Rem1,@LocaCode,'T',@UserName,@Amt1
			End	

		End
	If @P2<>2  And @Amt2<>0 --Update Payment 2
		Begin
		 Insert Into tb_Payment 	([SerialNo]	,[ReceiptNo]	,[RefNo]	,[CustCode]	,[CustName]	,[InvoiceDate]	,[Amount]	,[Balance]			,[Bank]		,[ChqDate]			
						,[Id]		,[Status]		,[Type]		,[PMode]	,[UserId]	,[Tr_Date]	,[LocaCode]	,[RepCode]	,[ChqNo]	,[IType],[PayStat])
			Values			(@ReceNo	,@DocNo          	,@RefNo      	,@CustCode	,@CustName    	,@IDate	,@Amt2		,@NetAmount-@Amt1-@Amt2	,@Bank2	,@ChqDat2
						,'PMT'		,1		,@PType	,@P2		,@UserName	,GetDate()	,@LocaCode	,@RepCode	,@Rem2	,'1',0)	
 				
 				
			IF   (@P2=13) --Credit Note Settle
			Begin
				--Set @TmpDate=Left(Ltrim(Convert(Varchar(10),@IDate,112)),4) + '-' + Right(Left(Ltrim(Convert(Varchar(10),@IDate,112)),7),2) + '-' +  Right(Rtrim(Convert(Varchar(10),@IDate,112)),2)
				Set @TmpDate=Right(Rtrim(Convert(Varchar(10),@IDate,112)),2)+'/'+ Right(Left(Ltrim(Convert(Varchar(10),@IDate,112)),6),2) +'/'+Left(Ltrim(Convert(Varchar(10),@IDate,112)),4)
				Exec SpUPDATECREDITNOTE   @LocaCode,@Rem2 ,@DocNo ,'0',@UserName,@CustCode,@TmpDate ,@Amt2,1 ,@CustName
			End	
			IF   (@P2=6) --Gift Voucher
			Begin
				If (abs(@Amt2)>0) Update tb_GiftVoucher Set tb_GiftVoucher.Rec='T',tb_GiftVoucher.RecDate=@IDate   Where tb_GiftVoucher.VouCode=@Rem2 Else Update tb_GiftVoucher Set tb_GiftVoucher.Rec='F',tb_GiftVoucher.RecDate=Null   Where tb_GiftVoucher.VouCode=@Rem2
				Insert Into tb_GiftVoucherSale([VouCode],[Loca],[SDate],[UnitNo],[ZNo],[Receipt],[Cashier],[Id],[Status],[TrnsDate],[Amount],[Discount])
				Values (Rtrim(@Rem2),@LocaCode,@IDate,1,0,@ReceNo,@UserName,'010',1,GetDate(),@Amt2,0)
			End	
			IF   (@P2=19) --Advance Set Off
			Begin
				If (abs(@Amt2)>0) Exec Sp_AdvanceSettle @Rem2,@LocaCode,'T',@UserName,@Amt2
			End	

		End
		If @P3<>2  And @Amt3<>0 --Update Payment 3
			Begin
				Insert Into tb_Payment 	([SerialNo]	,[ReceiptNo]	,[RefNo]	,[CustCode]	,[CustName]	,[InvoiceDate]	,[Amount]	,[Balance]				,[Bank]		,[ChqDate]			
							,[Id]		,[Status]		,[Type]		,[PMode]	,[UserId]	,[Tr_Date]	,[LocaCode]	,[RepCode]	,[ChqNo]	,[Itype],[PayStat])
				Values			(@ReceNo	,@DocNo          	,@RefNo      	,@CustCode	,@CustName    	,@IDate	,@Amt3		,@NetAmount-@Amt1-@Amt2-@Amt3	,@Bank3	,@ChqDat3
							,'PMT'		,1		,@PType	,@P3		,@UserName	,GetDate()	,@LocaCode	,@RepCode	,@Rem3	,'1',0)

				IF   (@P3=13) --Credit Note Settle
				Begin
					--Set @TmpDate=Left(Ltrim(Convert(Varchar(10),@IDate,112)),4) + '-' + Right(Left(Ltrim(Convert(Varchar(10),@IDate,112)),7),2) + '-' +  Right(Rtrim(Convert(Varchar(10),@IDate,112)),2)						
					Set @TmpDate=Right(Rtrim(Convert(Varchar(10),@IDate,112)),2)+'/'+ Right(Left(Ltrim(Convert(Varchar(10),@IDate,112)),6),2) +'/'+Left(Ltrim(Convert(Varchar(10),@IDate,112)),4)
					Exec SpUPDATECREDITNOTE   @LocaCode,@Rem3 ,@DocNo ,'0',@UserName,@CustCode,@TmpDate ,@Amt3,1 ,@CustName
				End	
				IF   (@P3=6) --Gift Voucher
				Begin						
					Begin
						If (abs(@Amt3)>0) Update tb_GiftVoucher Set tb_GiftVoucher.Rec='T',tb_GiftVoucher.RecDate=@IDate   Where tb_GiftVoucher.VouCode=@Rem3 Else Update tb_GiftVoucher Set tb_GiftVoucher.Rec='F',tb_GiftVoucher.RecDate=Null   Where tb_GiftVoucher.VouCode=@Rem3
						Insert Into tb_GiftVoucherSale([VouCode],[Loca],[SDate],[UnitNo],[ZNo],[Receipt],[Cashier],[Id],[Status],[TrnsDate],[Amount],[Discount])
						Values (Rtrim(@Rem3),@LocaCode,@IDate,1,0,@ReceNo,@UserName,'010',1,GetDate(),@Amt3,0)
					End
				End
				IF   (@P3=19) --Advance Set Off
				Begin
					If (abs(@Amt3)>0) Exec Sp_AdvanceSettle @Rem3,@LocaCode,'T',@UserName,@Amt3
				End		
			End
			If @P4<>2  And @Amt4<>0 --Update Payment 4
				Begin
					Insert Into tb_Payment 	([SerialNo]	,[ReceiptNo]	,[RefNo]	,[CustCode]	,[CustName]	,[InvoiceDate]	,[Amount]	,[Balance]					,[Bank]		,[ChqDate]			
								,[Id]		,[Status]		,[Type]		,[PMode]	,[UserId]	,[Tr_Date]	,[LocaCode]	,[RepCode]	,[ChqNo]	,[Itype],[PayStat])
					Values			(@ReceNo	,@DocNo          	,@RefNo      	,@CustCode	,@CustName    	,@IDate	,@Amt4		,@NetAmount-@Amt1-@Amt2-@Amt3-@Amt4	,@Bank4	,@ChqDat4
								,'PMT'		,1		,@PType	,@P4		,@UserName	,GetDate()	,@LocaCode	,@RepCode	,@Rem4	,'1',0)

					IF   (@P4=13) --Credit Note Settle
					Begin
						--Set @TmpDate=Left(Ltrim(Convert(Varchar(10),@IDate,112)),4) + '-' + Right(Left(Ltrim(Convert(Varchar(10),@IDate,112)),7),2) + '-' +  Right(Rtrim(Convert(Varchar(10),@IDate,112)),2)
						Set @TmpDate=Right(Rtrim(Convert(Varchar(10),@IDate,112)),2)+'/'+ Right(Left(Ltrim(Convert(Varchar(10),@IDate,112)),6),2) +'/'+Left(Ltrim(Convert(Varchar(10),@IDate,112)),4)
						Exec SpUPDATECREDITNOTE   @LocaCode,@Rem4 ,@DocNo ,'0',@UserName,@CustCode,@TmpDate ,@Amt4,1 ,@CustName
					End	
					IF   (@P4=6) --Gift Voucher
					Begin
						If (abs(@Amt4)>0) Update tb_GiftVoucher Set tb_GiftVoucher.Rec='T',tb_GiftVoucher.RecDate=@IDate   Where tb_GiftVoucher.VouCode=@Rem4 Else Update tb_GiftVoucher Set tb_GiftVoucher.Rec='F',tb_GiftVoucher.RecDate=Null   Where tb_GiftVoucher.VouCode=@Rem4
						Insert Into tb_GiftVoucherSale([VouCode],[Loca],[SDate],[UnitNo],[ZNo],[Receipt],[Cashier],[Id],[Status],[TrnsDate],[Amount],[Discount])
						Values (Rtrim(@Rem4),@LocaCode,@IDate,1,0,@ReceNo,@UserName,'010',1,GetDate(),@Amt4,0)

						End	
					IF   (@P4=19) --Advance Set Off
					Begin
						If (abs(@Amt4)>0) Exec Sp_AdvanceSettle @Rem1,@LocaCode,'T',@UserName,@Amt4
					End
				End	
	End
	Insert Into tb_DocNo ([DocNo],[tempNo],[Loca],[ID],[UserName]) Values (@DocNo,@SerialNo,@LocaCode,'IN2',@UserName)

	-- loyalty 	
	
	Declare @LoyaltyCustCode Varchar(20)
	select @LoyaltyCustCode=LoyaltyCustCode From tb_Customer Where Cust_Code= @CustCode 

	-- Check whether a customer is Loyalty or not
	-- If Loyalty Customer Then Add Points
	if Exists (select CustCode from tb_CustomerLoyalty where CustCode = @LoyaltyCustCode and [Status] = 1)
	Begin 	
		
		Declare @LoyaltyCustName Varchar(20)
		Declare @CustType int
		Declare @ClaimMode int
		Declare @PurchaseMode int
		Declare @Rate decimal(18,2)
		Declare @Points decimal(18,2)
		--Set @LoyaltyCustCode=''
		
		select @LoyaltyCustName = CustName From tb_CustomerLoyalty Where CustCode = @LoyaltyCustCode
		select @CustType = CardType From tb_CustomerLoyalty Where CustCode = @LoyaltyCustCode
		select @ClaimMode = ClmMode From tb_CustomerLoyalty Where CustCode = @LoyaltyCustCode
		select @PurchaseMode = PchMode From tb_CustomerLoyalty Where CustCode = @LoyaltyCustCode
		-- Change this rate to increase or reduce points
		Set @Rate=1
		select @Rate = Rate from tb_LoyCategory where Id = @CustType 
		set @Points = (@Rate / 100) * @NetAmount
		
		-- [Iid] = 1 : - Increase Points
		-- [Iid] = 2 : - Reduce Points 
		INSERT INTO [dbo].[tb_LoyaltyDet]
			   ([CustCode],	[CustName],	[CustType],	[Sdate],	[STime],	[Amount],	[Loca],	[UnitNo]
			   ,[Zno],	[Receipt],	[Cashier],	[Iid],	[ClaimType],	[PurcType],	[Total],	[Rate],	[Points]
			   ,[TrnsDate]
			   )	
		Values
				(@LoyaltyCustCode, @LoyaltyCustName, @CustType, (Select Convert(Datetime,Convert(Varchar(11),GetDate(),103),103)), GetDate(), @NetAmount, @LocaCode,1
				,1,	@DocNo,	@UserName,		1,	@ClaimMode,		@PurchaseMode,	@NetAmount,	@Rate,	@Points, 
				GetDate() 
				)
	
		Update tb_CustomerLoyalty Set Points=Isnull(Points,0) + @Points Where CustCode=@LoyaltyCustCode
		-- 15 : - Payment method = Loyalty Card
		if @P1 = 15 And @Amt1 <> 0
		Begin 
			INSERT INTO [dbo].[tb_LoyaltyDet]
				   ([CustCode],	[CustName],	[CustType],	[Sdate],	[STime],	[Amount],	[Loca],	[UnitNo]
				   ,[Zno],	[Receipt],	[Cashier],	[Iid],	[ClaimType],	[PurcType],	[Total],	[Rate],	[Points]
				   ,[TrnsDate]
				   )	
			Values
				(@LoyaltyCustCode, @LoyaltyCustName, @CustType, (Select Convert(Datetime,Convert(Varchar(11),GetDate(),103),103)), GetDate(), @NetAmount, @LocaCode,1
				,1,	@DocNo,	@UserName,		2,	@ClaimMode,		@PurchaseMode,	@NetAmount,	@Rate,	@Amt1, 	GetDate() 
			)
				Update tb_CustomerLoyalty Set Points=Isnull(Points,0) - @Amt1 Where CustCode=@LoyaltyCustCode
		End
		-- 15 : - Payment method = Loyalty Card
		if @P2 = 15 And @Amt2 <> 0
		Begin 
		INSERT INTO [dbo].[tb_LoyaltyDet]
			   ([CustCode],	[CustName],	[CustType],	[Sdate],	[STime],	[Amount],	[Loca],	[UnitNo]
			   ,[Zno],	[Receipt],	[Cashier],	[Iid],	[ClaimType],	[PurcType],	[Total],	[Rate],	[Points]
			   ,[TrnsDate]
			   )	
		Values
				(@LoyaltyCustCode, @LoyaltyCustName, @CustType,(Select Convert(Datetime,Convert(Varchar(11),GetDate(),103),103)), GetDate(), @NetAmount, @LocaCode,1
				,1,	@DocNo,	@UserName,		2,	@ClaimMode,		@PurchaseMode,	@NetAmount,	@Rate,	@Amt2, 	GETDATE()
				)
				Update tb_CustomerLoyalty Set Points=Isnull(Points,0) - @Amt2 Where CustCode=@LoyaltyCustCode
		End
		-- 15 : - Payment method = Loyalty Card
		if @P3 = 15 And @Amt3 <> 0
		Begin 
			INSERT INTO [dbo].[tb_LoyaltyDet]
				   ([CustCode],	[CustName],	[CustType],	[Sdate],	[STime],	[Amount],	[Loca],	[UnitNo]
				   ,[Zno],	[Receipt],	[Cashier],	[Iid],	[ClaimType],	[PurcType],	[Total],	[Rate],	[Points]
				   ,[TrnsDate]
				   )	
			Values
					(@LoyaltyCustCode, @LoyaltyCustName, @CustType, (Select Convert(Datetime,Convert(Varchar(11),GetDate(),103),103)), GetDate(), @NetAmount, @LocaCode,1
					,1,	@DocNo,	@UserName,		2,	@ClaimMode,		@PurchaseMode,	@NetAmount,	@Rate,	@Amt3, 	GetDate()
					)
				Update tb_CustomerLoyalty Set Points=Isnull(Points,0) - @Amt3 Where CustCode=@LoyaltyCustCode
		End
		-- 15 : - Payment method = Loyalty Card
		if @P4 = 15 And @Amt4 <> 0
		Begin 
			INSERT INTO [dbo].[tb_LoyaltyDet]
				   ([CustCode],	[CustName],	[CustType],	[Sdate],	[STime],	[Amount],	[Loca],	[UnitNo]
				   ,[Zno],	[Receipt],	[Cashier],	[Iid],	[ClaimType],	[PurcType],	[Total],	[Rate],	[Points]
				   ,[TrnsDate]
				   )	
			Values
					(@LoyaltyCustCode, @LoyaltyCustName, @CustType, (Select Convert(Datetime,Convert(Varchar(11),GetDate(),103),103)), GetDate(), @NetAmount, @LocaCode,1
					,1,	@DocNo,	@UserName,		2,	@ClaimMode,		@PurchaseMode,	@NetAmount,	@Rate,	@Amt4, 		GetDate() 
					)
				Update tb_CustomerLoyalty Set Points=Isnull(Points,0) - @Amt4 Where CustCode=@LoyaltyCustCode
		End		
	End
End

Delete From tb_TempInv 	Where   LocaCode	= @LocaCode	And
					SerialNo	= @SerialNo       And
					ID		= 'INV'		And
					UnitNo		=@UnitNo
					
					
-- for SunLanka TEchnician Update

IF EXISTS (SELECT * FROM tb_TempUpdateTech WHERE LocaCode=@LocaCode And UserName = @UserName And SerialNo=@SerialNo AND ID = 'INV')
BEGIN
	INSERT INTO tb_InvoiceTechnician 
			([SerialNo] ,[ItemCode] ,[LocaCode] ,[Rep_Code] ,[Rep_Name] ,[ItemSerial]	,[UserName] ,[ID])
	SELECT   @DocNo		,ItemCode	,@LocaCode	,Rep_Code	,Rep_Name	,ItemSerial		,@UserName	,'INV'  
	FROM	tb_TempUpdateTech 	 WHERE  LocaCode = @LocaCode	AND	SerialNo = @SerialNo AND
										ID		 = 'INV'		AND	UserName = @UserName
										
	DELETE FROM tb_TempUpdateTech 	WHERE   LocaCode	= @LocaCode	AND	SerialNo	= @SerialNo       AND
					ID		= 'INV'		AND		UserName		= @UserName	       
 
END

