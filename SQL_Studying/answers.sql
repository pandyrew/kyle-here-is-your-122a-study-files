select person_name from works where company_name = FBC

select employee.person_name 
from works
join employee on employee.person_name = works.person_name
join company on works.company_name = company.company_name
where employee.city = company.city;

select e1.person_name from employee e1
join manages on manages.person_name = e1.person_name
join employee e2 on e2.person_name = manages.manager_name
where e1.city = e2.city and e1.street = e2.street;

select w1.person_name from works w1 where salary > (select avg(w2.salary) from works w2 where w2.company_name = w1.company_name);

SELECT company_name
    FROM works
    GROUP BY company_name
    HAVING SUM(salary) <= ALL (
        SELECT SUM(salary) 
        FROM works 
        GROUP BY company_name
    );

select company_name 
from works
group by company_name
having sum(salary) <= ALL (
    select sum(salary)
    from works
    group by company_name
)


3.21:

select name from member where memb_no in (
    select memb_no from borrowed join books on books.isbn = borrowed.isbn
    where publisher = 'McGraw-Hill'
);

select name
from member m
where not exists (
    select 1
    from books b
    where b.publisher = 'McGraw-Hill'
    and not exists (
        select 1
        from borrowed br
        where br.memb_no = m.memb_no
        and br.isbn = b.isbn
    )
);

select name 
from member m 
where not exists (
    select 1
    from books b
    where b.publisher = 'MGH'
    and not exists (
        select 1
        from borrowed br
        where br.memb_no = m.memb_no
        and br.isbn = b.isbn
    )
)

books: [east of eden, poop, fart]

member m borrowed [east of eden, poop]


select name 
from member m 
where not exists (
    for book in books that are mgh:
    and not exists (
        poop borrwed by member m
    )
)


east of eden


someone who has borrowed all their books from mgh

books: [east of eden, poop, fart]

member m borrowed [east of eden, poop, fart]


find member m
they are not in this group (
    for each book, we see if it has been borrowed by member m
    so then since we are double negating, we want each book to not be in the next set
    so that we dont find a book that has not been borrowed
    so then if a book has been borrowed, then it not show up as a record.
    but if a book has been borrwed, then itll show up as a record because
    it does not exist in the borrwed record
     (
        YES BOOK HAS BEEN BORROWED
    )
)


select name 
from member m 
where not exists (
    select 1
    from books b
    where publisher = "MGH"
    where not exists (
        select 1
        from borrowed br
        where br.isbn = b.isbn
        and m.memb_no = b.memb_no
    )
)
        select 1
        from borrowed br
        where br.isbn = b.isbn
        and m.memb_no = b.memb_no








select name from 


select b.publisher, m.name
from borrowed br
join books b on br.isbn = b.isbn
join member m on br.memb_no = m.memb_no
group by b.publisher, m.memb_no, m.name
having count(distinct br.isbn) > 5;


select b.publisher, m.name
from borrowed br
join books b on br.isbn = b.isbn
join member m on br.memb_no = m.memb_no
group by b.publisher, m.memb_no, m.name
having count(distinct br.isbn) > 5;


select b.publisher, m.name
from borrowed br
join books b on br.isbn = b.isbn
join member m on br.memb_no = m.memb_no
group by b.publisher, m.memb_no, m.name
having count(distinct br.isbn) > 5;







select b.publisher, m.name 
from member m 
join borrowed br on br.memb_no = m.memb_no
join books b on b.isbn = br.isbn
group by b.publisher, m.memb_no, m.name
having count(distinct b.isbn) > 5;





Print the average number of books borrowed per member. Take into account that if a
member does not borrow any books, then that member does not appear in the
borrowed relation at all.








SELECT AVG(num_borrowed) AS average_books_per_member
FROM (
    SELECT m.memb_no, COUNT(br.isbn) AS num_borrowed
    FROM member m
    LEFT JOIN borrowed br ON m.memb_no = br.memb_no
    GROUP BY m.memb_no
) AS member_borrow_counts;






















