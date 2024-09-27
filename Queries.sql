/*
  Sağlıklı bir db oluşturmak için Normalizasyon kavramı bilinmeli.
    3 Kuralı var.

	1. Bir tabloda satır bazında tekrar olmamalı. Yani satır tekrarı bir kolon sayesinde önlenmeli. Bu kolon da PK olarak tanımlanmalı
	2. Bir tabloda kolon bazında tekrar eden veri olmamalı. Tekrar eden(cek) veriler, ayrı bir tabloda tutulmalı ve o tablodan referans alınmalı.
	3. İki tablo arasında çoka çok ilişki olmaz! Bir ara tablo ile bire-çok ve çoka-bir biçiminde ayrılmalı

*/

/*
   1. Ne yapmak istiyorsun (SELECT, INSERT, UPDATE, DELETE)
   2. Hangi tablo ya da tablolar ile çalışacaksın?
   3. Hangi kolonlardaki veriyi görmek istiyorsun?
   4. Kriterin var mı?
   5. Sıralama veya gruplama gibi ihtiyaçların varf mı?
*/

--GROUP BY
-- Hangi ülkede kaç adet tedarikçimiz var?
/*
    Ülke Adı          Firma Sayısı
	 USA                   9
	 Türkiye               3
	 Australia             2
*/

SELECT 
   Country, COUNT(CompanyName) AS 'Firma Sayısı'
FROM Suppliers
GROUP BY Country
ORDER BY Country

--Hangi üründen toplam kaç adet satılmış?
/*
   ProductId         TotalQuantity
   ----------        ---------------
     1                   1523
	 2                   613
*/

SELECT
   ProductID, SUM(Quantity) as TotalQty
FROM [Order Details]
GROUP BY ProductID
HAVING SUM(Quantity) > 1000
ORDER BY TotalQty DESC

-- INNER JOIN
-- OUTER JOIN
-- CROSS JOIN

SELECT
  ProductName, CategoryName
FROM Products JOIN Categories
ON Products.CategoryID = Categories.CategoryID

-- Toplam 1000 adetten fazla satılan ürünlerin
--     adı
--     kaç adet satıldı?
--     ne kadar ciro yapıldı?


SELECT
    P.ProductName, 
	SUM(od.Quantity) as TotalQuantity,
	SUM(od.Quantity * OD.UnitPrice) as TotalPrice
FROM [Order Details] od  JOIN Products p
ON p.ProductID = od.ProductID
GROUP BY  P.ProductName
HAVING SUM(od.Quantity) > 1000
ORDER BY TotalPrice DESC

/*
  Hangi siparişi
        müşteri vermiş
		çalışan onaylamış
  bu siparişte 
        hangi kategorideki,
		hangi tedarikçinin sağladığı
		hangi üründen
		kaç adet alınmış
		ne kadar ödenmiş
		Hangi kargo şirketiyle gönderilmiş

*/
SELECT 
      o.OrderID,
	  c.CompanyName,
	  e.FirstName + ' ' + e.LastName as Employee,
	  p.ProductName,
	  od.Quantity,
	  od.Quantity * od.UnitPrice,
	  sp.CompanyName,
	  cat.CategoryName,
	  sh.CompanyName,
	  o.ShipAddress + '/'+o.ShipCountry as ShipAddress

FROM Employees e JOIN Orders o
     ON e.EmployeeID = o.EmployeeID
JOIN Customers c 
     ON c.CustomerID = o.CustomerID
JOIN Shippers sh 
     ON sh.ShipperID = o.ShipVia
JOIN [Order Details] od
     ON o.OrderID = od.OrderID
JOIN Products p
     ON p.ProductID = od.ProductID
JOIN Categories cat 
     ON cat.CategoryID = p.CategoryID
JOIN Suppliers sp 
     ON sp.SupplierID = p.SupplierID


     
SELECT ProductName, CategoryID FROM Products

SELECT CategoryID, CategoryName FROM Categories

--Kategorisi belirsiz ürünler:
SELECT 
   ProductName, CategoryName
FROM Categories RIGHT JOIN  Products
ON Products.CategoryID = Categories.CategoryID
WHERE CategoryName is NULL

--Ürünü  olmayan kategoriler:
SELECT 
   ProductName, CategoryName
FROM Categories LEFT JOIN  Products
ON Products.CategoryID = Categories.CategoryID
WHERE ProductName is NULL

