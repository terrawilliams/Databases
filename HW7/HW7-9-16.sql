/* #9 */
SELECT ROUND(AVG(CONVERT(decimal, QtyShipped)), 2)  AverageQuantityShipped
FROM TblShipLine
WHERE UPPER(MethodShipped) = UPPER('fedex');

/* #10 */
SELECT ItemID           itemid,
       COUNT(*)         NumberofRows,
        SUM(Quantity)   QuantitySold,
       MIN(Price)       MinimumPrice,
       MAX(Price)       MaximumPrice,
       AVG(Price)       AveragePrice
FROM TblOrderLine
GROUP BY ItemID
ORDER BY ItemID;

/* #11 */
SELECT ItemID                                                                           itemid,
        COUNT(*)                                                                        NumberofRows,
        SUM(Quantity)                                                                   QuantitySold,
        MIN(Price)                                                                      MinimumPrice,
        MAX(Price)                                                                      MaximumPrice,
        AVG(Price)                                                                      AveragePrice,
        CONCAT(CONVERT(varchar, ((MAX(Price) - MIN(Price)) / MIN(Price)) * 100), '%')   Diff
FROM TblOrderLine
GROUP BY ItemID
HAVING ((MAX(Price) - MIN(Price)) / MIN(Price)) * 100 > 50
ORDER BY ItemID;

/* #12 */
SELECT OrderID,
       ItemID,
       COUNT(*)         NumberOfShipments,
       SUM(QtyShipped)  TotalShipped
FROM TblShipLine
GROUP BY OrderID, ItemID
HAVING COUNT(*) > 1
ORDER BY OrderID;

/* #13 */
SELECT OrderID                                              OrderNumber,
       CustomerID                                           CustomerNumber,
       CONVERT(varchar, OrderDate, 107)                     DateOrdered,
       CONVERT(varchar, DATEADD(dd, 50, OrderDate), 107)    '50 Days After Date Ordered',
       DATEDIFF(dd, OrderDate, GETDATE())                   NumberOfDaysDifference,
       GETDATE()                                            CurrentDateAndTime
FROM TblOrder
WHERE DATEDIFF(dd, OrderDate, GETDATE()) > 50;

/* #14 */
SELECT CustomerID,
       LastName + ', ' + SUBSTRING(FirstName, 1, 1) + '.'   CustomerName,
       '(' + SUBSTRING(Phone, 1, 3) + ') '
           + SUBSTRING(Phone, 4, 3) + '-'
           + SUBSTRING(Phone, 7, 4)                         PhoneNumber,
       UPPER(City)                                          City,
       UPPER(State)                                         State
FROM TblCustomer
WHERE CustomerID NOT IN
        (SELECT CustomerID
         FROM TblOrder);

/* #15 */
SELECT CustomerID,
       LastName + ', ' + SUBSTRING(FirstName, 1, 1) + '.'                                           CustomerName,
       '(' + SUBSTRING(Phone, 1, 3) + ') '
           + SUBSTRING(Phone, 4, 3) + '-'
           + SUBSTRING(Phone, 7, 4)  PhoneNumber,
       UPPER(City)                                                                                  City,
       UPPER(State)                                                                                 State,
       CONVERT(VARCHAR, FirstBuyDate, 107)                                                          FirstPurchaseDate
FROM TblCustomer
WHERE FirstBuyDate =
        (SELECT MAX(FirstBuyDate)
            FROM TblCustomer);

/* #16 */
SELECT ItemID,
       Description,
       ListPrice
FROM TblItem
WHERE ItemID IN
        (SELECT DISTINCT ItemID
            FROM tblReview);