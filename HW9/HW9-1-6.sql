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

CREATE VIEW LeftToShip AS
SELECT TblOrderLine.ItemID,
       SUM(Quantity) - SUM(QtyShipped) QuantityToShip
FROM TblOrderLine
INNER JOIN TblShipLine
ON TblOrderLine.OrderID = TblShipLine.OrderID and TblOrderLine.ItemID = TblShipLine.ItemID
WHERE TblOrderLine.OrderID IN
    (SELECT *
        FROM NotCompletelyShipped)
GROUP BY TblOrderLine.ItemID;

SELECT *
FROM TblOrderLine;

SELECT ItemID,
       Description,
       (SELECT QuantityToShip
           FROM LeftToShip
           WHERE LeftToShip.ItemID = items.ItemID) TotalLeftToShip,
       ISNULL((SELECT TotalQty
           FROM TotalQtyOnHand
           WHERE TotalQtyOnHand.ItemID = items.ItemID), 0) TotalAvailableInInventory
FROM TblItem items;

/* 9 */


/* 10 */


/* 11 */
