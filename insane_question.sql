-- Schema for Suppliers, Categories, and Products tables
Suppliers (supplier_id, supplier_name, city)
Categories (category_id, category_name)
Products (product_id, product_name, supplier_id, category_id, price, stock_quantity)



-- Insanely Hard Question:
-- Find the `supplier_name` of all suppliers who:
-- 1. Supply products in at least two different categories.
-- 2. Supply products in ALL categories that also contain products supplied by 'A_Tech'.
-- 3. DO NOT supply any product that is MORE expensive than the MOST expensive product supplied by 'B_Gadget'.

-- 1. Supply products in at least two different categories.

select s1.supplier_id
from suppliers s1
natural join products p1
group by s1.supplier_id
having count(distinct p1.category_id) >=2

-- 2. Supply products in ALL categories that also contain products supplied by 'A_Tech'.

select s2.supplier_id
from suppliers s2
where not exists (
    (
        select c2.category_id
        from categories c2
        natural join products p2
        natural join suppliers s22
        where s22.supplier_name = "A_tech"
    
    )
    except
    (
        select c22.category_id
        from categories c22
        natural join products p22
        where p22.supplier_id = s2.supplier_id
    )
)

-- 3. DO NOT supply any product that is MORE expensive than 
-- the MOST expensive product supplied by 'B_Gadget'.

select s3.supplier_id
from suppliers s3
natural join products p3
group by s3.supplier_id
having max(p3.price) <= 







(select max(p33.price)
from products p33
natural join suppliers s33
where s33.supplier_name = 'B_Gadget'
)



select s.supplier_name
from supplier s
where s.supplier_id in (
select s1.supplier_id
from suppliers s1
natural join products p1
group by s1.supplier_id
having count(distinct p1.category_id)
) and s.supplier_id in (
select s2.supplier_id
from suppliers s2
where not exists (
    (
        select c2.category_id
        from categories c2
        natural join products p2
        natural join suppliers s22
        where s22.supplier_name = "A_tech"
    
    )
    except
    (
        select c22.category_id
        from categories c22
        natural join products p22
        where p22.supplier_id = s2.supplier_id
    )
)
) and s.supplier_id in (
select s3.supplier_id
from suppliers s3
natural join products p3
where s3.price <= (select max(p33.price)
from products p33
natural join suppliers s33
where s33.supplier_name = 'B_Gadget'
)
)

























-- Solution:
SELECT s.supplier_name
FROM Suppliers s
WHERE
    -- Condition 1: Supplies products in at least two different categories.
    (SELECT COUNT(DISTINCT p1.category_id)
     FROM Products p1
     WHERE p1.supplier_id = s.supplier_id) >= 2

    AND

    -- Condition 2: Supplies products in ALL categories that also contain products supplied by 'A_Tech'.
    NOT EXISTS (
        -- Categories supplied by 'A_Tech'
        SELECT DISTINCT p_at.category_id
        FROM Products p_at
        JOIN Suppliers s_at ON p_at.supplier_id = s_at.supplier_id
        WHERE s_at.supplier_name = 'A_Tech'

        EXCEPT

        -- Categories supplied by the current supplier 's'
        SELECT DISTINCT p_s.category_id
        FROM Products p_s
        WHERE p_s.supplier_id = s.supplier_id
    )

    AND

    -- Condition 3: Does NOT supply any product that is MORE expensive than the MOST expensive product supplied by 'B_Gadget'.
    -- This means all products supplied by 's' must be <= MAX price of B_Gadget's products.
    NOT EXISTS (
        SELECT 1
        FROM Products p_curr
        WHERE p_curr.supplier_id = s.supplier_id
        AND p_curr.price > (
            SELECT MAX(p_bg.price)
            FROM Products p_bg
            JOIN Suppliers s_bg ON p_bg.supplier_id = s_bg.supplier_id
            WHERE s_bg.supplier_name = 'B_Gadget'
        )
    );
