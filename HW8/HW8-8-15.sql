/* #8 */
SELECT      TblItem.ItemID,
            TblItem.Description,
            ISNULL(CONVERT(VARCHAR, TblItemCostHistory.LastCostDate, 107), 'No Date Recorded')  LastCostDate,
            ISNULL(TblItemCostHistory.LastCost, 0)                                              LastCost
FROM        TblItem
LEFT JOIN   TblItemCostHistory
ON          TblItem.ItemID = TblItemCostHistory.ItemID
ORDER BY    TblItem.ItemID ASC, TblItemCostHistory.LastCostDate DESC;

/* #9 */
SELECT      TblItem.ItemID,
            TblItem.Description,
            ISNULL(CONVERT(VARCHAR, historyOuter.LastCostDate, 107), 'No Date Recorded')  LastCostDate,
            ISNULL(historyOuter.LastCost, 0) LastCost
FROM        TblItem
LEFT JOIN   TblItemCostHistory  historyOuter ON TblItem.ItemID = historyOuter.ItemID
WHERE       LastCostDate =
            (SELECT MAX(historyInner.LastCostDate)
                FROM TblItem itemInner
                LEFT OUTER JOIN TblItemCostHistory historyInner
                ON itemInner.ItemID = historyInner.ItemID
                WHERE historyOuter.ItemID = historyInner.ItemID
                GROUP BY historyInner.ItemID)
ORDER BY    TblItem.ItemID ASC;

SELECT i.ItemID,
       i.Description,
       ISNULL(CONVERT(VARCHAR, MAX(it.LastCostDate), 107), 'No Date Recorded') AS 'Last Cost Date',
       ISNULL((SELECT TOP 1 innerHistory.LastCost
             FROM TblItemCostHistory AS innerHistory
            WHERE innerHistory.ItemID = i.ItemID
            ORDER BY innerHistory.LastCostDate DESC), 0) AS 'Last Cost Paid'
FROM TblItem as i
LEFT JOIN TblItemCostHistory AS it ON it.ItemID = i.ItemID
GROUP BY i.ItemID, i.Description;

/* #10 */
SELECT i.ItemID,
       i.Description,
       type.CategoryDescription,
       ISNULL(CONVERT(VARCHAR, MAX(it.LastCostDate), 107), 'No Date Recorded') AS 'Last Cost Date',
       ISNULL((SELECT COUNT(*)
           FROM TblItemCostHistory AS countHist
           WHERE countHist.ItemID = i.ItemID
            GROUP BY countHist.ItemID), 0)  CountOfPurchases,
       ISNULL((SELECT TOP 1 innerHistory.LastCost
             FROM TblItemCostHistory AS innerHistory
            WHERE innerHistory.ItemID = i.ItemID
            ORDER BY innerHistory.LastCostDate DESC), 0) AS 'Last Cost Paid',
       ISNULL((SELECT AVG(avgHistory.LastCost)
           FROM TblItemCostHistory avgHistory
           WHERE avgHistory.ItemID = i.ItemID
           GROUP BY avgHistory.ItemID), 0) AverageLastCost
FROM TblItem as i
LEFT JOIN TblItemCostHistory AS it ON it.ItemID = i.ItemID
LEFT JOIN tblItemType AS type ON i.TypeID = type.TypeID
GROUP BY i.ItemID, i.Description, type.CategoryDescription;

/* #11 */
SELECT         TblOrder.OrderID,
               LastName + ', ' + SUBSTRING(FirstName, 1, 1) + '.'  CustomerName,
               '(' + SUBSTRING(Phone, 1, 3) + ') '
                    + SUBSTRING(Phone, 4, 3) + '-'
                    + SUBSTRING(Phone, 7, 4)                       CustomerTelephone,
               ItemID,
               CASE
                WHEN TblOrderLine.AddressID IS NOT NULL
                    THEN OrderlineAddress.ShipAddress
                WHEN TblOrder.AddressID IS NOT NULL
                    THEN OrderAddress.ShipAddress
                ELSE
                    TblCustomer.Address
                END                                                 ShipAddress,
               CASE
                WHEN TblOrderLine.AddressID IS NOT NULL
                    THEN OrderlineAddress.ShipPostalCode
                WHEN TblOrder.AddressID IS NOT NULL
                    THEN OrderAddress.ShipPostalCode
                ELSE
                    TblCustomer.Zip
                END                                                 ShipCode,
               CASE
                WHEN TblOrderLine.AddressID IS NOT NULL
                    THEN OrderlineAddress.ShipCountry
                WHEN TblOrder.AddressID IS NOT NULL
                    THEN OrderAddress.ShipCountry
                ELSE
                    TblCustomer.Country
                END                                                 ShipCountry,
                Quantity
