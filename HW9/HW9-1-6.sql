/* 1 */
UPDATE TblShipLine
SET MethodShipped = LOWER(MethodShipped);

UPDATE TblCustomer
SET State = UPPER(State);

DELETE FROM TblOrder
WHERE OrderID NOT IN
        (SELECT OrderID
            FROM TblOrderLine
            GROUP BY OrderID);

/* 2 */
CREATE VIEW ShippedSummary AS
SELECT OrderID ShippedOrderID,
       ItemID ShippedItemID,
       SUM(QtyShipped) TotalShipped
FROM TblShipLine
GROUP BY ItemID, OrderID;

SELECT orderLine.OrderID,
       CONVERT(VARCHAR, OrderDate, 107) OrderDate,
       LastName + ', ' + SUBSTRING(FirstName, 1, 1) + '.' CustomerName,
       orderLine.ItemID,
       Description ItemDescription,
       Quantity QuantityOrdered,
        ISNULL((SELECT TotalShipped
            FROM ShippedSummary
            WHERE orderLine.OrderID = ShippedSummary.ShippedOrderID
            AND orderLine.ItemID = ShippedSummary.ShippedItemID), 0) TotalShipped,
       Quantity - ISNULL((SELECT TotalShipped
            FROM ShippedSummary
            WHERE orderLine.OrderID = ShippedSummary.ShippedOrderID
            AND orderLine.ItemID = ShippedSummary.ShippedItemID), 0) QuantityRemaining,
       CASE
            WHEN (ISNULL((SELECT TotalShipped
                    FROM ShippedSummary
                    WHERE orderLine.OrderID = ShippedSummary.ShippedOrderID
                    AND orderLine.ItemID = ShippedSummary.ShippedItemID), 0)) = 0
            THEN 'Not Shipped'
            WHEN (Quantity - ISNULL((SELECT TotalShipped
                    FROM ShippedSummary
                    WHERE orderLine.OrderID = ShippedSummary.ShippedOrderID
                    AND orderLine.ItemID = ShippedSummary.ShippedItemID), 0)) = 0
            THEN 'Completely Shipped'
            WHEN (Quantity - ISNULL((SELECT TotalShipped
                    FROM ShippedSummary
                    WHERE orderLine.OrderID = ShippedSummary.ShippedOrderID
                    AND orderLine.ItemID = ShippedSummary.ShippedItemID), 0)) < 0
            THEN 'Over Shipped'
            ELSE 'Partially Shipped'
        END     ShippingStatus

FROM TblOrderLine orderLine
INNER JOIN TblOrder
ON orderLine.OrderID = TblOrder.OrderID
INNER JOIN TblCustomer
ON TblOrder.CustomerID = TblCustomer.CustomerID
INNER JOIN TblItem
ON orderLine.ItemID = TblItem.ItemID;

/* 3 */
SELECT orderLine.OrderID,
       CONVERT(VARCHAR, OrderDate, 107) OrderDate,
       LastName + ', ' + SUBSTRING(FirstName, 1, 1) + '.' CustomerName,
       orderLine.ItemID,
       Description ItemDescription,
       Quantity QuantityOrdered,
        ISNULL((SELECT TotalShipped
            FROM ShippedSummary
            WHERE orderLine.OrderID = ShippedSummary.ShippedOrderID
            AND orderLine.ItemID = ShippedSummary.ShippedItemID), 0) TotalShipped,
       Quantity - ISNULL((SELECT TotalShipped
            FROM ShippedSummary
            WHERE orderLine.OrderID = ShippedSummary.ShippedOrderID
            AND orderLine.ItemID = ShippedSummary.ShippedItemID), 0) QuantityRemaining,
       CASE
            WHEN (ISNULL((SELECT TotalShipped
                    FROM ShippedSummary
                    WHERE orderLine.OrderID = ShippedSummary.ShippedOrderID
                    AND orderLine.ItemID = ShippedSummary.ShippedItemID), 0)) = 0
            THEN 'Not Shipped'
            WHEN (Quantity - ISNULL((SELECT TotalShipped
                    FROM ShippedSummary
                    WHERE orderLine.OrderID = ShippedSummary.ShippedOrderID
                    AND orderLine.ItemID = ShippedSummary.ShippedItemID), 0)) = 0
            THEN 'Completely Shipped'
            WHEN (Quantity - ISNULL((SELECT TotalShipped
                    FROM ShippedSummary
                    WHERE orderLine.OrderID = ShippedSummary.ShippedOrderID
                    AND orderLine.ItemID = ShippedSummary.ShippedItemID), 0)) < 0
            THEN 'Over Shipped'
            ELSE 'Partially Shipped'
        END     ShippingStatus

