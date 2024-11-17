1. █ find the Location ID

2. █ • use select query and check - DuplicateTransactionDet.sql 
   ( put the relevant date and Location ID )

     • comment select part and uncomment delete part
     • run with delete part to remove duplicates in TransactionDet

3.  █ • use select query and check - DuplicatePaymentDet.sql
   ( put the relevant date and Location ID )

     • comment select part and uncomment delete part
     • run with delete part to remove duplicates in PaymentDet


4. █ Please run the dayend job for remove date 

  eg:- Exec DayEnd '2022-12-08' 
