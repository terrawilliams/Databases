create table TblCustomer
(
    CustomerID      char(5)         primary key,
    LastName        varchar(30)     not null,
    FirstName       varchar(20),
    Address         varchar(30)     not null,
    City            varchar(20)     not null,
    State           char(2)         not null,
    Zip             varchar(12)     not null,
    Country         varchar(15),
    FirstBuyDate    datetime,
    Email           varchar(60),
    Phone           char(15)        not null,
    CustomerType    char(1)         check (CustomerType in ('P', 'S')),
    CustomerAffID   char(5)         references TblCustomer (CustomerID)
);

create table TblShipAddress
(
    AddressID       int             primary key,
    ShipName        varchar(30),
    ShipAddress     varchar(30),
    ShipPostalCode  varchar(20),
    ShipCountry     varchar(30),
    ShipPhone       char(15),
);

create table TblOrder
(
    OrderID         char(6)         primary key,
    OrderDate       datetime        not null,
    DiscountCode    char(2)         check (DiscountCode in ('02', '03', '04', '06', '08', '10', 'A1', 'B3')),
    CreditCode      char(3),
    CustomerID      char(5)         references TblCustomer (CustomerID),
    AddressID       int             references TblShipAddress(AddressID)
);

create table tblItemType
(
    TypeID         int             primary key,
    CategoryDescription varchar(50),
);

create table tblItem
(
    ItemID          char(6)         primary key,
    Description     varchar(300),
    ListPrice       money           not null        check (ListPrice <= 5),
    TypeID          int             references tblItemType(TypeID)
);

create table tblOrderLine
(
    OrderID         char(6)         references TblOrder(OrderID),
    ItemID          char(6)         references tblItem(ItemID),
    Quantity        int             not null        check (Quantity > 0),
    Price           money           not null        check (Price > 0),
    AddressID       int             references TblShipAddress(AddressID),
    primary key (OrderID, ItemID)
);