FROM TblOrderLine orderLine
INNER JOIN TblOrder
ON orderLine.OrderID = TblOrder.OrderID
INNER JOIN TblCustomer
ON TblOrder.CustomerID = TblCustomer.CustomerID
INNER JOIN TblItem
ON orderLine.ItemID = TblItem.ItemID
WHERE (Quantity - ISNULL((SELECT TotalShipped
                    FROM ShippedSummary
                    WHERE orderLine.OrderID = ShippedSummary.ShippedOrderID
                    AND orderLine.ItemID = ShippedSummary.ShippedItemID), 0)) < 0;

/* 4 */
CREATE VIEW NotCompletelyShipped AS
SELECT orderLine.OrderID
FROM TblOrderLine orderLine
INNER JOIN TblOrder
ON orderLine.OrderID = TblOrder.OrderID
WHERE (Quantity - ISNULL((SELECT TotalShipped
                    FROM ShippedSummary
                    WHERE orderLine.OrderID = ShippedSummary.ShippedOrderID
                    AND orderLine.ItemID = ShippedSummary.ShippedItemID), 0)) > 0;

SELECT OrderID,
       CONVERT(VARCHAR, OrderDate, 107) DateOrdered,
       TblOrder.CustomerID,
       customer.LastName + ', ' + customer.FirstName CustomerName,
       SUBSTRING(customer.Phone, 1, 3) + '-' +
            SUBSTRING(customer.Phone, 4, 3) + '-' +
            SUBSTRING(customer.Phone, 7, 4) CustomerPhone,
       UPPER(customer.City) + ', ' + customer.State Location,
       affiliated.CustomerID    AffiliatedCustID,
       affiliated.LastName + ', ' + affiliated.FirstName AffiliatedCustomerName,
       SUBSTRING(affiliated.Phone, 1, 3) + '-' +
            SUBSTRING(affiliated.Phone, 4, 3) + '-' +
            SUBSTRING(affiliated.Phone, 7, 4) AffiliatedCustomerPhone
FROM TblOrder
INNER JOIN TblCustomer customer
ON TblOrder.CustomerID = customer.CustomerID
LEFT JOIN TblCustomer affiliated
ON customer.CustomerAffID = affiliated.CustomerID
WHERE OrderID IN
      (SELECT *
          FROM NotCompletelyShipped);

/* 5 */
CREATE VIEW ShippingDates AS
SELECT OrderID,
       MIN(DateShipped) FirstDateShipped,
       MAX(DateShipped) LastDateShipped
FROM TblShipLine
GROUP BY OrderID;

SELECT OrderID,
       CONVERT(VARCHAR, OrderDate, 107) OrderDate,
       orders.CustomerID,
       LastName + ', ' + FirstName CustomerName,
        CONVERT(VARCHAR, (SELECT FirstDateShipped
           FROM ShippingDates
           WHERE ShippingDates.OrderID = orders.OrderID), 107) FirstDateShipped,
       CONVERT(VARCHAR, (SELECT LastDateShipped
           FROM ShippingDates
           WHERE ShippingDates.OrderID = orders.OrderID), 107) LastDateShipped,
       DATEDIFF(DAY,
           (SELECT FirstDateShipped
           FROM ShippingDates
           WHERE ShippingDates.OrderID = orders.OrderID), (SELECT LastDateShipped
           FROM ShippingDates
           WHERE ShippingDates.OrderID = orders.OrderID)) DaysDifferenceShipping,
       DATEDIFF(DAY, OrderDate, (SELECT LastDateShipped
           FROM ShippingDates
           WHERE ShippingDates.OrderID = orders.OrderID)) DaysDifferenceOrderToLastShip
