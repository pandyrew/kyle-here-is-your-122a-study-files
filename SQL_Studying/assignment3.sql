classroom(building, room number, capacity)
department(dept name, building, budget)
course(course id, title, dept name, credits)
instructor(ID, name, dept name, salary)
section(course id, sec id, semester, year, building, room number, time slot id)
teaches(ID, course id, sec id, semester, year)
student(ID, name, dept name, tot cred)
takes(ID, course id, sec id, semester, year, grade)
advisor(s ID, i ID)
time slot(time slot id, day, start time, end time)
prereq(course id, prereq id)


3.11 Write the following queries in SQL, using the university schema.
a. Find the names of all students who have taken at least one Comp. Sci. course; make
sure there are no duplicate names in the result.

select distinct name 
from student
natural join takes
natural join course
where couse.dept_name = "CS"

b. Find the IDs and names of all students who have not taken any course offering before
Spring 2009.

select s1.id, s1.name
from student s1
where s1.id not in (
    select s2.id from student s2
    natural join takes t
    where t.year < 2009
)

select id, name
from student
except id,name
from student
natural join takes
where year < 2009



c. For each department, find the maximum salary of instructors in that department. You
may assume that every department has at least one instructor.

select dept_name, max(salary)
from instructors
group by dept_name

d. Find the lowest, across all departments, of the per-department maximum salary
computed by the preceding query.

select min(max_salary)
from (
    select dept_name, max(salary) max_salary
    from instructors
    group by dept_name
)

3.16 Consider the relational database below:

employee (person_name, street, city)
works (person_name, company_name, salary)
company (company_name, city)
manages (person_name, manager_name)

Give an expression in SQL for each of the following queries.
a. Find the names of all employees who work for First Bank Corporation.

select person_name from employee
natural join works
where company_name = "FBC"

b. Find all employees in the database who live in the same cities as the companies for
which they work.

select person_name 
from employee e, works w, company c
where e.person_name = w.person_name and e.city = c.city and w.company_name = c.company_name 

c. Find all employees in the database who live in the same cities and on the same streets
as do their managers.

select e1.person_name
from employee e1
join manages m on m.person_name = e1.person_name
join employee e2 on e2.person_name = m.manager_name
where e1.city = e2.city and e1.street = e2.street

d. Find all employees who earn more than the average salary of all employees of their
company.

select e1.person_name
from employee e1
where e1.salary > (
    select avg(e2.salary)
    from employee e2
    join works w on w.person_name = e2.person_name
    where e1.company_name = w.company_name
)
e. Find the company that has the smallest payroll.

SELECT company_name, SUM(salary) AS total_payroll
FROM works
GROUP BY company_name
ORDER BY total_payroll ASC
LIMIT 1;

select company_name, sum(salary) as total_payroll
from works
group by company_name
order by total_payroll ASC
limit 1


select company_name, sum(salary) as payroll
from works
group by company_name
order by payroll ASC
limit 1




employee (person_name, street, city)
works (person_name, company_name, salary)
company (company_name, city)
manages (person_name, manager_name)



3.21 Consider the following relational schema for a library:

member(memb_no, name, dob)
books(isbn, title, authors, publisher)
borrowed(memb_no, isbn, date)
Write the following queries in SQL.

a. Print the names of members who have borrowed any book published by “McGraw-
Hill”.

select m.name
from member m
join borrowed br on br.memb_no = m.name
join books b on b.isbn = br.isbn
where b.publisher = 'MGH'


b. Print the names of members who have borrowed all books published by “McGraw-
Hill”.

select m.name
from member m
where not exists (
    select 1
    from book b
    where b.publisher = 'MGH'
    and not exists (
        select 1
        from borrowed br
        where br.memb_no = m.name and br.isbn = b.isbn
    )
)


c. For each publisher, print the names of members who have borrowed more than five
books of that publisher.

select b.publisher, m.name
from member m
join borrowed br on br.memb_no = m.memb_no
join books b on b.isbn = br.isbn
group by b.publisher, m.name
having count(b.isbn) > 5;


d. Print the average number of books borrowed per member. Take into account that if a
member does not borrow any books, then that member does not appear in the
borrowed relation at all.

average number of books borrwed per member

select member, avg(books_borrowed)
from 



with member_count as (select count(*) from member)

select count(*) / member_count
from borrowed