FROM            TblOrder
LEFT OUTER JOIN TblOrderLine
ON              TblOrder.OrderID = TblOrderLine.OrderID
LEFT OUTER JOIN TblCustomer
ON              TblOrder.CustomerID = TblCustomer.CustomerID
LEFT OUTER JOIN TblShipAddress AS OrderlineAddress
ON              TblOrderLine.AddressID = OrderlineAddress.AddressID
LEFT OUTER JOIN TblShipAddress  AS OrderAddress
ON              TblOrder.AddressID = OrderAddress.AddressID
WHERE           MONTH(OrderDate) = 2 and YEAR(OrderDate) = YEAR(GETDATE())
ORDER BY        OrderID;

/* #12 */
SELECT  TblOrderLine.OrderID    OrderID,
        TblOrderLine.ItemID ItemID,
        Price,
        Quantity,
        ISNULL(SUM(QtyShipped), 0) TotalQuantityShipped,
        Quantity - ISNULL(SUM(QtyShipped), 0)    LeftToShip
FROM    TblOrderLine
LEFT OUTER JOIN TblShipLine
ON TblOrderLine.OrderID = TblShipLine.OrderID AND TblOrderLine.ItemID = TblShipLine.ItemID
GROUP BY TblOrderLine.OrderID, TblOrderLine.ItemID, Price, Quantity;

/* #13 */
SELECT  TblOrderLine.OrderID    OrderID,
        TblOrderLine.ItemID ItemID,
        Description ItemDescription,
        CategoryDescription,
        ListPrice,
        Price,
        Quantity,
        ISNULL(SUM(QtyShipped), 0) TotalQuantityShipped,
        Quantity - ISNULL(SUM(QtyShipped), 0)    LeftToShip
FROM    TblOrderLine
LEFT OUTER JOIN TblShipLine
ON  TblOrderLine.OrderID = TblShipLine.OrderID AND TblOrderLine.ItemID = TblShipLine.ItemID
LEFT OUTER JOIN TblItem
ON  TblOrderLine.ItemID = TblItem.ItemID
INNER JOIN tblItemType
ON  TblItem.TypeID = tblItemType.TypeID
GROUP BY TblOrderLine.OrderID, TblOrderLine.ItemID, Description, CategoryDescription, ListPrice, Price, Quantity;

/* #14 */
SELECT  TblOrderLine.OrderID    OrderID,
        LastName + ', ' + FirstName CustomerName,
        CASE
            WHEN TblOrderLine.AddressID IS NOT NULL
                THEN OrderLineAddress.ShipName
            WHEN TblOrder.AddressID IS NOT NULL
                THEN OrderAddress.ShipName
            ELSE LastName + ', ' + FirstName
        END                                         ShippingName,
        TblOrderLine.ItemID ItemID,
        Description ItemDescription,
        CategoryDescription,
        ListPrice,
        Price,
        Quantity,
        ISNULL(SUM(QtyShipped), 0) TotalQuantityShipped,
        Quantity - ISNULL(SUM(QtyShipped), 0)    LeftToShip
FROM    TblOrderLine
LEFT OUTER JOIN TblShipLine
ON  TblOrderLine.OrderID = TblShipLine.OrderID AND TblOrderLine.ItemID = TblShipLine.ItemID
LEFT OUTER JOIN TblItem
ON  TblOrderLine.ItemID = TblItem.ItemID
INNER JOIN tblItemType
ON  TblItem.TypeID = tblItemType.TypeID
INNER JOIN  TblOrder
ON TblOrderLine.OrderID = TblOrder.OrderID
INNER JOIN TblCustomer
ON TblOrder.CustomerID = TblCustomer.CustomerID
LEFT OUTER JOIN TblShipAddress OrderLineAddress
ON TblOrderLine.AddressID = OrderLineAddress.AddressID
LEFT OUTER JOIN TblShipAddress OrderAddress
ON TblOrder.AddressID = OrderAddress.AddressID
GROUP BY TblOrderLine.OrderID, LastName, FirstName,
         OrderLineAddress.ShipName, TblOrderLine.AddressID,
         OrderAddress.ShipName, TblOrder.AddressID,
         TblOrderLine.ItemID, Description, CategoryDescription,
         ListPrice, Price, Quantity;

/* #15 */
SELECT  LastName + ', ' + FirstName CustomerName,
        TblOrder.OrderID    OrderID,
        TblOrderLine.ItemID,
        Description
FROM    TblOrderLine
LEFT OUTER JOIN TblOrder
ON TblOrderLine.OrderID = TblOrder.OrderID
LEFT OUTER JOIN TblCustomer
ON TblOrder.CustomerID = TblCustomer.CustomerID
LEFT OUTER JOIN TblItem
ON TblOrderLine.ItemID = TblItem.ItemID
LEFT OUTER JOIN TblShipLine
ON TblOrderLine.OrderID = TblShipLine.OrderID and TblOrderLine.ItemID = TblShipLine.ItemID
WHERE MethodShipped = 'fedex'
ORDER BY CustomerName;