FROM TblOrder orders
INNER JOIN TblCustomer
ON orders.CustomerID = TblCustomer.CustomerID
WHERE OrderID NOT IN
        (SELECT *
            FROM NotCompletelyShipped)
AND DATEDIFF(DAY, OrderDate, (SELECT LastDateShipped
           FROM ShippingDates
           WHERE ShippingDates.OrderID = orders.OrderID)) > 20;

/* 6 */
CREATE VIEW CostHistorySummary AS
SELECT ItemID,
       MAX(LastCost) MostExpensiveCost,
       MIN(LastCost) LeastExpensiveCost,
       AVG(LastCost) AverageCost,
       MAX(LastCostDate) LastCostDate
FROM TblItemCostHistory outerCostHistory
GROUP BY ItemID;

CREATE VIEW PriceHistorySummary AS
SELECT ItemID,
       SUM(Quantity) TotalQtyOnOrder,
       COUNT(*) NumberOfOrders,
       MAX(Price) MostExpensivePrice,
       MIN(Price) LeastExpensivePrice,
       AVG(Price) AveragePrice
FROM TblOrderLine
GROUP BY ItemID;

SELECT ItemID,
       Description,
       CategoryDescription,
       ISNULL((SELECT TotalQtyOnOrder
           FROM PriceHistorySummary
           WHERE PriceHistorySummary.ItemID = items.ItemID), 0) TotalQtyOnOrder,
       ISNULL((SELECT NumberOfOrders
           FROM PriceHistorySummary
           WHERE PriceHistorySummary.ItemID = items.ItemID), 0) NumberOfOrders,
       ISNULL((SELECT MostExpensivePrice
           FROM PriceHistorySummary
           WHERE PriceHistorySummary.ItemID = items.ItemID), 0) MostExpensivePrice,
       ISNULL((SELECT LeastExpensivePrice
           FROM PriceHistorySummary
           WHERE PriceHistorySummary.ItemID = items.ItemID), 0) LeastExpensivePrice,
       ISNULL((SELECT AveragePrice
           FROM PriceHistorySummary
           WHERE PriceHistorySummary.ItemID = items.ItemID), 0) AveragePrice,
       ISNULL((SELECT MostExpensiveCost
           FROM CostHistorySummary
           WHERE CostHistorySummary.ItemID = items.ItemID), 0) MostExpensiveCost,
       ISNULL((SELECT LeastExpensiveCost
           FROM CostHistorySummary
           WHERE CostHistorySummary.ItemID = items.ItemID), 0) LeastExpensiveCost,
       ISNULL((SELECT AverageCost
           FROM CostHistorySummary
           WHERE CostHistorySummary.ItemID = items.ItemID), 0) AverageCost,
       ISNULL(CONVERT(VARCHAR, (SELECT LastCostDate
           FROM CostHistorySummary
           WHERE CostHistorySummary.ItemID = items.ItemID), 107), 'No Previous Purchase') LastCostDate,
       ISNULL((SELECT LastCost
           FROM TblItemCostHistory innerHistory
           WHERE innerHistory.ItemID = items.ItemID
           AND LastCostDate =
               (SELECT LastCostDate
                    FROM CostHistorySummary
                    WHERE CostHistorySummary.ItemID = items.ItemID)), 0) MostCurrentCost
FROM TblItem items
INNER JOIN tblItemType
ON items.TypeID = tblItemType.TypeID;

/* 7 */
CREATE VIEW LowestPricePaid AS
SELECT ItemID,
       MIN(Price) MinimumPrice
FROM TblOrderLine
GROUP BY ItemID;

