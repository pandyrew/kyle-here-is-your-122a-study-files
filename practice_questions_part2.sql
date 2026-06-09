-- Schema for Suppliers, Categories, and Products tables

suppliers (supplier_id, supplier_name, city)
categories (category_id, category_name)
products (product_id, product_name, supplier_id, category_id, price, stock_quantity)


-- Practice Questions (Part 2 - Revised)

-- Q1: List all product names, their supplier names, and their category names.

select p.product_name, s.supplier_name, c.category_name
from products p
join suppliers s on s.supplier_id = p.supplier_id
join categories c on c.category_id = p.category_id

-- Q2: Find the total number of products for each category, along with the category name.

select c.category_name, count(p.product_id)
from products p
join category c on p.category_id = c.category_id
group by c.category_name


-- Q3: Find the category (category_name) that has the most products.

select c.category_name, count(p.product_id)
from products p
join categories c on p.category_id = c.category_id
group by c.category_name
order by count(p.product_id) desc
limit 1


-- Q4: List all products (product_name, price) that belong to the 'Electronics' category
--     and have a price greater than $100.

select p.product_name, p.price
from products p
join category c on c.category_id = p.category_id
where c.category_name = 'Electronics'
and p.price > 100

-- Q5: For each supplier, find the average price of products they supply.
--     Only include suppliers whose average product price is greater than $150.

select s.supplier_name, avg(p.price)
from product p
join supplier s on s.supplier_id = p.supplier_id
group by s.supplier_name
having avg(p.price) > 150


-- Q6: Find suppliers (supplier_name) who supply products in *all* categories.

select s.supplier_name
from supplier s
where not exists (
    (
        select c.category_id 
        from categories c
    )
    except
    (
        select DISTINCT p.category_id
        from products p
        where p.supplier_id = s.supplier_id
    
    )
)

-- Q7: List categories (category_name) that have at least one product,
--     but no product with a stock quantity less than 10.


select c.category_name, count(p.product_id)
from products p
join category c on p.category_id = c.category_id
group by c.category_name
having count(p.product_id) < 10 and count(p.product_id) > 0;

-- Q8: Find cities where *all* suppliers in that city supply at least one product.

select 

-- Q9: Find the product(s) (product_name, price) with the third highest price.

select 
select p.product_name, p.price
from products p
order by p.price desc
limit 3



-- Q10: List suppliers (supplier_name) who supply products in at least two different categories,
--      and the total value (price * stock_quantity) of all their products is greater than $10000.





-- Answers

-- A1: List all product names, their supplier names, and their category names.
SELECT p.product_name, s.supplier_name, c.category_name
FROM Products p
JOIN Suppliers s ON p.supplier_id = s.supplier_id
JOIN Categories c ON p.category_id = c.category_id;


-- A2: Find the total number of products for each category, along with the category name.
SELECT c.category_name, COUNT(p.product_id) AS total_products
FROM Categories c
LEFT JOIN Products p ON c.category_id = p.category_id
GROUP BY c.category_id, c.category_name
ORDER BY total_products DESC;


-- A3: Find the category (category_name) that has the most products.
-- Solution 1: Using subquery with MAX
SELECT c.category_name
FROM Categories c
JOIN Products p ON c.category_id = p.category_id
GROUP BY c.category_id, c.category_name
HAVING COUNT(p.product_id) = (
    SELECT MAX(product_count)
    FROM (
        SELECT COUNT(product_id) AS product_count
        FROM Products
        GROUP BY category_id
    ) AS subquery_max
);

-- Solution 2: Using ORDER BY and LIMIT
SELECT c.category_name
FROM Categories c
JOIN Products p ON c.category_id = p.category_id
GROUP BY c.category_id, c.category_name
ORDER BY COUNT(p.product_id) DESC
LIMIT 1;


-- A4: List all products (product_name, price) that belong to the 'Electronics' category
--     and have a price greater than $100.
SELECT p.product_name, p.price
FROM Products p
JOIN Categories c ON p.category_id = c.category_id
WHERE c.category_name = 'Electronics' AND p.price > 100;


-- A5: For each supplier, find the average price of products they supply.
--     Only include suppliers whose average product price is greater than $150.
SELECT s.supplier_name, AVG(p.price) AS average_product_price
FROM Suppliers s
JOIN Products p ON s.supplier_id = p.supplier_id
GROUP BY s.supplier_id, s.supplier_name
HAVING AVG(p.price) > 150;


-- A6: Find suppliers (supplier_name) who supply products in *all* categories.
SELECT s.supplier_name
FROM Suppliers s
WHERE NOT EXISTS (
    SELECT ca.category_id
    FROM Categories ca
    EXCEPT
    SELECT DISTINCT p.category_id
    FROM Products p
    WHERE p.supplier_id = s.supplier_id
);


-- A7: List categories (category_name) that have at least one product,
--     but no product with a stock quantity less than 10.
SELECT c.category_name
FROM Categories c
WHERE EXISTS (
    SELECT 1 FROM Products p WHERE p.category_id = c.category_id
) AND NOT EXISTS (
    SELECT 1 FROM Products p2 WHERE p2.category_id = c.category_id AND p2.stock_quantity < 10
);


-- A8: Find cities where *all* suppliers in that city supply at least one product.
SELECT s.city
FROM Suppliers s
GROUP BY s.city
HAVING COUNT(DISTINCT s.supplier_id) = COUNT(DISTINCT p.supplier_id);


-- A9: Find the product(s) (product_name, price) with the third highest price.
-- Solution 1: Using nested subquery with DISTINCT and LIMIT/OFFSET
SELECT product_name, price
FROM Products
WHERE price = (
    SELECT DISTINCT price
    FROM Products
    ORDER BY price DESC
    LIMIT 1 OFFSET 2
);


-- A10: List suppliers (supplier_name) who supply products in at least two different categories,
--      and the total value (price * stock_quantity) of all their products is greater than $10000.
SELECT s.supplier_name
FROM Suppliers s
JOIN Products p ON s.supplier_id = p.supplier_id
GROUP BY s.supplier_id, s.supplier_name
HAVING COUNT(DISTINCT p.category_id) >= 2 AND SUM(p.price * p.stock_quantity) > 10000;
