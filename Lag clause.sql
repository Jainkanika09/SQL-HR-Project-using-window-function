create database laghr;
use laghr;


-- Scenario: Employee Attrition Tracking
create table employee_salary(
emp_id int ,
emp_name varchar(50),
department varchar(50),
month char(7),
salary int);

insert into employee_salary values
(101,'Aditi','HR','2025-01',45000),
(101,'Aditi','HR','2025-02',46000),
(101,'Aditi','HR','2025-03',47000),
(102,'Rohan','Finance','2025-02',55000),
(102,'Rohan','Finance','2025-02',55000),
(102,'Rohan','Finance','2025-03',56000);

/*
-- Particular employee’s previous month salary
--The difference in salary between months
*/
SELECT 
    emp_id,
    emp_name
    department,
    month,
    salary,
    LAG(salary, 1, 0) OVER (PARTITION BY emp_id ORDER BY month) AS prev_month_salary,
    salary - LAG(salary, 1, 0) OVER (PARTITION BY emp_id ORDER BY month) AS salary_change
FROM employee_salary
ORDER BY emp_id, month;

/*
 Scenario: Employee Salary Growth Tracking
Employee Attrition Tracking
*/

create table employee_attrition(
emp_id int ,
emp_name varchar(50),
Department varchar(50),
Status_date date,
Status Varchar(50));

insert into employee_attrition values
(101,'Aditi','HR','2024-01-10','joined'),
(101,'Aditi','HR','2025-09-05','resigned'),
(102,'Rohan','Finance','2023-09-05','joined'),
(102,'Rohan','Finance','2025-03-15','resigned'),
(103,'Neha','IT','2024-06-01','joined'),
(104,'Priya','IT','2024-08-10','resigned'),
(105,'Karan','HR','2025-01-15','joined');

/*
Find the joining date and resignation date for each employee
and calculate the total tenure (in days) between them.
*/

SELECT 
    emp_id,
    emp_name,
    department,
    status_date AS exit_date,
    LAG(status_date) OVER (PARTITION BY emp_id ORDER BY status_date) AS join_date,
    DATEDIFF(status_date, LAG(status_date) OVER (PARTITION BY emp_id ORDER BY status_date)) AS tenure_days
FROM employee_attrition
WHERE status = 'Resigned';

/*
Find the tenure (in days) for each resigned employee.
Calculate the average tenure per department.
Calculate the attrition rate per department.
*/

-- Step 1: Calculate Each Employee’s Tenure
WITH employee_tenure AS (
    SELECT 
        emp_id,
        emp_name,
        department,
        status_date AS exit_date,
        LAG(status_date) OVER (PARTITION BY emp_id ORDER BY status_date) AS join_date,
        DATEDIFF(status_date, LAG(status_date) OVER (PARTITION BY emp_id ORDER BY status_date)) AS tenure_days,
        status
    FROM employee_attrition
)
SELECT * 
FROM employee_tenure
WHERE status = 'Resigned';

-- Step 2: Calculate Average Tenure per Department
WITH employee_tenure AS (
    SELECT 
        emp_id,
        department,
        DATEDIFF(status_date, LAG(status_date) OVER (PARTITION BY emp_id ORDER BY status_date)) AS tenure_days,
        status
    FROM employee_attrition
)
SELECT 
    department,
    ROUND(AVG(tenure_days), 0) AS avg_tenure_days
FROM employee_tenure
WHERE status = 'Resigned'
GROUP BY department;

-- Step 3: Calculate Attrition Rate per Department
SELECT 
    department,
    COUNT(CASE WHEN status = 'Resigned' THEN 1 END) AS resigned_count,
    COUNT(CASE WHEN status = 'Joined' THEN 1 END) AS joined_count,
    ROUND(
        COUNT(CASE WHEN status = 'Resigned' THEN 1 END) * 100.0 / 
        COUNT(CASE WHEN status = 'Joined' THEN 1 END), 2
    ) AS attrition_rate_percent
FROM employee_attrition
GROUP BY department;