SELECT orderLine.OrderID,
       CONVERT(VARCHAR, OrderDate, 107) OrderDate,
       orderLine.ItemID,
       Description,
       Price PricePaid,
       (SELECT LastCost
           FROM TblItemCostHistory
           WHERE LastCostDate =
                 (SELECT LastCostDate
                     FROM CostHistorySummary
                     WHERE orderLine.ItemID = CostHistorySummary.ItemID)) MostCurrentCost,
       CONVERT(VARCHAR, (SELECT LastCostDate
            FROM CostHistorySummary
            WHERE orderLine.ItemID = CostHistorySummary.ItemID), 107) LastCostDate,
       Price - (SELECT LastCost
           FROM TblItemCostHistory
           WHERE LastCostDate =
                 (SELECT LastCostDate
                     FROM CostHistorySummary
                     WHERE orderLine.ItemID = CostHistorySummary.ItemID)) DifferenceBetweenPriceAndCost
FROM TblOrderLine orderLine
INNER JOIN TblItem
ON orderLine.ItemID = TblItem.ItemID
INNER JOIN TblOrder
ON orderLine.OrderID = TblOrder.OrderID
WHERE Price =
      (SELECT MinimumPrice
          FROM LowestPricePaid
          WHERE ItemID =
                (SELECT ItemID
                    FROM TblItem
                    WHERE Description LIKE 'Diplomacy%'))
AND Description LIKE 'Diplomacy%';

/* 8 */
CREATE VIEW TotalQtyOnHand AS
SELECT ItemID,
       SUM(QtyOnHand) TotalQty
FROM TblItemLocation
GROUP BY ItemID;

CREATE VIEW OrderlineLeftToShip AS
SELECT OrderID,
       ItemID,
       Quantity,
       ISNULL((SELECT TotalShipped
           FROM ShippedSummary
           WHERE ShippedOrderID = OrderID
           AND ShippedItemID = ItemID), 0) QuantityShipped,
       CASE
           WHEN Quantity -
                    ISNULL((SELECT TotalShipped
                        FROM ShippedSummary
                        WHERE ShippedOrderID = OrderID
                        AND ShippedItemID = ItemID), 0) < 0
               THEN 0
            ELSE Quantity -
                    ISNULL((SELECT TotalShipped
                        FROM ShippedSummary
                        WHERE ShippedOrderID = OrderID
                        AND ShippedItemID = ItemID), 0)
        END QuantityToShip
FROM TblOrderLine;

CREATE VIEW ItemLeftToShip AS
SELECT ItemID,
       SUM(QuantityToShip) QuantityLeftToShip
FROM OrderlineLeftToShip
GROUP BY ItemID;

SELECT ItemID,
       Description,
       ISNULL((SELECT QuantityLeftToShip
           FROM ItemLeftToShip
           WHERE ItemLeftToShip.ItemID = items.ItemID), 0) TotalLeftToShip,
       ISNULL((SELECT TotalQty
           FROM TotalQtyOnHand
           WHERE TotalQtyOnHand.ItemID = items.ItemID), 0) TotalAvailableInInventory,
       ISNULL((SELECT QuantityLeftToShip
           FROM ItemLeftToShip
           WHERE ItemLeftToShip.ItemID = items.ItemID), 0) -
            ISNULL((SELECT TotalQty
               FROM TotalQtyOnHand
               WHERE TotalQtyOnHand.ItemID = items.ItemID), 0) QuantityShort
FROM TblItem items
WHERE ISNULL((SELECT QuantityLeftToShip
           FROM ItemLeftToShip
           WHERE ItemLeftToShip.ItemID = items.ItemID), 0) -
            ISNULL((SELECT TotalQty
               FROM TotalQtyOnHand
               WHERE TotalQtyOnHand.ItemID = items.ItemID), 0) > 0;

/* 9 */
CREATE VIEW OrderLineProfit AS
SELECT OrderID,
       orderLine.ItemID,
       Price * Quantity TotalPrice,
       Quantity *
        (SELECT LastCost
            FROM TblItemCostHistory costHistory
            WHERE costHistory.ItemID = orderLine.ItemID
            AND LastCostDate =
                (SELECT LastCostDate
                    FROM CostHistorySummary
                    WHERE orderLine.ItemID = ItemID)) TotalCost,
       (Price * Quantity) - Quantity *
        (SELECT LastCost
            FROM TblItemCostHistory costHistory
            WHERE costHistory.ItemID = orderLine.ItemID
            AND LastCostDate =
                (SELECT LastCostDate
                    FROM CostHistorySummary
                    WHERE orderLine.ItemID = ItemID)) Profit
