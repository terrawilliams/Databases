/* #1 */
SELECT      CONVERT(VARCHAR, OrderDate, 101) OrderDate,
            OrderID                     OrderNumber,
            TblCustomer.LastName + ', ' +
            LEFT(TblCustomer.FirstName, 1) + '.' CustomerName,
            '(' + LEFT(TblCustomer.Phone, 3) + ') ' +
            LEFT(TblCustomer.Phone, 3) + '-' +
            LEFT(TblCustomer.Phone, 4)  CustomerTelephone
FROM TblOrder
LEFT OUTER JOIN TblCustomer
ON TblOrder.CustomerID = TblCustomer.CustomerID
WHERE MONTH(OrderDate) = 2 AND YEAR(OrderDate) = YEAR(GETDATE())
ORDER BY 1 DESC;

/* #2 */
SELECT      CONVERT(VARCHAR, OrderDate, 101)                        OrderDate,
            TOL.OrderID                                             OrderNumber,
            TblCustomer.LastName + ', ' +
            LEFT(TblCustomer.FirstName, 1) + '.'                    CustomerName,
            '(' + LEFT(TblCustomer.Phone, 3) + ') ' +
            LEFT(TblCustomer.Phone, 3) + '-' +
            LEFT(TblCustomer.Phone, 4)                              CustomerTelephone,
            TOL.ItemID                                              ItemID,
            TOL.Quantity                                            Quantity,
            CONVERT(DECIMAL(10, 2), TOL.Price)                      Price,
            CONVERT(DECIMAL(10, 2), (TOL.Quantity * TOL.Price))     ExtendedPrice
FROM TblOrder
LEFT OUTER JOIN TblCustomer
ON TblOrder.CustomerID = TblCustomer.CustomerID
LEFT OUTER JOIN TblOrderLine AS TOL
ON TblOrder.OrderID = TOL.OrderID
WHERE MONTH(OrderDate) = 2 AND YEAR(OrderDate) = YEAR(GETDATE())
ORDER BY 1 DESC;

/* #3 */
SELECT      CONVERT(VARCHAR, OrderDate, 101)                        OrderDate,
            TOL.OrderID                                             OrderNumber,
            TblCustomer.LastName + ', ' +
            LEFT(TblCustomer.FirstName, 1) + '.'                    CustomerName,
            '(' + LEFT(TblCustomer.Phone, 3) + ') ' +
            LEFT(TblCustomer.Phone, 3) + '-' +
            LEFT(TblCustomer.Phone, 4)                              CustomerTelephone,
            TOL.ItemID                                              ItemID,
            ITEM.Description                                        ItemDescription,
            TOL.Quantity                                            Quantity,
            CONVERT(DECIMAL(10, 2), TOL.Price)                      Price,
            CONVERT(DECIMAL(10, 2), (TOL.Quantity * TOL.Price))     ExtendedPrice
FROM TblOrder
LEFT OUTER JOIN TblCustomer
ON TblOrder.CustomerID = TblCustomer.CustomerID
LEFT OUTER JOIN TblOrderLine AS TOL
ON TblOrder.OrderID = TOL.OrderID
LEFT OUTER JOIN TblItem ITEM
ON TOL.ItemID = ITEM.ItemID
WHERE MONTH(OrderDate) = 2 AND YEAR(OrderDate) = YEAR(GETDATE())
ORDER BY 1 DESC;

/* #4 */
SELECT      CONVERT(VARCHAR, OrderDate, 101)                        OrderDate,
            TOL.OrderID                                             OrderNumber,
            TblCustomer.LastName + ', ' +
            LEFT(TblCustomer.FirstName, 1) + '.'                    CustomerName,
            '(' + LEFT(TblCustomer.Phone, 3) + ') ' +
            LEFT(TblCustomer.Phone, 3) + '-' +
            LEFT(TblCustomer.Phone, 4)                              CustomerTelephone,
            TOL.ItemID                                              ItemID,
            TI.Description                                          ItemDescription,
            TIType.CategoryDescription                              CategoryDescription,
            TOL.Quantity                                            Quantity,
            CONVERT(DECIMAL(10, 2), TOL.Price)                      Price,
            CONVERT(DECIMAL(10, 2), (TOL.Quantity * TOL.Price))     ExtendedPrice
