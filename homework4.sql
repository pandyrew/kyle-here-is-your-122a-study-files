3.12 Write the following queries in SQL, using the university schema.
a. Create a new course “CS-001”, titled “Weekly Seminar”, with 0 credits. insert into course
(course_id, title, dept_name, credits)
INSERT INTO course (course_id, title, dept_name, credits)
VALUES (‘CS-001’, ‘Weekly Seminar’, ‘Comp. Sci’, 0);
b. Create a section of this course in Autumn 2009, with section id of 1.
INSERT INTO section (course_id, sec_id, semester , year, building, room_number, time_slot_id)
VALUES (‘CS-001’, ‘1’, ‘Autumn’, 2009, NULL, NULL, NULL);
c. Enroll every student in the Comp. Sci. department in the above section.
INSERT INTO takes (ID, course_id, sec_id, semester, year, grade)
SELECT ID, ‘CS-001’, ‘1’, ‘Autumn’, 2009, NULL
FROM student
WHERE dept_name = ‘Comp. Sci.’;
d. Delete enrollments in the above section where the student’s name is Chavez.
DELETE FROM takes
WHERE course_id = 'CS-001' AND sec_id = '1' and semester = 'Autumn' AND year = 2009 AND
ID in (SELECT ID FROM student WHERE name = 'Chavez');
e. Delete the course CS-001.What will happen if you run this delete statement without first
deleting offerings (sections) of this course.
DELETE FROM course where course_id = 'CS-001';
Since there the section table references course_id, there will be a foreign key constraint error
f. Delete all takes tuples corresponding to any section of any course with the word
“database” as a part of the title; ignore case when matching the word with the title.
DELETE FROM takes
WHERE course_id IN ( SELECT course_id FROM course WHERE lower(title) like
'%database%' );
3.13 Consider the relational database below: employee (driver-id, name, address) car (license,
model, year) accident (report-number, date, location) owns (driver-id, license) participated
(report-number, license, driver-id, damage-amount) Write SQL DDL corresponding to the
schema. Make any reasonable assumptions about data types, and be sure to declare primary
and foreign keys.
create table employee (
driver_id varchar(20) primary key,
name varchar(50),
address varchar(100)
);
create table car (
license varchar(20) primary key,
model varchar(50),
year int
);
create table accident (
report_number int primary key,
date date,
location varchar(100)
);
create table owns (
driver_id varchar(20),
license varchar(20),
primary key (driver_id, license),
foreign key (driver_id) references employee(driver_id),
foreign key (license) references car(license)
);
create table participated (
report_number int,
license varchar(20),
driver_id varchar(20),
damage_amount numeric(12, 2),
primary key (report_number, license),
foreign key (report_number) references accident(report_number),
foreign key (license) references car(license),
foreign key (driver_id) references employee(driver_id)
);
3.14 Consider the insurance database in 3.13, where the primary keys are underlined.
Construct the following SQL queries for this relational database.
a. Find the number of accidents in which the cars belonging to “John Smith” were involved.
select count(distinct report_number)
from participated
where license in (
select license
from owns natural join employee
where name = 'John Smith'
);
b. Update the damage amount for the car with license number “AABB2000” in the accident
with report number “AR2197” to $3000.
update participated set damage_amount = 3000 where report_number = 'AR2197' and license =
'AABB2000';
3.17 Consider the relational database below.
employee (person_name, street, city)
works (person_name, company_name, salary)
company (company_name, city)
manages (person_name, manager_name)
Give an expression in SQL for each of the following queries.
a. Give all employees of First Bank Corporation a 10 percent raise.
update works set salary = salary * 1.10 where company_name = 'First Bank Corporation';
b. Give all managers of First Bank Corporation a 10 percent raise.
update works set salary = salary * 1.10 where company_name = 'First Bank Corporation' and
person_name in (select manager_name from manages);
c. Delete all tuples in the works relation for employees of Small Bank Corporation.
delete from works where company_name = 'Small Bank Corporation';