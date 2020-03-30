/* (1) */
SELECT      FirstName + ' ' + LastName   Name,
            Phone,
            City,
            State,
            CustomerAffID                AffiliatedCustomer,
            FirstBuyDate
FROM TblCustomer
WHERE State = 'CA'
ORDER BY LastName;

/* (2) */
SELECT      LastName + ', ' + SUBSTRING(FirstName, 1, 1) + '.' Name,
            '(' + SUBSTRING(Phone, 1, 3) + ') ' +
                    SUBSTRING(Phone, 4, 3) + '-' +
                    SUBSTRING(Phone, 7, 4)  PhoneNumber,
            UPPER(City)                     City,
            UPPER(State)                    State,
            CustomerAffID                   AffiliatedCustomer,
            CONVERT(varchar, FirstBuyDate, 107) FirstBuyDateOut
FROM TblCustomer
WHERE State = 'CA'
ORDER BY FirstBuyDate DESC;

/* (3) */
SELECT      LastName + ', ' + SUBSTRING(FirstName, 1, 1) + '.' Name,
            '(' + SUBSTRING(Phone, 1, 3) + ') ' +
                    SUBSTRING(Phone, 4, 3) + '-' +
                    SUBSTRING(Phone, 7, 4)  PhoneNumber,
            UPPER(City)                     City,
            UPPER(State)                    State,
            CustomerAffID                   AffiliatedCustomer,
            CONVERT(varchar, FirstBuyDate, 107) FirstBuyDateOut
FROM TblCustomer
WHERE State = 'CA' and CustomerAffID IS NULL
ORDER BY FirstBuyDate DESC;

/* (4) */
SELECT      CONVERT(VARCHAR, OrderDate, 101)            'Date of Order',
            OrderID                                     'Order Number',
            CustomerID                                  'Customer Number',
            CreditCode                                  'Credit Code',
            ISNULL(CONVERT(VARCHAR, AddressID),  'Use Billing Address')    'Shipping AddressID'
FROM TblOrder
WHERE AddressID IS NULL
ORDER BY OrderDate;

/* (5) */
SELECT      OrderID                         OrderNumber,
            ItemID                          ItemNumber,
            Quantity                        QuantityOrdered,
            CONVERT(DECIMAL(10,2), Price)   PricePaid,
            CONVERT(DECIMAL(10,2), (Price * Quantity))   ExtendedPrice
FROM TblOrderLine
WHERE ItemID = 'B67466';

/* (6) */
SELECT      OrderID                         OrderNumber,
            ItemID                          ItemNumber,
            Quantity                        QuantityOrdered,
            CONVERT(DECIMAL(10,2), Price)   PricePaid,
            CONVERT(DECIMAL(10,2), (Price * Quantity))   ExtendedPrice
FROM TblOrderLine
WHERE (Price * Quantity) > 850;

/* (7) */
SELECT      OrderID                         OrderNumber,
            ItemID                          ItemNumber,
            Quantity                        QuantityOrdered,
            CONVERT(DECIMAL(10,2), Price)   PricePaid,
            CONVERT(DECIMAL(10,2), (Price * Quantity))   ExtendedPrice,
            CASE
                WHEN (Price * Quantity) >= 5000
                    THEN '***Closely Watch the Status***'
                WHEN (Price * Quantity) >= 2000
                    THEN 'Very Large Order - Watch Dates'
                WHEN (Price * Quantity) >= 1500
                    THEN 'Large Order - Monitor Shipping Date'
                WHEN (Price * Quantity) >= 1000
                    THEN 'Medium Number'
                ELSE
                    NULL
            END             OrderStatusMessage
FROM TblOrderLine
WHERE (Price * Quantity) > 850;

/* (8) */
SELECT      OrderID,
            ItemID,
            CONVERT(varchar, DateShipped, 101)      DateShipped,
            QtyShipped,
            MethodShipped
FROM TblShipLine
WHERE MONTH(DateShipped) = 1 and YEAR(DateShipped) = YEAR(GETDATE())
GROUP BY OrderID, DateShipped, QtyShipped, ItemID, MethodShipped
ORDER BY OrderID, ItemID;
