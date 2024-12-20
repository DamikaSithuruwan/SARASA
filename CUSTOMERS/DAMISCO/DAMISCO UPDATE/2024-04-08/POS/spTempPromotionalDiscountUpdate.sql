USE [SPOSDATA]
GO
/****** Object:  StoredProcedure [dbo].[spTempPromotionalDiscountUpdate]    Script Date: 09/04/2024 02:05:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[spTempPromotionalDiscountUpdate]
	 @LocationID int
	,@Receipt char(10)
	,@UnitNo int
	,@DecimalPointsCurrency int
	,@DiscountPercentage decimal(18,4)
	,@DiscountAmount decimal(18,4)
	,@IsCombinedPromotion bit
	,@NetAmount decimal(18,4)
	,@DiscountID int
	,@CustomerType INT
	,@CustomerID INT
    ,@DocumentID INT
    ,@BillTypeID INT
    ,@SaleTypeID INT
	,@CashierID BIGINT
    ,@Cashier VARCHAR(50)
	,@RefNo VARCHAR(50)
	,@PromotionID bigint
AS
--By Pravin
----20/03/2014
	SET NOCOUNT ON

BEGIN TRY
       BEGIN TRANSACTION 

DECLARE @Amount decimal(18,4)=0,@AmountTmp decimal(18,4)=0,@AmountNoPromo decimal(18,4)=0,
@RowNO bigint=0,@DiscountPercentageSave decimal(18,4)=0,
@RowNoPayment bigint=0, @IsPaid bit=0,@DiscountNo INT,@ValueTo decimal(18,4)=0,
@IsOneItemAllowOneDiscount bit = 0

/*
    ,@LocationID int=2
	,@Receipt char(10)='00000295'
	,@UnitNo int=3
	,@DecimalPointsCurrency int=2
	,@DiscountPercentage decimal(18,4)=10
	,@DiscountAmount decimal(18,4)=10
	,@IsCombinedPromotion bit=0
	,@NetAmount decimal(18,4)=500
	,@DiscountID int=6
	,@CustomerType INT
	,@CustomerID INT
    ,@DocumentID INT
    ,@BillTypeID INT
    ,@SaleTypeID INT
	,@CashierID BIGINT
    ,@Cashier VARCHAR(50)

	*/
	
select @IsOneItemAllowOneDiscount=IsOneItemAllowOneDiscount from SysConfig where LocationID=@LocationID and UnitNo=@UnitNo