FROM TblOrderLine orderLine;

SELECT OrderID,
       CONVERT(VARCHAR, OrderDate, 107) DateOrdered,
       orders.CustomerID,
       LastName,
       FirstName,
       (SELECT SUM(Profit)
           FROM OrderLineProfit
            WHERE OrderID = orders.OrderID
           GROUP BY OrderID) OrderProfit
FROM TblOrder orders
INNER JOIN TblCustomer
ON orders.CustomerID = TblCustomer.CustomerID;

/* 10 */
CREATE VIEW OrderProfit AS
SELECT OrderID,
       SUM(Profit) Profit
FROM OrderLineProfit
GROUP BY OrderID;

SELECT orderLine.OrderID,
       CONVERT(VARCHAR, OrderDate, 107) OrderDate,
       FirstName + ' ' + LastName CustomerName,
       orderLine.ItemID,
       Description ItemDescription,
       Quantity QtyOrdered,
       Price ItemPrice,
       (SELECT LastCost
            FROM TblItemCostHistory costHistory
            WHERE costHistory.ItemID = orderLine.ItemID
            AND LastCostDate =
                (SELECT LastCostDate
                    FROM CostHistorySummary
                    WHERE orderLine.ItemID = ItemID)) LastCostPaid,
       Price - (SELECT LastCost
                    FROM TblItemCostHistory costHistory
                    WHERE costHistory.ItemID = orderLine.ItemID
                    AND LastCostDate =
                        (SELECT LastCostDate
                            FROM CostHistorySummary
                            WHERE orderLine.ItemID = ItemID)) DifferenceBetweenPriceAndCost,
       Quantity * (Price - (SELECT LastCost
                                FROM TblItemCostHistory costHistory
                                WHERE costHistory.ItemID = orderLine.ItemID
                                AND LastCostDate =
                                    (SELECT LastCostDate
                                        FROM CostHistorySummary
                                        WHERE orderLine.ItemID = ItemID))) ExtendedDifference
FROM TblOrderLine orderLine
INNER JOIN TblOrder
ON orderLine.OrderID = TblOrder.OrderID
INNER JOIN TblCustomer
ON TblOrder.CustomerID = TblCustomer.CustomerID
INNER JOIN TblItem
ON orderLine.ItemID = TblItem.ItemID
WHERE orderLine.OrderID =
      (SELECT OrderID
          FROM OrderProfit
          WHERE Profit =
                (SELECT MAX(Profit)
                    FROM OrderProfit));

/* 11 */
CREATE VIEW SalesInNv AS
SELECT ItemID,
       SUM(Quantity) QuantitySold
FROM TblOrderLine
INNER JOIN TblOrder
ON TblOrderLine.OrderID = TblOrder.OrderID
INNER JOIN TblCustomer
ON TblOrder.CustomerID = TblCustomer.CustomerID
WHERE State = 'NV'
GROUP BY ItemID;

SELECT ItemID,
       Description ItemDescription,
       (SELECT MAX(QuantitySold)
           FROM SalesInNv) TotalQuantityOrdered,
       (SELECT AveragePrice
           FROM PriceHistorySummary
           WHERE PriceHistorySummary.ItemID = items.ItemID) AveragePrice,
       (SELECT LastCost
            FROM TblItemCostHistory costHistory
            WHERE costHistory.ItemID = items.ItemID
            AND LastCostDate =
                (SELECT LastCostDate
                    FROM CostHistorySummary
                    WHERE items.ItemID = ItemID)) LastCostPaid,
       CONVERT(VARCHAR, (SELECT LastCostDate
                    FROM CostHistorySummary
                    WHERE items.ItemID = ItemID), 107) LastCostDate
FROM TblItem items
WHERE ItemID =
      (SELECT ItemID
          FROM SalesInNv
          WHERE QuantitySold =
                (SELECT MAX(QuantitySold)
                    FROM SalesInNv));