SELECT 
   ProductName, CategoryName
FROM Categories FULL OUTER JOIN  Products
ON Products.CategoryID = Categories.CategoryID
WHERE ProductName is NULL  OR
      CategoryName is NULL


-- Sipariş vermeyen müşteriler kimler?
SELECT CompanyName, OrderID
FROM Orders RIGHT JOIN Customers
ON Orders.CustomerID = Customers.CustomerID
WHERE OrderID is NULL

--Hangi çalışan hangi çalışana rapor veriyor
SELECT
     Calisan.FirstName + ' ' + Calisan.LastName 'Temsilci',
	 Mudur.FirstName + ' ' + Mudur.LastName 'Mudur'
FROM Employees as Calisan  LEFT JOIN Employees as Mudur
     on Calisan.ReportsTo = Mudur.EmployeeID

SELECT COUNT(*) FROM Orders
SELECT COUNT(*) FROM [Order Details]
--Veritipinin eşleştiği tüm verileri çaprazlama olarak eşleştiren join türü
SELECT * FROM Orders CROSS JOIN [Order Details]

-- Sipariş vermeyen müşteriler kimler (JOIN)?
SELECT CompanyName
FROM Orders RIGHT JOIN Customers
ON Orders.CustomerID = Customers.CustomerID
WHERE OrderID is NULL

--Execution Plan karşılatırılarak en ideal sorgu türü seçilmelidir.
--Sub Queries:
SELECT CompanyName FROM 
Customers WHERE CustomerID NOT IN (SELECT DISTINCT CustomerID FROM Orders)

-- En pahalı ürünümüz hangisi?
SELECT * 
FROM Products WHERE UnitPrice = (SELECT MAX(UnitPrice) FROM Products)

-- Hangi kategorinin altında kaç adet ürün var?
SELECT 
  CategoryName,
  (
     SELECT COUNT(ProductId) FROM Products WHERE CategoryID = c.CategoryID
  ) as 'ProductsCount'
FROM Categories as c

-- Şirketimiz, hangi yılın  hangi ayında ne kadar ciro yapmış bilmek istiyorum!

SELECT x.Volume
FROM 
(SELECT 
    YEAR(OrderDate) as Year,
	MONTH(OrderDate) as Month,
	SUM(od.Quantity * od.UnitPrice) as Volume
FROM Orders o JOIN [Order Details] od
ON o.OrderID = od.OrderID
GROUP BY  YEAR(OrderDate), 	MONTH(OrderDate)) as x
WHERE x.Month=3 AND x.Year=1998


--Views
CREATE VIEW VolumeByDate
AS
SELECT 
    YEAR(OrderDate) as Year,
	MONTH(OrderDate) as Month,
	SUM(od.Quantity * od.UnitPrice) as Volume
FROM Orders o JOIN [Order Details] od
ON o.OrderID = od.OrderID
GROUP BY  YEAR(OrderDate), 	MONTH(OrderDate)



SELECT SUM(Volume) as Volume FROM VolumeByDate WHERE Year = 1997

ALTER VIEW CustomersFromGermany
AS
SELECT * FROM Customers WHERE Country = 'Germany'
WITH CHECK OPTION

INSERT INTO CustomersFromGermany (CustomerID, CompanyName, Country) values ('GRMX', 'Markt','Germany')
SELECT * FROM CustomersFromGermany

--CTE (Common Table Expression): Alt sorguları daha kolay kullanmak ve kayıtlı sorgu (view) oluşturmamak için kullanabiliriz.
-- Yıllara göre müşteri sayıları

SELECT 
   oy.year,
   COUNT(oy.CustomerID)
FROM
(SELECT YEAR(OrderDate) year, CustomerID FROM Orders)  as oy
GROUP BY oy.year


WITH CTE_by_year
AS
(
   SELECT YEAR(OrderDate) yil, CustomerID musteri FROM Orders
)

SELECT yil, COUNT(musteri) FROM CTE_by_year
GROUP BY yil

--Stored Procedures
-- Bu ürünü satın alanlar yanında hangi ürünleri tercih ettiler?
-- 1. O ürünü satın alan fişleri bul
-- 2. O fişlerin içinde yer alan DİĞER ürünleri say.
CREATE PROC RecommendedProducts
  @productId int
