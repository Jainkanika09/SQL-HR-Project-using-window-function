

# HR Data Analysis & Attrition Tracking with Advanced SQL

This repository contains a comprehensive SQL case study focusing on two critical HR data analysis scenarios: **Employee Salary Growth Tracking** and **Employee Attrition Analysis**.

It demonstrates the effective use of **SQL Window Functions (`LAG`)** and **Conditional Aggregation (`CASE` within `COUNT`)** to derive key HR metrics from raw transaction data.

## 💾 Data Model (Schema)

Two tables are used for this analysis:

### 1. `employee_salary`

Tracks monthly salary records for employees.

| Column | Data Type | Description |
| :--- | :--- | :--- |
| `emp_id` | INT | Unique employee identifier |
| `emp_name` | VARCHAR(50) | Employee's name |
| `department` | VARCHAR(50) | Employee's department |
| `month` | CHAR(7) | The year-month of the salary record (e.g., '2025-01') |
| `salary` | INT | The salary amount for that month |

### 2. `employee_attrition`

Tracks joining and resignation events for employees.

| Column | Data Type | Description |
| :--- | :--- | :--- |
| `emp_id` | INT | Unique employee identifier |
| `emp_name` | VARCHAR(50) | Employee's name |
| `department` | VARCHAR(50) | Employee's department |
| `status_date` | DATE | The date of the status change (joined or resigned) |
| `status` | VARCHAR(50) | The status of the event ('joined' or 'resigned') |

## 📈 Analysis 1: Employee Salary Growth Tracking

This analysis calculates the previous month's salary and the monthly change in salary for each employee.

### 🔑 Key Concept: `LAG` Window Function

The `LAG` function is used to access data from a preceding row within the same result set, defined by the `PARTITION BY` and `ORDER BY` clauses.

```sql
SELECT
    emp_id,
    emp_name,
    department,
    month,
    salary,
    -- Get the salary from the previous month for the same employee
    LAG(salary, 1, 0) OVER (PARTITION BY emp_id ORDER BY month) AS prev_month_salary,
    -- Calculate the difference between current and previous salary
    salary - LAG(salary, 1, 0) OVER (PARTITION BY emp_id ORDER BY month) AS salary_change
FROM employee_salary
ORDER BY emp_id, month;
```

## 📊 Analysis 2: Employee Tenure & Attrition Rate

This scenario involves a multi-step calculation to first determine individual employee tenure and then aggregate these findings to calculate departmental metrics.

### Step 1: Calculate Each Employee's Tenure

This step uses a Common Table Expression (`employee_tenure`) to calculate the join date, exit date, and total tenure in days for all employees.

```sql
WITH employee_tenure AS (
    SELECT
        emp_id,
        emp_name,
        department,
        status_date AS exit_date,
        -- Find the *previous* status date (which is the 'joined' date)
        LAG(status_date) OVER (PARTITION BY emp_id ORDER BY status_date) AS join_date,
        -- Calculate the difference in days between exit and join date
        DATEDIFF(status_date, LAG(status_date) OVER (PARTITION BY emp_id ORDER BY status_date)) AS tenure_days,
        status
    FROM employee_attrition
)
-- Filter the results to only show resigned employees with their tenure
SELECT *
FROM employee_tenure
WHERE status = 'resigned';
```

### Step 2: Calculate Average Tenure per Department

Using the results from the `employee_tenure` CTE, we calculate the average tenure (in days) for all resigned employees, grouped by department.

```sql
WITH employee_tenure AS (
    -- ... (Same CTE query as Step 1)
    SELECT
        emp_id, department, status_date, status,
        DATEDIFF(status_date, LAG(status_date) OVER (PARTITION BY emp_id ORDER BY status_date)) AS tenure_days
    FROM employee_attrition
)
SELECT
    department,
    ROUND(AVG(tenure_days), 0) AS avg_tenure_days
FROM employee_tenure
WHERE status = 'resigned'
GROUP BY department;
```

### Step 3: Calculate Attrition Rate per Department

This step calculates the departmental attrition rate using **Conditional Aggregation**. The rate is defined as:

$$\text{Attrition Rate} = \left(\frac{\text{Resigned Count}}{\text{Joined Count}}\right) \times 100$$

```sql
SELECT
    department,
    -- Count of employees whose final status is 'resigned'
    COUNT(CASE WHEN status = 'resigned' THEN 1 END) AS resigned_count,
    -- Count of employees who have 'joined' (denominator)
    COUNT(CASE WHEN status = 'joined' THEN 1 END) AS joined_count,
    -- Calculate the attrition rate percentage
    ROUND(
        COUNT(CASE WHEN status = 'resigned' THEN 1 END) * 100.0 /
        COUNT(CASE WHEN status = 'joined' THEN 1 END)
    , 2) AS attrition_rate_percent
FROM employee_attrition
GROUP BY department;```

### Final Attrition Rate Results

| department | resigned\_count | joined\_count | attrition\_rate\_percent |
| :--- | :--- | :--- | :--- |
| HR | 1 | 2 | 50.00 |
| Finance | 1 | 1 | 100.00 |
| IT | 1 | 1 | 100.00 |

https://jainkanika09.github.io/jainkanika09.git.io/
https://www.linkedin.com/in/kanika-jain-a46816228/
