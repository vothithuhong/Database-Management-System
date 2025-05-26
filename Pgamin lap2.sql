SELECT current_user;

CREATE ROLE hradmin WITH LOGIN PASSWORD '123';

CREATE DATABASE hr OWNER hradmin;

CREATE SCHEMA hrschema AUTHORIZATION hradmin;

CREATE TABLE hrschema.department (
    dept_id SERIAL PRIMARY KEY,
    dept_name TEXT NOT NULL
);

CREATE TABLE hrschema.employee (
    emp_id SERIAL PRIMARY KEY,
    emp_name TEXT NOT NULL,
    dept_id INT REFERENCES hrschema.department(dept_id)
);

CREATE SCHEMA IF NOT EXISTS hrschema AUTHORIZATION hradmin;

CREATE TABLE hrschema.regions (
    region_id     INTEGER PRIMARY KEY,
    region_name   VARCHAR(50)
);

CREATE TABLE hrschema.countries (
    country_id    CHAR(2) PRIMARY KEY,
    country_name  VARCHAR(40),
    region_id     INTEGER REFERENCES hrschema.regions(region_id)
);

CREATE TABLE hrschema.locations (
    location_id     INTEGER PRIMARY KEY,
    street_address  VARCHAR(100),
    postal_code     VARCHAR(20),
    city            VARCHAR(50),
    state_province  VARCHAR(50),
    country_id      CHAR(2) REFERENCES hrschema.countries(country_id)
);

CREATE TABLE hrschema.departments (
    department_id   INTEGER PRIMARY KEY,
    department_name VARCHAR(50),
    location_id     INTEGER REFERENCES hrschema.locations(location_id)
);

CREATE TABLE hrschema.jobs (
    job_id      VARCHAR(10) PRIMARY KEY,
    job_title   VARCHAR(50),
    min_salary  NUMERIC,
    max_salary  NUMERIC
);

CREATE TABLE hrschema.employees (
    employee_id   INTEGER PRIMARY KEY,
    first_name    VARCHAR(50),
    last_name     VARCHAR(50),
    email         VARCHAR(100),
    phone_number  VARCHAR(30),
    hire_date     DATE,
    job_id        VARCHAR(10) REFERENCES hrschema.jobs(job_id),
    salary        NUMERIC,
    manager_id    INTEGER REFERENCES hrschema.employees(employee_id),
    department_id INTEGER REFERENCES hrschema.departments(department_id)
);

CREATE TABLE hrschema.job_history (
    employee_id   INTEGER,
    start_date    DATE,
    end_date      DATE,
    job_id        VARCHAR(10),
    department_id INTEGER,
    PRIMARY KEY (employee_id, start_date),
    FOREIGN KEY (employee_id) REFERENCES hrschema.employees(employee_id),
    FOREIGN KEY (job_id) REFERENCES hrschema.jobs(job_id),
    FOREIGN KEY (department_id) REFERENCES hrschema.departments(department_id)
);

SELECT UPPER(SUBSTRING(first_name FROM 1 FOR 3)) AS first_name_upper3
FROM hrschema.employees;

SELECT TRIM(first_name) AS trimmed_first_name
FROM hrschema.employees;

SELECT first_name, last_name, LENGTH(first_name || last_name) AS full_name_length
FROM hrschema.employees;

SELECT first_name, last_name, ROUND(salary / 12.0, 2) AS monthly_salary
FROM hrschema.employees;

SELECT first_name, last_name, salary
FROM hrschema.employees
WHERE salary BETWEEN 10000 AND 15000;

SELECT first_name, last_name, department_id
FROM hrschema.employees
WHERE department_id IN (3, 10)
ORDER BY department_id ASC;

SELECT first_name, last_name, department_id, salary
FROM hrschema.employees
WHERE department_id IN (3, 10)
  AND salary NOT BETWEEN 10000 AND 15000;

SELECT first_name
FROM hrschema.employees
WHERE first_name ILIKE '%c%' AND first_name ILIKE '%e%';

SELECT last_name
FROM hrschema.employees
WHERE LENGTH(last_name) = 6;

SELECT first_name, last_name, salary, ROUND(salary * 0.15, 2) AS bonus_15_percent
FROM hrschema.employees;

SELECT SUM(salary) AS total_salary
FROM hrschema.employees;

SELECT 
    ROUND(MAX(salary), 2) AS max_salary,
    ROUND(MIN(salary), 2) AS min_salary,
    ROUND(AVG(salary), 2) AS avg_salary,
    COUNT(*) AS employee_count
FROM hrschema.employees;

SELECT DISTINCT j.job_id, j.job_title
FROM hrschema.jobs j
JOIN hrschema.employees e ON e.job_id = j.job_id
ORDER BY j.job_id;

SELECT MAX(salary) AS max_salary_programmer
FROM hrschema.employees e
JOIN hrschema.jobs j ON e.job_id = j.job_id
WHERE j.job_title = 'Programmer';

SELECT MAX(salary) - MIN(salary) AS salary_difference
FROM hrschema.employees;

SELECT DISTINCT e.employee_id, e.first_name, e.last_name
FROM hrschema.employees e
WHERE e.employee_id IN (
    SELECT DISTINCT manager_id
    FROM hrschema.employees
    WHERE manager_id IS NOT NULL
);

SELECT manager_id, MIN(salary) AS min_salary_under_manager
FROM hrschema.employees
WHERE manager_id IS NOT NULL
GROUP BY manager_id;

SELECT e.department_id, d.department_name, SUM(e.salary) AS total_salary
FROM hrschema.employees e
JOIN hrschema.departments d ON e.department_id = d.department_id
GROUP BY e.department_id, d.department_name
HAVING SUM(e.salary) > 30000
ORDER BY e.department_id;

SELECT e.first_name, e.last_name, j.job_title, e.salary
FROM hrschema.employees e
JOIN hrschema.jobs j ON e.job_id = j.job_id
WHERE j.job_title NOT IN ('Programmer', 'Shipping Clerk')
  AND e.salary NOT IN (4500, 10000, 15000);

SELECT department_id, ROUND(AVG(salary), 2) AS avg_salary
FROM hrschema.employees
GROUP BY department_id
HAVING COUNT(*) > 5;

SELECT j.job_title, ROUND(AVG(e.salary), 2) AS avg_salary
FROM hrschema.employees e
JOIN hrschema.jobs j ON e.job_id = j.job_id
GROUP BY j.job_title;

SELECT m.first_name || ' ' || m.last_name AS manager_name,
       d.department_name,
       l.city
FROM hrschema.employees m
JOIN hrschema.departments d ON m.employee_id = d.manager_id
JOIN hrschema.locations l ON d.location_id = l.location_id;

SELECT j.job_title, e.first_name || ' ' || e.last_name AS employee_name,
       e.salary - (SELECT MIN(salary) FROM hrschema.employees) AS salary_diff
FROM hrschema.employees e
JOIN hrschema.jobs j ON e.job_id = j.job_id
ORDER BY salary_diff DESC
LIMIT 3;