AS
SELECT TOP 10 ProductName, SUM(Quantity) as Qty 
FROM [Order Details]  JOIN Products 
ON [Order Details].ProductID = Products.ProductID
WHERE OrderID IN
(SELECT 
  OrderID
FROM [Order Details] WHERE ProductID = @productId)
AND Products.ProductID !=@productId
GROUP BY Products.ProductName
ORDER BY Qty DESC

RecommendedProducts 1

GO 
--Yeni sipariş oluşturan bir prosedür:

CREATE PROC CreateNewOrder
   @custId nchar(5),
   @eid int
as
INSERT into Orders (CustomerId, EmployeeId, OrderDate) 
            values (@custId, @eid, Getdate())
RETURN Scope_Identity()

-- Sadece bir ürün alan müşterinin prosedürü;:
CREATE PROC CreateNewOrderWithOneProduct
  @custId nchar(5),
  @eid int,
  @product int,
  @quantity smallint,
  @discount real
AS
  DECLARE @lastOrderId int;
  EXEC @lastOrderId = CreateNewOrder @custId, @eid

  DECLARE @price money
  SELECT @price = UnitPrice FROM Products WHERE ProductID = @product

  INSERT into [Order Details] (OrderID, ProductID, UnitPrice, Discount, Quantity)
                 values       (@lastOrderId, @product, @price, @discount, @quantity)


CreateNewOrderWithOneProduct 'ANTON',5,8,5,0.25

--Scalar Functions
SELECT LOWER('ÜRKMEZ')

SELECT 
    UPPER(SUBSTRING(FirstName,1,1)) +'. ' + UPPER(LastName)
FROM Employees

ALTER FUNCTION FormatShortName
(
   @name nvarchar(50),
   @lastName nvarchar(50)
)
RETURNS nvarchar(50)
AS
   BEGIN
      DECLARE @result nvarchar(50)
      SET @result = UPPER(SUBSTRING(@name,1,1))+'. ' +
	                UPPER(SUBSTRING(@lastName,1,1)) +
					LOWER(SUBSTRING(@lastName,2,LEN(@lastName)-1))
      
	  RETURN @result
   END

SELECT dbo.FormatShortName(FirstName, LastName) FROM Employees
GO

DECLARE @x nvarchar(50)
SET @x = 'Türkay';

SELECT dbo.FormatShortName(@x, 'urkmez');

SELECT  UPPER(SUBSTRING('türkay',1,1))+'. ' +
	                UPPER(SUBSTRING('urkmez',1,1)) +
					LOWER(SUBSTRING('urkmez',2,LEN('urkmez')-1))

select dbo.FormatShortName('tÜRkaY', 'ÜRkmEZ')

-- KDV'li fiyat hesaplayan fonksiyon:
CREATE FUNCTION Calculate_KDV
(
  @price money,
  @rate float
)
RETURNS money
AS
  BEGIN
     DECLARE @result money
	 SET @result = @price * (1+@rate)
	 RETURN Round(@result,2)
  END

SELECT dbo.Calculate_KDV(100,0.20)

SELECT ProductName, UnitPrice, Dbo.Calculate_KDV(UnitPrice,0.20) FROM Products

UPDATE Products SET UnitPrice = dbo.Calculate_KDV(UnitPrice, 0.20)

SELECT ProductName,UnitPrice FROM Products

--Belirtilen müşteriyle kaç gündür çalışıyoruz ve bu müşteri toplamda bizden kaç dolarlık alışveriş yapmış?
CREATE FUNCTION CustomerInfo
( 
   @customer nchar(5)
)
RETURNS TABLE
AS
RETURN (
   SELECT c.CompanyName, 
         SUM(od.Quantity * od.UnitPrice) as TotalVolume,
		 (SELECT DATEDIFF(DAY, MIN(OrderDate), MAX(OrderDate)) FROM Orders WHERE CustomerID=@customer) as 'Days'
   FROM Customers c JOIN Orders o
               on c.CustomerID = o.CustomerID
  JOIN [Order Details] od
		       on od.OrderID = o.OrderID
   WHERE c.CustomerID = @customer
   GROUP BY c.CompanyName

)

SELECT CompanyName,  
       (SELECT TotalVolume FROM dbo.CustomerInfo(c.CustomerID)) as 'Ciro',
       (SELECT Days FROM dbo.CustomerInfo(c.CustomerID)) as 'Gün'

	   FROM Customers c


SELECT * FROM dbo.CustomerInfo('BERGS')

