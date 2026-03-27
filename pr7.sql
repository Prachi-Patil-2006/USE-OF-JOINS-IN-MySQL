/*
==============================================================
        LAB 7 – USE OF JOINS IN MySQL
* ------------------------------------------------------------
   STEP 1: CREATE A NEW DATABASE AND SWITCH TO IT
------------------------------------------------------------ */
CREATE DATABASE IF NOT EXISTS companyDB;   -- Create a new database named 'companyDB' if it doesn't exist
USE companyDB;                             -- Switch to the 'companyDB' database so all commands run inside it

/* ------------------------------------------------------------
   STEP 2: DROP OLD TABLES IF THEY EXIST (TO AVOID DUPLICATES)
------------------------------------------------------------ */
DROP TABLE IF EXISTS Employee;             -- Delete old Employee table if it exists
DROP TABLE IF EXISTS Department;           -- Delete old Department table if it exists

/* ------------------------------------------------------------
   STEP 3: CREATE THE 'Department' TABLE
------------------------------------------------------------ */
CREATE TABLE Department (
    dept_id INT PRIMARY KEY,               -- dept_id is the Primary Key (unique for each department)
    dept_name VARCHAR(50)                  -- dept_name stores department name as text
);

/* ------------------------------------------------------------
   STEP 4: CREATE THE 'Employee' TABLE
------------------------------------------------------------ */
CREATE TABLE Employee (
    emp_id INT PRIMARY KEY,                -- emp_id is the Primary Key (unique for each employee)
    emp_name VARCHAR(50),                  -- emp_name stores the employee’s name
    dept_id INT,                           -- dept_id is a Foreign Key referencing Department table
    salary DECIMAL(10,2),                  -- salary stores numeric data with 2 decimal points
    FOREIGN KEY (dept_id) REFERENCES Department(dept_id)  -- Establish relationship with Department
);

/* ------------------------------------------------------------
   STEP 5: INSERT SAMPLE DATA INTO 'Department'
------------------------------------------------------------ */
INSERT INTO Department VALUES
(1, 'HR'),                                 -- Department 1: Human Resources
(2, 'Finance'),                            -- Department 2: Finance
(3, 'IT'),                                 -- Department 3: Information Technology
(4, 'Marketing');                          -- Department 4: Marketing

/* ------------------------------------------------------------
   STEP 6: INSERT SAMPLE DATA INTO 'Employee'
------------------------------------------------------------ */
INSERT INTO Employee VALUES
(101, 'Alice', 1, 50000),                  -- Alice works in HR
(102, 'Bob', 2, 55000),                    -- Bob works in Finance
(103, 'Charlie', 3, 60000),                -- Charlie works in IT
(104, 'David', 3, 62000),                  -- David works in IT
(105, 'Eva', NULL, 45000);                 -- Eva does not belong to any department (NULL dept_id)

/* ------------------------------------------------------------
   STEP 7: VIEW THE DATA
------------------------------------------------------------ */
SELECT * FROM Department;                  -- Display all records from Department table
SELECT * FROM Employee;                    -- Display all records from Employee table


/* ============================================================
   INNER JOIN
   → Returns only rows that have matching values in both tables
============================================================ */
-- Syntax:
-- SELECT columns FROM table1
-- INNER JOIN table2 ON table1.column = table2.column;

SELECT e.emp_id, e.emp_name, d.dept_name
FROM Employee e                            -- 'e' is alias for Employee table
INNER JOIN Department d                    -- 'd' is alias for Department table
ON e.dept_id = d.dept_id;                  -- Condition: Match department IDs

-- OUTPUT:
-- Only employees who have a valid department ID will be displayed.
-- Eva is excluded because her dept_id is NULL.
--
-- +--------+----------+-----------+
-- | emp_id | emp_name | dept_name |
-- +--------+----------+-----------+
-- | 101    | Alice    | HR        |
-- | 102    | Bob      | Finance   |
-- | 103    | Charlie  | IT        |
-- | 104    | David    | IT        |
-- +--------+----------+-----------+


