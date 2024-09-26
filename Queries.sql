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

SELECT CompanyName FROM 
Customers WHERE CustomerID NOT IN (SELECT DISTINCT CustomerID FROM Orders)

-- En pahalı ürünümüz hangisi?
SELECT * 
FROM Products WHERE UnitPrice = (SELECT MAX(UnitPrice) FROM Products)
             