/*
  Bir result set içerisindeki verilerin sütun olarak görüntülenmesi işlemine pivot diyoruz
*/

SELECT YEAR(OrderDate) year, SUM(od.Quantity * od.UnitPrice) as Total FROM Orders o JOIN [Order Details] od
                on OD.OrderID = o.OrderID
	   GROUP BY YEAR(OrderDate)
	   ORDER BY year
	  
/*
    1996		1997		1998
  -------------------------------------
   226508      658338       469771    
*/
-- PIVOT örneği:

CREATE VIEW SalesForCountry
AS
SELECT * FROM
(
   SELECT YEAR(OrderDate) year, o.ShipCountry, od.Quantity * od.UnitPrice as Total FROM Orders o JOIN [Order Details] od
                on OD.OrderID = o.OrderID	  
	 
) as source
PIVOT
(
   SUM(Total) FOR year IN ([1996],[1997],[1998])
) as pvt

SELECT * FROM SalesForCountry
UNPIVOT (TotalPrice FOR OrderYear IN ([1996],[1997],[1998])) AS unpvt

-- Çalışana göre sipariş adeti
SELECT * FROM
(
   SELECT FirstName, OrderId FROM Employees JOIN Orders    
               ON Employees.EmployeeID = Orders.EmployeeID
) as src
PIVOT 
(
  COUNT(OrderID) FOR FirstName IN ([Nancy],[Andrew],[Janet])
) as pvt



--Siparişte satın alınan ürün adedi kadar stoğu güncelleyen trigger
alter TRIGGER autoStockUpdate
ON [Order Details] FOR INSERT, UPDATE, DELETE
AS
  BEGIN
      DECLARE @qty int
	  DECLARE @id int
      IF EXISTS (Select * from inserted) AND NOT EXISTS(SELECT * FROM deleted)
	    BEGIN
			
	  --insert edilen verileri değişkenlere aktardık:
	       SELECT @qty = Quantity, @id= ProductID FROM inserted
           --UPDATE Products SET UnitsInStock = UnitsInStock - @qty WHERE ProductID = @id
		END
      ELSE IF EXISTS(SELECT  * FROM  inserted) AND EXISTS (SELECT * FROM deleted)
	     BEGIN
		    -- 1. inserted (yeni): 5
			--    deleted (eski) ise 3 stoktan 2 azalt
			-->2. inserted: 3
			--    deleted: 5 ise stoğu 2 arttır. 
			DECLARE @insQty int
		    DECLARE @delQty int

			SELECT @insQty = Quantity, @id=ProductId FROM inserted
			SELECT @delQty = Quantity FROM deleted

			SET @qty = @insQty - @delQty
			 --UPDATE Products SET UnitsInStock = UnitsInStock - @qty WHERE ProductID = @id
		 END
	   ELSE
	       -- Sadece silme durumu
	       BEGIN 
		         DECLARE @deletedQty int
				 SELECT @deletedQty = Quantity, @id=ProductId FROM deleted
				 SET @qty = 0 - @deletedQty
				 --UPDATE Products SET UnitsInStock = UnitsInStock - @qty WHERE ProductID = @id
		   END
	 
	   UPDATE Products SET UnitsInStock = UnitsInStock - @qty WHERE ProductID = @id
  END


INSERT into [Order Details] (OrderID, ProductID,Quantity) values (10276,8,5)
UPDATE [Order Details] SET Quantity= 2 WHERE OrderID= 10276 AND ProductID = 8
SELECT ProductName, UnitsInStock FROM Products WHERE ProductID = 8




