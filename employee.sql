-- 1. Create a database named employee, then import data_science_team.csv proj_table.csv 
-- and emp_record_table.csv into the employee database from the given resources.

create database employee;

-- 2. Create an ER diagram for the given employee database.
-- created ER Diagram

alter table data_science_team
modify emp_id varchar(10) not null primary key,
modify first_name varchar(100) not null,
modify last_name varchar(100) not null,
modify gender char(1) not null,
modify role varchar(100) not null,
modify dept varchar(100) not null,
modify exp int not null,
modify country varchar(100) not null,
modify continent varchar(100) not null;

alter table emp_record_table
modify emp_id varchar(10) not null primary key,
modify first_name varchar(100) not null,
modify last_name varchar(100) not null,
modify gender char(1) not null,
modify role varchar(100) not null,
modify dept varchar(100) not null,
modify exp int not null,
modify country varchar(100) not null,
modify continent varchar(100) not null,
modify salary int not null,
modify emp_rating int not null,
modify manager_id varchar(10) null,
modify proj_id varchar(10) null;

alter table proj_table
modify proj_id varchar(10) not null primary key,
modify proj_name varchar(100) not null,
modify domain varchar(50) not null,
modify start_date date not null,
modify closure_date date not null,
modify dev_qtr varchar(10) not null,
modify status varchar(20) not null;


 -- 3. Write a query to fetch EMP_ID, FIRST_NAME, LAST_NAME, GENDER, and DEPARTMENT from the employee record table,
 -- and make a list of employees and details of their department.
 
SELECT 
    emp_id, first_name, last_name, gender, dept
FROM
    emp_record_table
ORDER BY emp_id;
 
 -- 4.	Write a query to fetch EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPARTMENT, and EMP_RATING if the EMP_RATING is: 
 -- ●	less than two
SELECT 
    emp_id, first_name, last_name, gender, dept, emp_rating
FROM
    emp_record_table
WHERE
    emp_rating < 2;

-- ●  greater than four 
SELECT 
    emp_id, first_name, last_name, gender, dept, emp_rating
FROM
    emp_record_table
WHERE
    emp_rating > 4;
    
--  ●  between two and four
SELECT 
    emp_id, first_name, last_name, gender, dept, emp_rating
FROM
    emp_record_table
WHERE
    emp_rating > 2 and emp_rating < 4;

-- 5.	Write a query to concatenate the FIRST_NAME and the LAST_NAME of employees in the Finance department 
-- from the employee table and then give the resultant column alias as NAME.

select concat(first_name," ",last_name) as Name
from emp_record_table where dept='Finance';


-- 6.	Write a query to list only those employees who have someone reporting to them. 
-- Also, show the number of reporters (including the President).

SELECT 
    m.emp_id, m.first_name, m.last_name, m.gender, m.role, COUNT(e.emp_id) AS num_reporters
FROM
    emp_record_table m
JOIN
    emp_record_table e ON m.emp_id = e.manager_id
GROUP BY
    m.emp_id, m.first_name, m.last_name, m.gender, m.role
ORDER BY 
    m.emp_id;
    

-- 7.	Write a query to list down all the employees from the healthcare and finance departments using union. Take data from the employee record table.

select * from emp_record_table where dept= 'Healthcare'
union
select * from emp_record_table where dept= 'Finance';

-- 8.	Write a query to list down employee details such as EMP_ID, FIRST_NAME, LAST_NAME, ROLE, DEPARTMENT, and EMP_RATING grouped by dept. 
-- Also include the respective employee rating along with the max emp rating for the department.

select emp_id, first_name, last_name, role, dept, emp_rating,
max(emp_rating) over (partition by dept) as max_emp_rating
from emp_record_table;

-- 9.	Write a query to calculate the minimum and the maximum salary of the employees in each role. Take data from the employee record table.
SELECT 
    emp_id, FIRST_NAME, LAST_NAME, role,salary, MIN(salary) AS min_salary, MAX(salary) AS max_salary
FROM
    emp_record_table
GROUP BY 
	emp_id, FIRST_NAME, LAST_NAME, role, salary
ORDER BY role;

-- 10.	Write a query to assign ranks to each employee based on their experience. Take data from the employee record table.
select emp_id, FIRST_NAME, LAST_NAME, role, dept, exp, rank() over (order by exp desc) as exp_rank from emp_record_table;


-- 11.	Write a query to create a view that displays employees in various countries whose salary is more than six thousand. Take data from the employee record table.

create view v_emp as
select * from emp_record_table where salary > 6000;

select * from v_emp;

-- 12.	Write a nested query to find employees with experience of more than ten years. Take data from the employee record table.

select emp_id, first_name, last_name, role, dept, exp from emp_record_table where emp_id in (select emp_id from emp_record_table where exp > 10);


-- 13.	Write a query to create a stored procedure to retrieve the details of the employees whose experience is more than three years. 
-- Take data from the employee record table.

USE `employee`;
DROP procedure IF EXISTS `emp_detail_exp`;

DELIMITER $$
USE `employee`$$
CREATE PROCEDURE `emp_detail_exp` ()
BEGIN
	select * from emp_record_table where exp > 3;
END$$

DELIMITER ;

call emp_detail_exp;


-- 14.	Write a query using stored functions in the project table to check whether 
-- the job profile assigned to each employee in the data science team matches the organization’s set standard.

USE `employee`;
DROP function IF EXISTS `employee`.`Org_set_std`;


DELIMITER $$
USE `employee`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `Org_set_std`(exp int) RETURNS varchar(50) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
	declare role varchar(50);
    if exp <= 2 then
		set role ='Junior Data Scientist';
	elseif exp> 2 and exp <= 5 then
		set role ='Associate Data Scientist';
	elseif exp> 5 and exp <= 10 then
		set role ='Senior Data Scientist';  
	elseif exp> 10 and exp <= 12 then
		set role ='Lead Data Scientist';  
	elseif exp> 12 and exp<= 16 then
		set role ='Manager';
	else 
		set role ='President';
	end if;
    
RETURN role;
END$$

DELIMITER ;



select org_set_std(exp), exp from emp_record_table order by  org_set_std(exp) asc;


-- 15.	Create an index to improve the cost and performance of the query to find the employee 
-- whose FIRST_NAME is ‘Eric’ in the employee table after checking the execution plan.

create index indx_first_name on emp_record_table (first_name);
SELECT * FROM emp_record_table WHERE first_name = 'Eric';

SHOW INDEX FROM emp_record_table;

-- 16.	Write a query to calculate the bonus for all the employees, based on their ratings and salaries (Use the formula: 5% of salary * employee rating).

SELECT 
    salary,
    emp_rating,
    ROUND((5 * salary * emp_rating) / 100, 2) AS Bonus
FROM
    emp_record_table;


-- 17.	Write a query to calculate the average salary distribution based on the continent and country. Take data from the employee record table.
SELECT continent, 
       country, 
       ROUND(AVG(salary), 2) AS avg_salary
FROM emp_record_table
GROUP BY continent, country;


