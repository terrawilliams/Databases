
IF object_id ('ord') is not null
    drop table ord;

IF object_id ('cust') is not null
    drop table cust;

IF object_id ('ord2') is not null
    drop table ord2;

IF object_id ('ord3') is not null
    drop table ord3;

IF object_id ('emp3') is not null
    drop table emp3;

CREATE TABLE Ord
(OrderID	char(10),
 OrderDate  datetime,
 CustID		char(10),
 DueDate	datetime);

 CREATE TABLE Cust
 (CustID	char(10),
  CustomerName	Varchar(35));

INSERT INTO Ord VALUES
(100, '02/06/2020', 1234, '02/11/2020'),
(200, '02/09/2020', 6773, '02/17/2020'),
(300, '02/18/2020', 1234, '03/2/2020');

INSERT INTO Cust VALUES
(1234, 'John Smith'),
(2555, 'Jane Doe'),
(6773, 'Bertie Wooster'),
(8372, 'Martin Cheng');

CREATE TABLE Ord2
(OrderID	char(10),
 OrderDate  datetime,
 CustID		char(10),
 DueDate	datetime);

 INSERT INTO Ord2 VALUES
('100', '02/06/2020', '1234', '02/11/2020'),
('200', '02/09/2020', '6773', '02/17/2020'),
('300', '02/18/2020', '1234', '03/02/2020'),
('400', '01/27/2020', '2555', '02/02/2020'),
('500', '02/12/2020', '8989', '02/22/2020'),
('600', '01/28/2020', '2555', '01/31/2020'),
('700', '02/05/2020', '2555', '02/13/2020');

CREATE TABLE Ord3
(OrderID	char(10),
 OrderDate  datetime,
 CustID		char(10),
 DueDate	datetime,
 empid          int);

 INSERT INTO Ord3 VALUES
('100', '02/06/2020', '1234', '02/11/2020', 4),
('200', '02/09/2020', '6773', '02/17/2020', 5),
('300', '02/18/2020', '1234', '03/02/2020', 5),
('400', '01/27/2020', '2555', '02/02/2020', 7),
('500', '02/12/2020', '8989', '02/22/2020', 7),
('600', '01/28/2020', '2555', '01/31/2020', 7),
('700', '02/05/2020', '2555', '02/13/2020', 10);


CREATE TABLE emp3
(empid      int,
 empname    varchar(30),
 empmgrid   int)

INSERT INTO emp3 VALUES
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
