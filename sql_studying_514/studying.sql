
Homework Assignment #3 (from textbook)

course(course id, title, dept name, credits)
instructor(ID, name, dept name, salary)
section(course id, sec id, semester, year, building, room number, time slot id)
student(ID, name, dept name, tot cred)
takes(ID, course id, sec id, semester, year, grade)



3.11 Write the following queries in SQL, using the university schema.
a. Find the names of all students who have taken at least one Comp. Sci. course; make
sure there are no duplicate names in the result.

select distinct name 
from student
natural join takes
natural join course
where course.dept_name = "Comp. Sci"

b. Find the IDs and names of all students who have not taken any course offering before
Spring 2009.

select s.ID, s.name
from student s
natural join takes t
where t.year < 2009


c. For each department, find the maximum salary of instructors in that department. You
may assume that every department has at least one instructor.

select dept_name, max(salary)
from instructor
group by dept_name



d. Find the lowest, across all departments, of the per-department maximum salary
computed by the preceding query.

select min(max_salary)
from (
select dept_name, max(salary) as max_salary
from instructor
group by dept_name
)



3.16 Consider the relational database below:
employee (person_name, street, city)
works (person_name, company_name, salary)
company (company_name, city)
manages (person_name, manager_name)
Give an expression in SQL for each of the following queries.
a. Find the names of all employees who work for First Bank Corporation.

select person_name
from employee e
natural join works w
where w.company_name = 'fbc';


b. Find all employees in the database who live in the same cities as the companies for
which they work.

select person_name
from employee e
natural join works
natural join company c
where c.city = e.city;


c. Find all employees in the database who live in the same cities and on the same streets
as do their managers.

select e1.person_name
from employee e1
natural join manages m
join employee e2 on e2.person_name = m.manager_name
where e1.city = e2.city and e1.street = e2.street;

d. Find all employees who earn more than the average salary of all employees of their
company.

select e.person_name
from employee e
where salary > (
    select avg(salary)
    from works w
    where w.company_name = e.company_name
)


e. Find the company that has the smallest payroll.

select company_name, sum(salary)
from works
group by company_name
order by sum(salary) asc
limit 1

select company_name
from works
group by company_name
having sum(salary) <= all (select sum(salary) from works group by company_name)

3.21 Consider the following relational schema for a library:
member(memb_no, name, dob)
books(isbn, title, authors, publisher)
borrowed(memb_no, isbn, date)
Write the following queries in SQL.
a. Print the names of members who have borrowed any book published by “McGraw-
Hill”.

select name 
from member m 
natural join borrowed br
natural join books b
where b.publisher = "mgh"

b. Print the names of members who have borrowed all books published by “McGraw-
Hill”.

select m.name
from member m
where not exists (
    select 1
    from books b
    where b.publisher = 'MGH'
    and not exists (
        select 1
        from borrowed br
        where br.memb_no = m.memb_no
        where br.isbn = b.isbn
    )
)

c. For each publisher, print the names of members who have borrowed more than five
books of that publisher.

select b.publisher, m.name
from member m
join borrowed br on br.memb_no = m.memb_no
join books b on b.isbn = br.isbn
group by b.publisher, m.name, m.memb_no
having count(b.isbn) > 5;

d. Print the average number of books borrowed per member. Take into account that if a
member does not borrow any books, then that member does not appear in the
borrowed relation at all.

with total_members as (select count(*) from member)
select count(*) / total_members 
from borrowed