if(@IsCombinedPromotion=0)
BEGIN

	UPDATE TempItemDet  SET IDis1=0,IDiscount1=0,IDI1=0
	WHERE IDis1!=0 AND IDis1<@DiscountPercentage 
	AND IDI1!=5

	UPDATE TempItemDet  SET IDis2=0,IDiscount2=0,IDI2=0
	WHERE IDis2!=0 AND IDis2<@DiscountPercentage 
	AND IDI2!=5

	UPDATE TempItemDet  SET IDis3=0,IDiscount3=0,IDI3=0
	WHERE IDis3!=0 AND IDis3<@DiscountPercentage 
	AND IDI3!=5

	UPDATE TempItemDet  SET IDis4=0,IDiscount4=0,IDI4=0
	WHERE IDis4!=0 AND IDis4<@DiscountPercentage 
	AND IDI4!=5

	UPDATE TempItemDet  SET IDis4=5,IDiscount5=0,IDI5=0
	WHERE IDis5!=0 AND IDis5<@DiscountPercentage 
	AND IDI5!=5
	
	update TempItemDet set Nett=Amount-(IDiscount1+IDiscount2+IDiscount3+IDiscount4+IDiscount5),Rate=Nett/Qty 
	Where LocationID=@LocationID And Receipt=@Receipt 
	And UnitNo=@UnitNo  AND BillTypeID=@BillTypeID AND SaleTypeID=@SaleTypeID AND DOCUMENTID IN (1,2,3,4)
	


	IF @SaleTypeID=2
	BEGIN

		SELECT @Amount = ROUND(((ISNULL(SUM(Nett),0)) ),@DecimalPointsCurrency)
		From TempItemDet		
		Where  LocationID=@LocationID And Receipt=@Receipt And UnitNo=@UnitNo And DocumentID IN(1,3)
		AND BillTypeID=@BillTypeID AND SaleTypeID=@SaleTypeID
		AND RowNo NOT IN (SELECT RowNo FROM TempItemDet WHERE (IDiscount1<>0 and IDI1<>5)  OR (IDiscount2<>0 and IDI2<>5)  
		OR (IDiscount3<>0 and IDI3<>5)  OR (IDiscount4<>0 and IDI4<>5)  OR (IDiscount5<>0 and IDI5<>5))

	 END
	 ELSE
	 BEGIN

		SELECT @Amount = ROUND(((ISNULL(SUM(Nett),0)) ),@DecimalPointsCurrency)
		From TempItemDet t
		INNER JOIN (SELECT ProductID,IsPromotion,IsNonDiscount,SellingPrice FROM ProductMaster GROUP BY ProductID,IsPromotion,IsNonDiscount,SellingPrice) P
		ON P.ProductID=t.ProductID and (Price=SellingPrice or not exists(select ProductCode from ProductMaster where ProductID=t.ProductID group by ProductCode having COUNT(1)>1))
		Where  LocationID=@LocationID And Receipt=@Receipt And UnitNo=@UnitNo And DocumentID IN(1,3) AND P.IsPromotion=1
		AND BillTypeID=@BillTypeID AND SaleTypeID=@SaleTypeID
		AND (p.IsNonDiscount=0 OR p.IsNonDiscount IS NULL) AND (@IsOneItemAllowOneDiscount=0 OR IsFixedDiscount=1 OR (IDI1=0 and IsSDis=0))
		AND RowNo NOT IN (SELECT RowNo FROM TempItemDet WHERE (IDiscount1<>0 and IDI1<>5)  OR (IDiscount2<>0 and IDI2<>5)  
		OR (IDiscount3<>0 and IDI3<>5)  OR (IDiscount4<>0 and IDI4<>5)  OR (IDiscount5<>0 and IDI5<>5))

	 END


	SELECT @AmountTmp =ROUND(ISNULL(SUM(Nett),0),@DecimalPointsCurrency)
	From TempItemDet 
	Where  LocationID=@LocationID And Receipt=@Receipt And UnitNo=@UnitNo And DocumentID=6
	AND BillTypeID=@BillTypeID AND SaleTypeID=@SaleTypeID

	SET @Amount=@Amount-@AmountTmp

	SET @AmountTmp=0

	SELECT @AmountTmp = ROUND(((ISNULL(SUM(Nett),0)) ),@DecimalPointsCurrency)
	From TempItemDet 
	Where  LocationID=@LocationID And Receipt=@Receipt And UnitNo=@UnitNo And DocumentID IN(2,4) 
	AND BillTypeID=@BillTypeID AND SaleTypeID=@SaleTypeID
		

	SET @Amount=@Amount-@AmountTmp

	SET @AmountTmp=0


	SELECT @AmountTmp =ROUND(ISNULL(sum(CASE WHEN Amount > Balance THEN Balance ELSE Amount END ),0),@DecimalPointsCurrency)
	From TempPaymentDet 
	Where  LocationID=@LocationID And Receipt=@Receipt And UnitNo=@UnitNo 
	AND BillTypeID=@BillTypeID AND SaleTypeID=@SaleTypeID

	SET @Amount=@Amount-@AmountTmp

	SET @AmountTmp=0

END
ELSE
BEGIN

	SELECT @AmountNoPromo=isnull(sum(Nett),0) FROM  TempItemDet
	INNER JOIN (SELECT ProductID,IsPromotion FROM ProductMaster GROUP BY ProductID,IsPromotion) P
	ON P.ProductID=TempItemDet.ProductID
	Where LocationID=@LocationID And Receipt=@Receipt 
	And UnitNo=@UnitNo  AND BillTypeID=@BillTypeID AND SaleTypeID=@SaleTypeID AND DOCUMENTID IN (1,2,3,4)
	AND P.IsPromotion=0

	SET @Amount = @NetAmount-@AmountNoPromo

END



SET @DiscountPercentageSave=@DiscountPercentage
SET @Amount=ROUND(ISNULL(@Amount,0),@DecimalPointsCurrency)



IF @DiscountAmount=0
BEGIN

	SET	@DiscountAmount=ROUND(ISNULL((@Amount*@DiscountPercentage/100),0),@DecimalPointsCurrency)
END
ELSE
BEGIN

	SET	@DiscountPercentage=0

END


IF(@DiscountPercentage>0)
BEGIN
	
	if(@RefNo<>'' and LEN(@RefNo)=16)
	begin
		select @ValueTo=ValueTo from BankBin where @RefNo like ltrim(rtrim(CardPfx))+'%'

		if(@ValueTo>0 and @Amount>@ValueTo)
		begin
			set @Amount=@ValueTo
		end
	end

	SET	@DiscountAmount=ROUND(ISNULL((@Amount*@DiscountPercentage/100),0),@DecimalPointsCurrency)

