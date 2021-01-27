use employees;
select * from departments;

-- profiling dept_emp
select * from dept_emp;
update dept_emp set to_date='9999-01-01' where to_date='2000-01-01';
select max(to_date) from dept_emp;

select * from dept_emp
where to_date< from_date ;


create view my_view as
select emp_no, count(*) as duplicate from dept_emp group by emp_no having duplicate >1 order by duplicate  desc;

select  * from my_view join dept_emp on my_view.emp_no=dept_emp.emp_no;

select * from dept_emp where from_date='2002-08-01';

-- profiling dept_manager

select * from dept_manager;
update dept_manager set to_date='9999-01-01' where to_date='2000-01-01';
select min(from_date) from dept_manager;

select * from dept_manager
where to_date< from_date ; /*no probleme*/

-- profiling salaries

select * from salaries;

select from_date, count(*) as duplicate from salaries group by from_date having duplicate >1 order by duplicate  desc; /* compter duplicate from_date*/

select count(*) from salaries;

select min(to_date) from salaries;
select emp_no ,max(salary) as max from salaries group by emp_no order by max desc;


-- profiling titles
select * from titles;
select count(*) from titles;

select max(to_date) from titles;

-- profiling employees
select * from employees;
select count(*) from employees;
select min(hire_date) from employees;
select max(birth_date) from employees;

-- start queries
-- create view list_of_employees as 
select distinct concat(e.first_name ,' ', e.last_name) as 'Name',d.dept_name as 'Departments',t.title as 'Position',s.salary as 'Salary'
from employees e join salaries s on e.emp_no=s.emp_no 
join titles t on e.emp_no=t.emp_no
join dept_emp de on e.emp_no=de.emp_no
join departments d on de.dept_no=d.dept_no
join dept_manager dm on d.dept_no=dm.dept_no
where s.to_date='9999-01-01' /* still receive a salary so still in the company*/and t.to_date = '9999-01-01' /*last title job*/and de.to_date = '9999-01-01'/* last department*/
and d.dept_no = 'd009'
order by d.dept_no, e.last_name;

-- drop view list_of_employees;
drop view list_of_employees;
-- check duplicate
select emp_no, count(*) as duplicate from list_of_employees group by emp_no having duplicate >1 order by duplicate  desc;

select count(*) as 'number of duplicate'from (select emp_no, count(*) as duplicate from list_of_employees group by emp_no having duplicate >1 order by duplicate  desc) as duplicate_table;

-- check the last salary for max from date of salaries
select * from salaries where to_date ='9999-01-01' and from_date='2002-08-01'; 


-- test duplicate to understand
select * from dept_emp where emp_no = 34421;
select * from titles where emp_no = 34421;
select * from dept_manager where emp_no = 34421; 
select * from employees where emp_no = 34421;
select * from salaries where to_date = '9999-01-01' and from_date < '2001-08-01'; 
/*where emp_no = 34421*/
select *
from employees e join salaries s on e.emp_no=s.emp_no 
join titles t on e.emp_no=t.emp_no
join dept_emp de on e.emp_no=de.emp_no
join departments d on de.dept_no=d.dept_no
join dept_manager dm on d.dept_no=dm.dept_no
where e.emp_no = 34421
order by d.dept_no, e.last_name;
-- 


-- List of the average salary of employees in each job position (title)
select round(AVG(s.salary),0)  as 'Average Salary', t.title as 'Position'
from titles t join salaries s on t.emp_no=s.emp_no where s.to_date='9999-01-01' and t.to_date='9999-01-01'
group by t.title
order by  round(AVG(s.salary),0);
-- test 
-- pour ceux qui ont 2 departements, savoir auxquels départements ils appartiennent
select * from (select distinct e.emp_no,concat(e.first_name ,' ', e.last_name) as 'Name',d.dept_name as 'Departments',t.title as 'Position',s.salary as 'Salary'
from employees e join salaries s on e.emp_no=s.emp_no 
join titles t on e.emp_no=t.emp_no
join dept_emp de on e.emp_no=de.emp_no
join departments d on de.dept_no=d.dept_no
join dept_manager dm on d.dept_no=dm.dept_no
where s.to_date='9999-01-01' /* still receive a salary so still in the company*/and t.to_date = '9999-01-01' /*last title job*/and de.to_date = '9999-01-01'/* last department*/
/*and d.dept_no = 'd001'*/
order by d.dept_no, e.last_name) as dep join (select emp_no, count(*) as duplicate from list_of_employees group by emp_no having duplicate >1 order by duplicate  desc) as dup on dep.emp_no=dup.emp_no order by dep.emp_no;


#List of employees who change departments
SELECT *
FROM dept_emp
WHERE emp_no IN (SELECT emp_no
                    FROM dept_emp
                    GROUP BY emp_no
                    HAVING COUNT(emp_no) > 1)
ORDER BY emp_no, from_date;

SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));



-- test cecile

select e.emp_no, e.first_name, s.salary
from employees e
join salaries s
on e.emp_no=s.emp_no
where s.to_date='9999-01-01' and s.salary in (select min(salary) from salaries);

select avg(s.salary)
from employees e
join salaries s
on e.emp_no=s.emp_no
where s.to_date='9999-01-01'and e.gender='M';

Select 
emp_no as employees_no, 
first_name, 
last_name, 
hire_date 
from employees 
WHERE month(hire_date)=12 ; 




-- test murugesh 
Select retained.Year, retained.No_of_employees_hired,old.No_of_employees_hired_retained_now
from

(SELECT YEAR(E.hire_date) AS "Year", COUNT(DISTINCT E.emp_no) AS No_of_employees_hired
FROM employees E JOIN dept_emp DE USING(emp_no)
JOIN titles T USING(emp_no)
JOIN departments D ON D.dept_no=DE.dept_no
WHERE YEAR(E.hire_date)>1995
GROUP BY YEAR(E.hire_date)) as retained join

(SELECT YEAR(E.hire_date) AS "Year", COUNT(DISTINCT E.emp_no) AS No_of_employees_hired_retained_now
FROM employees E JOIN dept_emp DE USING(emp_no)
JOIN titles T USING(emp_no)
JOIN departments D ON D.dept_no=DE.dept_no
WHERE T.to_date='9999-01-01'and YEAR(E.hire_date)>1995
GROUP BY YEAR(E.hire_date)) as old 
on retained.year=old.year;

select *
from employees e join salaries s on e.emp_no=s.emp_no 
join titles t on e.emp_no=t.emp_no
join dept_emp de on e.emp_no=de.emp_no
join departments d on de.dept_no=d.dept_no
join dept_manager dm on d.dept_no=dm.dept_no
where year(e.hire_date)=2000;

-- check manager turnover

select * from dept_manager dm join departments d on dm.dept_no=d.dept_no join salaries s on dm.emp_no=s.emp_no
 order by dm.dept_no,dm.from_date,s.from_date;
 
 -- know when employee gonna retire
 
select distinct e.first_name, e.last_name,e.birth_date, year(e.birth_date)+62 as 'year retire'
from employees e join salaries s on e.emp_no=s.emp_no 
join titles t on e.emp_no=t.emp_no
join dept_emp de on e.emp_no=de.emp_no
join departments d on de.dept_no=d.dept_no
join dept_manager dm on d.dept_no=dm.dept_no
where s.to_date='9999-01-01' /* still receive a salary so still in the company*/and t.to_date = '9999-01-01' /*last title job*/and de.to_date = '9999-01-01'/* last department*/
;


