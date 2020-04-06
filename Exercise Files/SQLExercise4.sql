
IF object_id ('zcust') is not null
    drop table cust;

IF object_id ('zord') is not null
    drop table ord;

IF object_id ('zemp') is not null
    drop table emp;

IF object_id ('zprod') is not null
    drop table prod;

IF object_id ('zorderline') is not null
    drop table orderline;

 CREATE TABLE zCust
 (CustID	char(10),
  CustomerName	Varchar(35));

INSERT INTO zCust VALUES
(1234, 'John Smith'),
(2555, 'Jane Doe'),
(6773, 'Bertie Wooster'),
(8372, 'Martin Cheng');


CREATE TABLE zOrd
(OrderID	int,
 OrderDate  datetime,
 CustID		char(10),
 DueDate	datetime,
 empid          int);

 INSERT INTO zOrd VALUES
(100, '04/15/2020', 1234, '05/19/2020',4),
(200, '04/24/2020', 6773, '05/18/2020',5),
(300, '04/22/2020', 1234, '08/1/2020',5),
(400, '05/27/2020', '2555', '06/16/2020',7),
(500, '06/11/2020', '8989', '06/22/2020',7),
(600, '06/15/2020', '2555', '06/27/2020',7),
(700, '07/11/2020', '2555', '09/04/2020',10);

CREATE TABLE zEmp
(empid      int,
 empname    varchar(30),
 empmgrid   int)

INSERT INTO zemp VALUES
(1, 'Martinson', null),
(2, 'Polanski', 1),
(3, 'Torquez', 1),
(4, 'Ling', 3),
(5, 'Bassett', 1),
(6, 'Martinez', 1),
(7, 'Johnson', 3),
(8, 'Cheng', 1),
(9, 'Fukamota', 3),
(10, 'Stein', 1);

CREATE TABLE zProd
 (ProdID	int,
  ProdName	Varchar(35));

INSERT INTO zProd VALUES
(10, 'Bookcase'),
(25, 'Table'),
(64, 'Desk'),
(81, 'Sofa'),
(31, 'Nightstand'),
(45, 'Bed'),
(67, 'Wood');

CREATE TABLE zOrderLine
(OrderID     int,
 ProdID      int,
 QtyOrdered  decimal(8,3),
 Price       money);

INSERT INTO zOrderLine Values
(100, 10, 3, 125.95),
(100, 67, 4.56, 10.99),
(100, 45, 1, 450),
(200, 81, 1, 1876.95),
(300, 64, 2, 312.99),
(300, 10, 1, 125.95),
(500, 10, 15, 120.99),
(600, 12, 5, 455.99),
(600, 64, 4, 312.00),
(400, 10, 10, 120.99),
(400, 25, 8, 460.99),
(400, 12, 2, 678.99),
(400, 67, 20.55, 10.99);
 