CREATE TRIGGER tr_InsOfDelete
ON Products INSTEAD OF Delete
AS
 BEGIN
     DECLARE @id int
	 SELECT  @id = ProductId FROM deleted

	 UPDATE Products SET Discontinued = 1 WHERE ProductID = @id
 END

 DELETE FROM Products WHERE ProductID = 2

 SELECT ProductID, ProductName, Discontinued FROM Products

 --Hata Yönetimi
 BEGIN TRY
   SELECT 5/0
 END TRY
 BEGIN CATCH
   Print('Tam sayılar 0 a bolünemez!')
 END CATCH

 -- Birden fazla tablo ile çalışarak operasyonu tamamlayan biş iş varsa bu iş transaction ile yönetilmeli

 BEGIN TRY
    BEGIN TRAN T1
	   --Komut (INSERT, UPDATE, DELETE)
	     BEGIN TRAN T2
		  --Komut
         COMMIT TRAN 
    COMMIT TRAN    
 END TRY
 BEGIN CATCH 
    ROLLBACK TRAN T1
 END CATCH


 CREATE PROC HowIsRollback
   @categoryId int,
   @ProductName nvarchar(40) 
 AS
  BEGIN TRY
     BEGIN TRAN InsertProduct
	    INSERT into Products (ProductName) values (@ProductName)
	    BEGIN TRAN DelCategory
		  DELETE FROM Categories WHERE CategoryID = @categoryId
		COMMIT TRAN
	 COMMIT TRAN
  END TRY
  BEGIN CATCH 
     ROLLBACK TRAN InsertProduct
  END CATCH

  HowIsRollback 3,'Baklava'
  

  -- Yeni bir ürünü kategorisiyle birlikte ekleyen (transaction ile) prosedür:

  CREATE PROC CreateCategoryAndProduct
   @CategoryName nvarchar(15),
   @ProductName nvarchar(40) 
  AS
    BEGIN TRY
	  BEGIN TRAN NewCategory
	     INSERT into Categories(CategoryName) values (@CategoryName)
		 DECLARE @catId int
		 SET @catId = SCOPE_IDENTITY()
		 BEGIN TRAN NewProduct
		    INSERT into Products(ProductName, CategoryID) values (@ProductName, @catId)
		 COMMIT TRAN
      COMMIT TRAN
	END TRY
	BEGIN CATCH
	   ROLLBACK TRAN NewCategory
	END CATCH

	EXEC CreateCategoryAndProduct 'Sebzeler','Bezelye'

	SELECT * FROM Categories
	SELECT * FROM Products

	--Tuning Advisor önerileri:

CREATE NONCLUSTERED INDEX IX_Employee_LastName ON [dbo].[Employees]
(
	[FirstName] ASC
)
INCLUDE([LastName]) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]


CREATE NONCLUSTERED INDEX [ix_Order_Details] ON [dbo].[Order Details]
(
	[ProductID] ASC,
	[Quantity] DESC,
	[UnitPrice] ASC
)
INCLUDE([OrderID]) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]

DECLARE @count int
  SET @count = 1
WHILE @count < 1000
  BEGIN
INSERT into Employees (FirstName, LastName) values ('Türkay','Ürkmez')
INSERT into Employees (FirstName, LastName) values ('Abdullah','Kaya')
INSERT into Employees (FirstName, LastName) values ('Ali Canalp','Cansever')
INSERT into Employees (FirstName, LastName) values ('Ayşe Sena','Şahin')
INSERT into Employees (FirstName, LastName) values ('Barış Ozan','Ağkoç')

  SET @count = @count +1
  END

  SELECT * FROM Employees
DBCC INDEXDEFRAG (Northwind, 'Employees', IX_Employee_LastName);

DBCC SHOWCONTIG ('Northwind..Orders');

SELECT 
  ProductName, UnitPrice, UnitsInStock
FROM Products
ORDER BY UnitsInStock


CREATE VIEW GetStockColorFlag
as
SELECT 
  ProductName, UnitPrice, UnitsInStock, ColorState = CASE 
                                                        WHEN UnitsInStock = 0 THEN 'Red'
                                                        WHEN UnitsInStock < 50 THEN 'Blue'
                                                        WHEN UnitsInStock >= 50 THEN 'Green'    							
														
	                                                 END       
FROM Products

SELECT * FROM GetStockColorFlag 
WHERE ColorState = 'Red'
ORDER BY UnitsInStock 

SELECT 
 FirstName, LastName, Region, Region = CASE
                                          WHEN Region = 'WA' THEN 'Washington'
                                          WHEN Region is NULL THEN 'Bilinmiyor'

                                       END
FROM Employees

CREATE VIEW AllCompanies
as
SELECT CompanyName, Address,City, Country, 'Customer' as 'Type'  FROM Customers
UNION
SELECT CompanyName, Address,City, Country,'Supplier' as 'Type'  FROM Suppliers


SELECT * from  AllCompanies WHERE Country = 'Germany'

SELECT Country,  COUNT(Type),Type FROM AllCompanies 
GROUP BY Type, Country 

SELECT DISTINCT CustomerID FROM Customers
INTERSECT
SELECT CustomerID FROM Orders

