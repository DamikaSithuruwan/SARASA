USE [ERP]
GO
/****** Object:  StoredProcedure [dbo].[spLoyaltyBirthdayDetailsUpdate]    Script Date: 2023-12-28 03:42:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--By Pravin
----23/10/2013
--spUpdateLoyaltyDetails 290832,1,'0001',0,5,1,1,1,0,0,0,0,0286579,1,0,0,2,0
create PROCEDURE [dbo].[spLoyaltyPromotionDetailsUpdate]
    @CustomerID BIGINT ,
    @Receipt CHAR(12) ,
    @Amount DECIMAL(18, 4) ,
    @LocationID INT ,
    @UnitNo INT ,
    @CashierID BIGINT ,
    @DiscPer DECIMAL(18, 4) ,
    @DiscAmt DECIMAL(18, 4) ,
    @Zno BIGINT ,
    @PromotionID BIGINT
AS --delete  from TempItemDet
	 --select * from TempItemDet
	
	
	DECLARE @UserName VARCHAR(50)
			,@DOB DATETIME

    SET NOCOUNT ON

    BEGIN TRY
        BEGIN TRANSACTION

		
		BEGIN
		  INSERT  INTO InvLoyaltyPromotionTransaction
									( [CustomerID] ,
									  [Receipt] ,
									  [Amount] ,
									  [LocationID] ,
									  [UnitNo] ,
									  [CashierID] ,
									  [DiscPer] ,
									  [DiscAmt] ,
									  [Zno] ,
									  [DocumentDate] ,
									  [PromotionID]
	  
									)
							VALUES  ( @CustomerID ,
									  @Receipt ,
									  @Amount ,
									  @LocationID ,
									  @UnitNo ,
									  @CashierID ,
									  @DiscPer ,
									  @DiscAmt ,
									  @Zno ,
									  GETDATE() ,
									  @PromotionID
									)

		END
	--select * from InvLoyaltyBirthDayTransaction
        COMMIT TRANSACTION;
        SELECT  '0' AS Result
    END TRY
  
    BEGIN CATCH
        IF @@TRANCOUNT > 0 
            BEGIN
                ROLLBACK TRANSACTION
                SELECT  ERROR_MESSAGE() AS Result

            END
        ELSE 
            BEGIN
                SELECT  ERROR_MESSAGE() AS Result
            END
    END CATCH
