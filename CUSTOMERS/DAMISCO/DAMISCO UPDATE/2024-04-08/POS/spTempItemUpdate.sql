USE [SPOSDATA]
GO
/****** Object:  StoredProcedure [dbo].[spTempItemUpdate]    Script Date: 08/04/2024 07:37:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	
	ALTER PROCEDURE [dbo].[spTempItemUpdate]
	   @LocationID int
	  ,@ProductID bigint
      ,@ProductCode varchar(50)
      ,@RefCode varchar(50)
	  ,@BarCodeFull bigint
      ,@Descrip varchar(50)
      ,@Cost decimal(18,4)
      ,@Price decimal(18,4)
      ,@Qty decimal(18,4)
      ,@DocumentID int
      ,@Receipt varchar(10)
	  ,@CashierID bigint
      ,@Cashier  varchar(15)
	  ,@UnitNo int	  
	  ,@BillTypeID int
	  ,@SaleTypeID int
	  ,@BaseUnitID bigint
	  ,@UnitOfMeasureID bigint
	  ,@UnitOfMeasureName varchar(10)
	  ,@ConvertFactor decimal(18,4)
	  ,@BatchNo varchar(50)
	  ,@SerialNo varchar(50)
	  ,@ExpiaryDate Date =null
	  ,@IsTax bit
	  ,@TaxPercentage Decimal(18,4)
	  ,@SalesmanID bigint
	  ,@Salesman varchar(15)
	  ,@CustomerID bigint
	  ,@Customer varchar(15)
	  ,@IsStock bit
	  ,@CustomerType int
      ,@TransStatus INT
	  ,@IsPromotion bit
	  ,@FixedDiscount decimal(18,4)
	  ,@FixedDiscountPercentage decimal(18,4)
	  ,@PromotionID bigint
	  ,@ProductColorSizeID bigint
	  ,@ExchangeReasonID bigint
	  ,@IsItemSeek bit
	  ,@GuidePersonID bigint=0
	  ,@GuidePersonName varchar(50)=''

	  as
	  --delete  from TempItemDet
	 --select * from TempItemDet
	 Declare @tempQty decimal(18,4),
		     @RowNo bigint=0,
		     @RowNoPayment BIGINT=0,
			 @TaxAmount decimal(18,4)=0

	 Declare @tempFixedDisPer decimal(18,4)=0,
		     @tempFixedDisVal decimal(18,4)=0

SET NOCOUNT ON

BEGIN TRY
       BEGIN TRANSACTION 

	   

select @RowNoPayment=isnull(max(RowNo),0) from TempPaymentDet Where LocationID=@LocationID And Receipt=@Receipt And UnitNo=@UnitNo

if not exists(select ProductCode from TempItemDet Where ProductID=@ProductID And LocationID=@LocationID And 
		       Receipt=@Receipt And UnitNo=@UnitNo 
			   AND (SaleTypeID=2 OR SaleTypeID=7))
			   
begin

IF(@ExpiaryDate is null)

begin
	


	 if exists(select ProductCode from TempItemDet Where ProductID=@ProductID And LocationID=@LocationID And 
		       Receipt=@Receipt And UnitNo=@UnitNo And DocumentID=@DocumentID And Price=@Price AND RefCode=@RefCode
			   And BillTypeID=@BillTypeID And IsRecall=0 And UnitOfMeasureID=@UnitOfMeasureID And
			   IsSDis=0 AND IsPaid=0 And BatchNo=@BatchNo And SerialNo=@SerialNo And SaleTypeID=@SaleTypeID AND Descrip=@Descrip 
			   And (IDiscount1=0 And IDiscount2=0 And IDiscount3=0 And IDiscount4=0 And IDiscount5=0 And IsSDis=0)  And IsPromotion=@IsPromotion And IsPromotionApplied=0
			   And ProductColorSizeID=@ProductColorSizeID)
			   
		 begin



			select @tempQty=Qty from TempItemDet Where ProductID=@ProductID And LocationID=@LocationID And 
		       Receipt=@Receipt And UnitNo=@UnitNo And DocumentID=@DocumentID And Price=@Price And
			   RefCode=@RefCode And BillTypeID=@BillTypeID And IsRecall=0 And UnitOfMeasureID=@UnitOfMeasureID And
			   IsSDis=0 AND IsPaid=0  And BatchNo=@BatchNo And SerialNo=@SerialNo And SaleTypeID=@SaleTypeID
			   And (IDiscount1=0 And IDiscount2=0 And IDiscount3=0 And IDiscount4=0 And IDiscount5=0 And IsSDis=0)  And IsPromotion=@IsPromotion And IsPromotionApplied=0
			   And ProductColorSizeID=@ProductColorSizeID
					


				--if(@SerialNo<>'' OR @SaleTypeID=2  OR @SaleTypeID=7)
				if(@SaleTypeID=2  OR @SaleTypeID=7)
				begin
					
					set @tempQty=0

				END

			select @RowNo=isnull(max((RowNo)),0) from TempItemDet Where LocationID=@LocationID And Receipt=@Receipt And UnitNo=@UnitNo
			
			
			IF @RowNo<@RowNoPayment
			BEGIN
				SET @RowNo=@RowNoPayment
				
			END
			
			set @RowNo=isnull(@RowNo,0)+1
			

						Update TempItemDet Set
							   Cost=@Cost
							  ,BarCodeFull=@BarCodeFull
							  ,Descrip=@Descrip
							  ,CashierID=@CashierID
							  ,Cashier=@Cashier
							  ,Qty=@tempQty+@Qty
							  ,Amount=@Price*(@tempQty+@Qty)
							  ,Rate=@Price
							  ,Nett=@Price*(@tempQty+@Qty)
							  ,ConvertFactor=@ConvertFactor
							  ,IsTax=@IsTax
							  ,TaxAmount=@TaxAmount
							  ,TaxPercentage=@TaxPercentage
							  ,SalesmanID=@SalesmanID
							  ,Salesman=@Salesman
							  ,CustomerID=@CustomerID
							  ,Customer=@Customer
							  ,IsStock=@IsStock
							  ,EndTime=cast(getdate() as time)
							  ,ExpiaryDate=@ExpiaryDate
							  ,RowNo=@RowNo
							  ,CustomerType=@CustomerType
							  ,ExchangeReasonID=@ExchangeReasonID
							  ,IsItemSeek=@IsItemSeek
							  ,GuidePersonID = @GuidePersonID
							  ,GuidePersonName = @GuidePersonName
							 Where ProductID=@ProductID And LocationID=@LocationID And 
		       Receipt=@Receipt And UnitNo=@UnitNo And DocumentID=@DocumentID And Price=@Price And
			   RefCode=@RefCode And BillTypeID=@BillTypeID And IsRecall=0 And UnitOfMeasureID=@UnitOfMeasureID And
			   IsSDis=0  AND IsPaid=0  And BatchNo=@BatchNo And SerialNo=@SerialNo And SaleTypeID=@SaleTypeID
			   And (IDiscount1=0 And IDiscount2=0 And IDiscount3=0 And IDiscount4=0 And IDiscount5=0 And IsSDis=0) And IsPromotion=@IsPromotion And IsPromotionApplied=0
			   And ProductColorSizeID=@ProductColorSizeID
			   


			   		
		 end

	 else
		begin

			select @RowNo=isnull(max((RowNo)),0) from TempItemDet Where LocationID=@LocationID And Receipt=@Receipt And UnitNo=@UnitNo
			
			IF @RowNo<@RowNoPayment
			BEGIN
				SET @RowNo=@RowNoPayment
				
			END
			set @RowNo=isnull(@RowNo,0)+1

			Insert Into TempItemDet
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
					  ,BaseUnitID
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
					  ,UnitNo
					  ,RowNo
					  ,TaxAmount
					  ,IsTax
					  ,TaxPercentage
					  ,IsStock
					  ,CustomerType
					  ,TransStatus
					  ,Ispromotion
					  ,PromotionID
					  ,ProductColorSizeID
					  ,ExchangeReasonID
					  ,IsItemSeek
					  ,GuidePersonID
					  ,GuidePersonName
			)
			Values
			(
					   @ProductID
					  ,@ProductCode
					  ,@RefCode
					  ,@BarCodeFull
					  ,@Descrip
					  ,@BatchNo
					  ,@SerialNo
					  ,@ExpiaryDate
					  ,@Cost
					  ,@Cost --AvgCost
					  ,@Price
					  ,@Qty
					  ,@Qty*@Price --Amount
					  ,@BaseUnitID
					  ,@UnitOfMeasureID
					  ,@UnitOfMeasureName
					  ,@ConvertFactor
					  ,@Qty*@Price
					  ,@Qty*@Price
					  ,@LocationID
					  ,@DocumentID
					  ,@BillTypeID
					  ,@SaleTypeID
					  ,@Receipt
					  ,@SalesmanID
					  ,@Salesman
					  ,@CustomerID
					  ,@Customer
					  ,@CashierID
					  ,@Cashier
					  ,cast(getdate() as time)
					  ,cast(getdate() as time)
					  ,cast(getdate() as date)
					  ,@UnitNo
					  ,@RowNo
					  ,@TaxAmount
					  ,@IsTax
					  ,@TaxPercentage
					  ,@IsStock
					  ,@CustomerType
					  ,@TransStatus
					  ,@IsPromotion 
					  ,@PromotionID
					  ,@ProductColorSizeID
					  ,@ExchangeReasonID
					  ,@IsItemSeek
					  ,@GuidePersonID
					  ,@GuidePersonName
			)
			
			set @tempFixedDisPer = @FixedDiscountPercentage
			set @tempFixedDisVal = @FixedDiscount;


			if(@FixedDiscountPercentage>0)
			begin
				set @FixedDiscount=(@Qty*@Price)*(@FixedDiscountPercentage/100)
			end
			else
			begin
			    set @FixedDiscount=(@Qty*@FixedDiscount)
				set @FixedDiscountPercentage=0
			end
			if(@FixedDiscount>0 and (@DocumentID in (1,2,3)))
			begin

			update TempItemDet set IDI1=6,IDis1=@FixedDiscountPercentage,IDiscount1=@FixedDiscount
			,Nett=Amount-(@FixedDiscount+IDiscount2+IDiscount3+IDiscount4+IDiscount5+sdiscount) ,Rate=Nett/Qty
			,IDI1CashierID=@CashierID,CustomerID=@CustomerID,CustomerType=@CustomerType ,isFixedDiscount=1
			Where LocationID=@LocationID And Receipt=@Receipt 
			And UnitNo=@UnitNo And DocumentID=@DocumentID And ProductID=@ProductID And RowNO=@RowNO
			
			end 

			--apply promotionid
			IF EXISTS (SELECT PromotionID FROM InvPromotionProductDis WHERE ProductID=@ProductID AND DiscountPercentage=@tempFixedDisPer AND DiscountValue=@tempFixedDisVal )
			BEGIN
			    
				set @PromotionID = (SELECT TOP 1 PromotionID FROM InvPromotionProductDis WHERE ProductID=@ProductID AND DiscountPercentage=@tempFixedDisPer AND DiscountValue=@tempFixedDisVal)

				update TempItemDet set PromotionID = @PromotionID,IsPromotion=1,isFixedDiscount=0
				Where LocationID=@LocationID And Receipt=@Receipt 
			    And UnitNo=@UnitNo And DocumentID=@DocumentID And ProductID=@ProductID And RowNO=@RowNO 
			    And ProductColorSizeID=@ProductColorSizeID

			END

		end

end

else

begin


	 if exists(select ProductCode from TempItemDet Where ProductID=@ProductID And LocationID=@LocationID And 
		       Receipt=@Receipt And UnitNo=@UnitNo And DocumentID=@DocumentID And Price=@Price And
			   RefCode=@RefCode And BillTypeID=@BillTypeID And IsRecall=0 And UnitOfMeasureID=@UnitOfMeasureID And
			   IsSDis=0 AND IsPaid=0  And BatchNo=@BatchNo And SerialNo=@SerialNo And ExpiaryDate=@ExpiaryDate And SaleTypeID=@SaleTypeID  AND Descrip=@Descrip
			   And (IDiscount1=0 And IDiscount2=0 And IDiscount3=0 And IDiscount4=0 And IDiscount5=0 And IsSDis=0) And IsPromotion=@IsPromotion And IsPromotionApplied=0
			   And ProductColorSizeID=@ProductColorSizeID) 
		 begin

			select @tempQty=Qty from TempItemDet Where ProductID=@ProductID And LocationID=@LocationID And 
		       Receipt=@Receipt And UnitNo=@UnitNo And DocumentID=@DocumentID And Price=@Price And
			   RefCode=@RefCode And BillTypeID=@BillTypeID And IsRecall=0 And UnitOfMeasureID=@UnitOfMeasureID And
			   IsSDis=0 AND IsPaid=0  And BatchNo=@BatchNo And SerialNo=@SerialNo And ExpiaryDate=@ExpiaryDate And SaleTypeID=@SaleTypeID
			   And (IDiscount1=0 And IDiscount2=0 And IDiscount3=0 And IDiscount4=0 And IDiscount5=0 And IsSDis=0) And IsPromotion=@IsPromotion And IsPromotionApplied=0
			   And ProductColorSizeID=@ProductColorSizeID
					


				--if(@SerialNo<>'' OR @SaleTypeID=2  OR @SaleTypeID=7)
				if(@SaleTypeID=2  OR @SaleTypeID=7)
				begin
					
					set @tempQty=0

				END
				
				select 
				No=max(isnull(RowNo,0)) from TempItemDet Where LocationID=@LocationID And Receipt=@Receipt And UnitNo=@UnitNo 
			
			IF @RowNo<@RowNoPayment
			BEGIN
				SET @RowNo=@RowNoPayment
				
			END
			set @RowNo=isnull(@RowNo,0)+1
			

						Update TempItemDet Set
							   Cost=@Cost
							  ,BarCodeFull=@BarCodeFull
							  ,Descrip=@Descrip
							  ,CashierID=@CashierID
							  ,Cashier=@Cashier
							  ,Qty=@tempQty+@Qty
							  ,Amount=@Price*(@tempQty+@Qty)
							  ,Rate=@Price
							  ,Nett=@Price*(@tempQty+@Qty)
							  ,ConvertFactor=@ConvertFactor
							  ,IsTax=@IsTax
							  ,TaxAmount=@TaxAmount
							  ,TaxPercentage=@TaxPercentage
							  ,SalesmanID=@SalesmanID
							  ,Salesman=@Salesman
							  ,CustomerID=@CustomerID
							  ,Customer=@Customer
							  ,IsStock=@IsStock
							  ,EndTime=cast(getdate() as time)
							  ,RowNo=@RowNo
							  ,CustomerType=@CustomerType
							  ,ExchangeReasonID=@ExchangeReasonID
							  ,IsItemSeek=@IsItemSeek
							  ,GuidePersonID = @GuidePersonID
							  ,GuidePersonName = @GuidePersonName
							 Where ProductID=@ProductID And LocationID=@LocationID And 
		       Receipt=@Receipt And UnitNo=@UnitNo And DocumentID=@DocumentID And Price=@Price And
			   RefCode=@RefCode And BillTypeID=@BillTypeID And IsRecall=0 And UnitOfMeasureID=@UnitOfMeasureID And
			   IsSDis=0 AND IsPaid=0  And BatchNo=@BatchNo And SerialNo=@SerialNo And ExpiaryDate=@ExpiaryDate And SaleTypeID=@SaleTypeID
			   And (IDiscount1=0 And IDiscount2=0 And IDiscount3=0 And IDiscount4=0 And IDiscount5=0 And IsSDis=0) And IsPromotion=@IsPromotion And IsPromotionApplied=0
			   And ProductColorSizeID=@ProductColorSizeID
			   		
		 end

	 else
		begin

			select @RowNo=max(isnull(RowNo,0)) from TempItemDet Where LocationID=@LocationID And Receipt=@Receipt And UnitNo=@UnitNo 
			
			IF @RowNo<@RowNoPayment
			BEGIN
				SET @RowNo=@RowNoPayment
				
			END
			set @RowNo=isnull(@RowNo,0)+1
			

			Insert Into TempItemDet
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
					  ,BaseUnitID
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
					  ,UnitNo
					  ,RowNo
					  ,TaxAmount
					  ,IsTax
					  ,TaxPercentage
					  ,IsStock
					  ,CustomerType
					  ,TransStatus
					  ,IsPromotion
					  ,PromotionID
					  ,ProductColorSizeID
					  ,ExchangeReasonID
					  ,IsItemSeek
					  ,GuidePersonID
					  ,GuidePersonName
			)
			Values
			(
					   @ProductID
					  ,@ProductCode
					  ,@RefCode
					  ,@BarCodeFull
					  ,@Descrip
					  ,@BatchNo
					  ,@SerialNo
					  ,@ExpiaryDate
					  ,@Cost
					  ,@Cost --AvgCost
					  ,@Price
					  ,@Qty
					  ,@Qty*@Price --Amount
					  ,@BaseUnitID
					  ,@UnitOfMeasureID
					  ,@UnitOfMeasureName
					  ,@ConvertFactor
					  ,@Qty*@Price
					  ,@Qty*@Price
					  ,@LocationID
					  ,@DocumentID
					  ,@BillTypeID
					  ,@SaleTypeID
					  ,@Receipt
					  ,@SalesmanID
					  ,@Salesman
					  ,@CustomerID
					  ,@Customer
					  ,@CashierID
					  ,@Cashier
					  ,cast(getdate() as time)
					  ,cast(getdate() as time)
					  ,cast(getdate() as date)
					  ,@UnitNo
					  ,@RowNo
					  ,@TaxAmount
					  ,@IsTax
					  ,@TaxPercentage
					  ,@IsStock
					  ,@CustomerType
					  ,@TransStatus
					  ,@Ispromotion
					  ,@PromotionID
					  ,@ProductColorSizeID
					  ,@ExchangeReasonID
					  ,@IsItemSeek
					  ,@GuidePersonID
					  ,@GuidePersonName
			)

			set @tempFixedDisPer = @FixedDiscountPercentage
			set	@tempFixedDisVal = @FixedDiscount;

			if(@FixedDiscountPercentage>0)
			begin
				set @FixedDiscount=(@Qty*@Price)*(@FixedDiscountPercentage/100)
			end
			else
			begin
			    set @FixedDiscount=(@Qty*@FixedDiscount)
				set @FixedDiscountPercentage=0
			end
			
			if(@FixedDiscount>0 and (@DocumentID in (1,2,3)))
			begin

			update TempItemDet set IDI1=6,IDis1=@FixedDiscountPercentage,IDiscount1=@FixedDiscount
			,Nett=Amount-(@FixedDiscount+IDiscount2+IDiscount3+IDiscount4+IDiscount5+sdiscount) ,Rate=Nett/Qty
			,IDI1CashierID=@CashierID,CustomerID=@CustomerID,CustomerType=@CustomerType ,isFixedDiscount=1
			Where LocationID=@LocationID And Receipt=@Receipt 
			And UnitNo=@UnitNo And DocumentID=@DocumentID And ProductID=@ProductID And RowNO=@RowNO 
			And ProductColorSizeID=@ProductColorSizeID

			end

			--apply promotionid
			IF EXISTS (SELECT PromotionID FROM InvPromotionProductDis WHERE ProductID=@ProductID AND DiscountPercentage=@tempFixedDisPer AND DiscountValue=@tempFixedDisVal )
			BEGIN
			    
				set @PromotionID = (SELECT TOP 1 PromotionID FROM InvPromotionProductDis WHERE ProductID=@ProductID AND DiscountPercentage=@tempFixedDisPer AND DiscountValue=@tempFixedDisVal)

				update TempItemDet set PromotionID = @PromotionID,IsPromotion=1,isFixedDiscount=0
				Where LocationID=@LocationID And Receipt=@Receipt 
			    And UnitNo=@UnitNo And DocumentID=@DocumentID And ProductID=@ProductID And RowNO=@RowNO 
			    And ProductColorSizeID=@ProductColorSizeID

			END

		end
end
end
							
	 exec spPromotionProductDiscount @LocationID,@UnitNo,@Receipt,@CashierID																
--select * from TempReadPromotionDetails								
																	
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
	