FROM TblOrder
LEFT OUTER JOIN TblCustomer
ON TblOrder.CustomerID = TblCustomer.CustomerID
LEFT OUTER JOIN TblOrderLine AS TOL
ON TblOrder.OrderID = TOL.OrderID
LEFT OUTER JOIN TblItem TI
ON TOL.ItemID = TI.ItemID
LEFT OUTER JOIN TblItemType TIType
ON TIType.TypeID = TI.TypeID
WHERE MONTH(OrderDate) = 2 AND YEAR(OrderDate) = YEAR(GETDATE())
ORDER BY 1 DESC;

/* #5 */
SELECT      CONVERT(VARCHAR, OrderDate, 101)                        OrderDate,
            TOL.OrderID                                             OrderNumber,
            TblCustomer.LastName + ', ' +
            LEFT(TblCustomer.FirstName, 1) + '.'                    CustomerName,
            '(' + LEFT(TblCustomer.Phone, 3) + ') ' +
            LEFT(TblCustomer.Phone, 3) + '-' +
            LEFT(TblCustomer.Phone, 4)                              CustomerTelephone,
            TOL.ItemID                                              ItemID,
            TI.Description                                          ItemDescription,
            TIType.CategoryDescription                              CategoryDescription,
            TOL.Quantity                                            Quantity,
            CONVERT(DECIMAL(10, 2), TOL.Price)                      Price,
            CONVERT(DECIMAL(10, 2), (TOL.Quantity * TOL.Price))     ExtendedPrice,
            CASE
                WHEN TR.OrderID = TOL.OrderID AND TR.ItemID = TOL.ItemID
                    THEN 'Yes'
                ELSE
                    'No'
            END     'ReviewExists?'
FROM TblOrder
LEFT OUTER JOIN TblCustomer
ON TblOrder.CustomerID = TblCustomer.CustomerID
LEFT OUTER JOIN TblOrderLine AS TOL
ON TblOrder.OrderID = TOL.OrderID
LEFT OUTER JOIN TblItem TI
ON TOL.ItemID = TI.ItemID
LEFT OUTER JOIN TblItemType TIType
ON TIType.TypeID = TI.TypeID
LEFT OUTER JOIN tblReview TR
ON TR.OrderID = TOL.OrderID AND TR.ItemID = TOL.ItemID
WHERE MONTH(OrderDate) = 2 AND YEAR(OrderDate) = YEAR(GETDATE())
ORDER BY 1 DESC;

/* #6 */
SELECT      DISTINCT TblItem.ItemID                             ItemID,
            Description                                         ItemDescription,
            SUM(Quantity)                                       TotalQtySold,
            (SELECT COUNT(*)
                    FROM TblOrderLine AS OrderLine
                    WHERE OrderLine.ItemID = TblItem.ItemID
                    GROUP BY OrderLine.ItemID)                  CountOfOrderLines,
            CONVERT(DECIMAL(10, 2), ListPrice)                  ListPrice,
            CONVERT(DECIMAL(10, 2), (SELECT MIN(Price)))        MinimumPrice,
            CONVERT(DECIMAL(10, 2), (SELECT MAX(Price)))        MaxPrice,
            CONVERT(DECIMAL(10, 2), (SELECT AVG(Price)))        AvgPrice
FROM TblItem
INNER JOIN TblOrderLine TOL
ON TblItem.ItemID = TOL.ItemID
GROUP BY TblItem.ItemID, Description, ListPrice
ORDER BY TblItem.ItemID;

/* #7 */
SELECT      DISTINCT TblItem.ItemID                                 ItemID,
            Description                                             ItemDescription,
            ISNULL(SUM(Quantity), 0)                                TotalQtySold,
            ISNULL((SELECT COUNT(*)
                    FROM TblOrderLine AS OrderLine
                    WHERE OrderLine.ItemID = TblItem.ItemID
                    GROUP BY OrderLine.ItemID), 0)                  CountOfOrderLines,
            CONVERT(DECIMAL(10, 2), ListPrice)                      ListPrice,
            CONVERT(DECIMAL(10, 2), ISNULL((SELECT MIN(Price)), 0)) MinimumPrice,
            CONVERT(DECIMAL(10, 2), ISNULL((SELECT MAX(Price)), 0)) MaximumPrice,
            CONVERT(DECIMAL(10, 2), ISNULL((SELECT AVG(Price)), 0)) AvgPrice
FROM TblItem
LEFT OUTER JOIN TblOrderLine TOL
ON TblItem.ItemID = TOL.ItemID
GROUP BY TblItem.ItemID, Description, ListPrice
ORDER BY TblItem.ItemID;