/* ============================================================
   LEFT OUTER JOIN
   → Returns all records from the left table (Employee)
     and matching records from the right (Department)
============================================================ */
SELECT e.emp_id, e.emp_name, d.dept_name
FROM Employee e
LEFT JOIN Department d                     -- Include all employees even if they don’t belong to a department
ON e.dept_id = d.dept_id;

-- OUTPUT:
-- Eva will appear with dept_name as NULL because she has no department.
--
-- +--------+----------+-----------+
-- | emp_id | emp_name | dept_name |
-- +--------+----------+-----------+
-- | 101    | Alice    | HR        |
-- | 102    | Bob      | Finance   |
-- | 103    | Charlie  | IT        |
-- | 104    | David    | IT        |
-- | 105    | Eva      | NULL      |
-- +--------+----------+-----------+


/* ============================================================
   RIGHT OUTER JOIN
   → Returns all records from the right table (Department)
     and matching ones from the left (Employee)
============================================================ */
SELECT e.emp_id, e.emp_name, d.dept_name
FROM Employee e
RIGHT JOIN Department d                    -- Include all departments even if they have no employees
ON e.dept_id = d.dept_id;

-- OUTPUT:
-- Marketing department will appear with NULL employee because no one is assigned to it.
--
-- +--------+----------+-----------+
-- | emp_id | emp_name | dept_name |
-- +--------+----------+-----------+
-- | 101    | Alice    | HR        |
-- | 102    | Bob      | Finance   |
-- | 103    | Charlie  | IT        |
-- | 104    | David    | IT        |
-- | NULL   | NULL     | Marketing |
-- +--------+----------+-----------+


/* ============================================================
   FULL OUTER JOIN (MySQL does not directly support it)
   → Use UNION of LEFT JOIN and RIGHT JOIN
============================================================ */
SELECT e.emp_id, e.emp_name, d.dept_name
FROM Employee e
LEFT JOIN Department d
ON e.dept_id = d.dept_id

UNION                                       -- Combines both sets (no duplicates)

SELECT e.emp_id, e.emp_name, d.dept_name
FROM Employee e
RIGHT JOIN Department d
ON e.dept_id = d.dept_id;

-- OUTPUT:
-- Combines all employees and departments including unmatched ones.
--
-- +--------+----------+-----------+
-- | emp_id | emp_name | dept_name |
-- +--------+----------+-----------+
-- | 101    | Alice    | HR        |
-- | 102    | Bob      | Finance   |
-- | 103    | Charlie  | IT        |
-- | 104    | David    | IT        |
-- | 105    | Eva      | NULL      |
-- | NULL   | NULL     | Marketing |
-- +--------+----------+-----------+


/* ============================================================
   CROSS JOIN
   → Returns all combinations of rows from both tables
     (Cartesian Product)
============================================================ */
SELECT e.emp_name, d.dept_name
FROM Employee e
CROSS JOIN Department d;

-- OUTPUT:
-- Every employee is paired with every department.
-- (5 employees × 4 departments = 20 rows)
--
-- +----------+-----------+
-- | emp_name | dept_name |
-- +----------+-----------+
-- | Alice    | HR        |
-- | Alice    | Finance   |
-- | Alice    | IT        |
-- | Alice    | Marketing |
-- | Bob      | HR        |
-- | ...      | ...       |
-- +----------+-----------+


/* ============================================================
   SELF JOIN
   → Joins a table to itself to compare rows within the same table
============================================================ */
SELECT e1.emp_name AS Employee, 
       e2.emp_name AS Colleague, 
       d.dept_name
FROM Employee e1                          -- First instance of Employee table
JOIN Employee e2                          -- Second instance of same table
ON e1.dept_id = e2.dept_id                -- Join where both employees share same department
AND e1.emp_id <> e2.emp_id                -- Exclude same employee comparison
JOIN Department d
ON e1.dept_id = d.dept_id;

-- OUTPUT:
-- Shows employees working in the same department.
--
-- +----------+-----------+-----------+
-- | Employee | Colleague | dept_name |
-- +----------+-----------+-----------+
-- | Charlie  | David     | IT        |
-- | David    | Charlie   | IT        |
-- +----------+-----------+-----------+