END

IF(@Amount!=@NetAmount)
BEGIN
	
	SET	@DiscountPercentage=0

END


IF (abs(@DiscountAmount)<=abs(@Amount) AND abs(@DiscountAmount)>0 AND @Amount>0)
BEGIN

	select @RowNoPayment=isnull(max(RowNo),0) from TempPaymentDet Where LocationID=@LocationID 
	And Receipt=@Receipt And UnitNo=@UnitNo 

	select @RowNO=isnull(max(RowNo),0) from TempItemDet Where LocationID=@LocationID 
	And Receipt=@Receipt And UnitNo=@UnitNo 


	select @DiscountNo=isnull(Count(RowNo),0)+1 from TempItemDet Where LocationID=@LocationID 
	And Receipt=@Receipt And UnitNo=@UnitNo And DocumentID=6 
			
			
			
			IF @RowNo<@RowNoPayment
			BEGIN
				SET @RowNo=@RowNoPayment
				
			END
			
			IF @RowNoPayment>0
			BEGIN
				
				SET @IsPaid=1
			END
			
			SET @RowNo=@RowNo+1

			
			INSERT INTO TempItemDet
	(
       ProductID
      ,ProductCode
      ,RefCode
      ,BarCodeFull
      ,Descrip
      ,BatchNo
      ,SerialNo
      ,ExpiaryDate
      ,Cost
      ,AvgCost
      ,Price
      ,Qty
      ,Amount
      ,UnitOfMeasureID
      ,UnitOfMeasureName
      ,ConvertFactor
      ,Rate
      ,Nett
      ,LocationID
      ,DocumentID
      ,BillTypeID
      ,SaleTypeID
      ,Receipt
      ,SalesmanID
      ,Salesman
      ,CustomerID
      ,Customer
      ,CashierID
      ,Cashier
      ,StartTime
      ,EndTime
      ,RecDate
      ,BaseUnitID
      ,UnitNo
      ,RowNo
      ,IsRecall
      ,RecallNo
      ,RecallAdv      
      ,TaxAmount
      ,IsTax
      ,TaxPercentage
      ,IsStock
	  ,IsSDis
	  ,SDID
	  ,SDIs
	  ,SDiscount
	  ,SDNo
	  ,CustomerType
	  ,IsPaidBeforeDiscount
	  ,TransStatus
	  ,IsPromotion
	  ,PromotionID
	)

	VALUES
	 (
       0
      ,''
      ,@RefNo
      ,''
      ,''
      ,''
      ,''
      ,NULL
      ,0
      ,0
      ,0
      ,0
      ,0
      ,0
      ,0
      ,0
      ,0
      ,@DiscountAmount
      ,@LocationID
      ,@DocumentID
      ,@BillTypeID
      ,@SaleTypeID
      ,@Receipt
      ,0
      ,''
      ,@CustomerID
      ,''
      ,@CashierID
      ,@Cashier
      ,cast(getdate() as datetime)
      ,cast(getdate() as datetime)
      ,cast(getdate() as date)
      ,0
      ,@UnitNo
      ,@RowNo
      ,0
      ,''
      ,''
      ,0
      ,0
      ,0
      ,0
	  ,0
	  ,@DiscountID
	  ,@DiscountPercentage
	  ,@DiscountAmount
	  ,@DiscountNo
	  ,@CustomerType
	  ,@IsPaid
	  ,1
	  ,1
	  ,@PromotionID
	  )


		update TempItemDet 
		set  IsSDis=1,SDID=@DiscountID,SDIs=@DiscountPercentage,
		SDiscount=(SDiscount+((Nett-SDiscount)*(@DiscountAmount/@NetAmount)))
		,CustomerID=@CustomerID,CustomerType=@CustomerType					
		Where LocationID=@LocationID AND Receipt=@Receipt And UnitNo=@UnitNo 
		And IsSDis=0  And DocumentID IN (1,2,3,4)
		And IsRecall=0


END

	  COMMIT TRANSACTION;
	  SELECT '0' AS Result
	END TRY
  
    BEGIN CATCH
      IF @@TRANCOUNT > 0
	  begin
         ROLLBACK TRANSACTION
		 SELECT ERROR_MESSAGE() AS Result

	  end
	  else
      begin
		 SELECT ERROR_MESSAGE() AS Result
	  end
    END CATCH
