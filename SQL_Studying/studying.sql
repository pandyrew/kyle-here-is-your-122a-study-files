customer (cust_id, name, city, membership_level)

orders (order_id, cust_id, store_id, order_date, total_amount)

store (store_id, store_name, city, annual_revenue)

stock (store_id, product_id, quantity, price)

delivery (order_id, driver_id, delivery_status)


Find the names of all customers who have placed an order 
at a store located in 'Chicago'. Ensure there are no duplicate names in your result.

select distinct name 
from customer c
join orders o on o.cust_id = c.cust_id
join store s on s.store_id = o.store_id
where s.city = 'Chicago'

Find the IDs and names of all customers who have never placed an order after January 1st, 2024.

select c1.cust_id, c1.name
from customer c1
where c1.cust_id not in (
    select c2.cust_id
    from customer c2
    join order o on c2.cust_id = order.cust_id
    where 
)