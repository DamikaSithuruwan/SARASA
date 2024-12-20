USE [easyway]
GO
/****** Object:  StoredProcedure [dbo].[Sp_GetInvoice]    Script Date: 2024-06-28 11:26:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[Sp_GetInvoice]  --'Ly3VHBlDfoG9VmzecYoQZJFXFdKvqu'
    @InvoiceNo      varchar(50)
AS
BEGIN
DECLARE @NoofPieces	decimal(14,2)
DECLARE @NoofItems	int

select @NoofPieces= ISNULL(Sum(CASE WHEN Iid='001' Or Iid='003' Then Qty  Else 0 End),0),@NoofItems=ISNULL(COUNT(1),0) from tbPosTransact where Status=1 And SaleType='S' And Upload = 'O' And (Iid='001' Or Iid='003') And InvoiceNo=@InvoiceNo

Select  top 1 Head1,Head2,Head3,Head4,Head5,Head6,Head7,Head8,Head9,Head10,  t.Receipt, t.Loca, t.UnitNo, t.RecDate, t.Cashier, t.Salesman, t.Cust Customer, t.StartTime, t.EndTime, Tail1, Tail2, Tail3, Tail4, Tail5, Tail6, Tail7, Tail8, Tail9, Tail10, ISNULL(Sum(CASE WHEN Iid='006' Then Nett  Else 0 End),0) SubTotalDiscount, 0 CompanyId,@NoofItems NoOfItems,@NoofPieces NoOfPieces  FROM tbPostransact t join tbSystemPos s on t.Loca=s.Loca Where  Status=1 And SaleType='S' And Upload = 'O' And InvoiceNo=@InvoiceNo  and s.Loca=(select top 1 Loca from tbPosPayment where InvoiceNo=@InvoiceNo)
--Cast(t.RecDate As Date) Between '2020-02-14' And '2020-02-14' And t.Receipt='20000022'  and t.Zno='728' And t.UnitNo='1'
group by  Head1,Head2,Head3,Head4,Head5,Head6,Head7,Head8,Head9,Head10,  t.Receipt, t.Loca, t.UnitNo, t.RecDate, t.Cashier, t.Salesman, t.Cust , t.StartTime, t.EndTime, Tail1, Tail2, Tail3, Tail4, Tail5, Tail6, Tail7, Tail8, Tail9, Tail10

SELECT ISNULL(Sum(CASE WHEN Iid='001' Or Iid='003' Then Nett When Iid='002' Or Iid='004' Or Iid='006' Then -Nett  Else 0 End),0) Nett,
Rtrim(ItemCode) ItemCode, RefCode, (CASE When Iid='002' Then Rtrim(Descrip) + '  (Exch.)'  Else Rtrim(Descrip) End)  Descrip, Price, Qty, 
ISNULL(Sum(CASE WHEN Iid='001' Or Iid='003' Then Amount When Iid='002' Or Iid='004' Or Iid='006' Then -Amount  Else 0 End),0) Amount
, IDI1 Discount1, IDis1, IDiscount1, IDI2 Discount2, IDis2, IDiscount2, IDI3 Discount3, IDis3, IDiscount3, IDI4 Discount4, IDis4, IDiscount4,IDI5 Discount5, IDis5, IDiscount5  FROM tbPosTransact Where Status=1 And SaleType='S' And Upload = 'O' And  InvoiceNo=@InvoiceNo
group by ItemCode, RefCode, Descrip, Price, Qty, Amount, IDI1, IDis1, IDiscount1, IDI2, IDis2, IDiscount2, IDI3, IDis3, IDiscount3, IDI4, IDis4, IDiscount4, IDI5, IDis5, IDiscount5,IId

SELECT ISNULL(SUM(Amount),0) Amount,SerialNo,Descrip PayType FROM tbPosPayment p join tbPayTypePos t on p.TypeId=t.Code  Where PStatus='S' And CustType<>'S'  And Upload = 'O' and  InvoiceNo=@InvoiceNo
--Cast(SDate As Date) Between '2020-02-14' And '2020-02-14' And Receipt='20000022' And  Zno='728' And UnitNo='1'  
Group by SerialNo,Descrip

select CustCode CustomerCode,CustName CustomerName, Sum(Points) EarnedPoints,0 TotalPoints, 0 ExpiryPoints from tb_LoyaltyDet Where  InvoiceNo=@InvoiceNo
--Cast(SDate As Date) Between '2020-02-14' And '2020-02-14' And Receipt='20000022' And UnitNo='1'
group by CustCode,CustName


END
