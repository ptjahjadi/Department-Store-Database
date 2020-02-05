SELECT first_name, last_name, department_name, job_title
FROM staff NATURAL JOIN jobs LEFT JOIN departments
ON staff.department_id = departments.department_id;


SELECT country_name, count(staff_id)
FROM countries LEFT JOIN locations 
ON countries.country_id = locations.country_id
LEFT JOIN (departments NATURAL JOIN staff)
On locations.location_id = departments.location_id
GROUP BY country_name
ORDER BY country_name;


SELECT first_name, last_name, DATEDIFF(job_history.end_date, job_history.start_date) AS duration, job_title
FROM staff INNER JOIN job_history NATURAL JOIN jobs
ON staff.job_id = job_history.job_id
ORDER BY duration
LIMIT 1;

#Probably one of the better GROUP BY explanations I can find 
#Think of it as combining things with the same parameters together given the conditions
#https://www.essentialsql.com/get-ready-to-learn-sql-server-6-group-and-summarize-your-results/

SELECT supervisor.first_name, supervisor.last_name, job_title, COUNT(supervised.supervisor_ID) as num_supervised
FROM staff supervised INNER JOIN staff supervisor NATURAL JOIN jobs
ON supervised.supervisor_ID = supervisor.staff_ID
GROUP BY supervisor.first_name, supervisor.last_name, jobs.job_title, supervisor.staff_id
HAVING COUNT(supervised.supervisor_ID) >= 5;


# Question 5
# note: one staff is not associated to a departmnet (id: 178)

# part 1 = no manager
SELECT department_name
FROM departments
where manager_id IS NULL;

select distinct department_name, department_id from departments natural join staff;

# part 2 = no staff
select * from departments where department_name NOT IN (select department_name from departments inner join staff on departments.department_id = staff.department_id);

select * from staff where department_id=260;

select * from staff;

select * from (
	(SELECT department_name, department_id
	FROM departments
	where manager_id IS NULL
    ) a
    NATURAL JOIN
    (select department_name, department_id from departments where department_name NOT IN (select department_name from departments natural join staff))b 
);

SELECT department_name
FROM departments
WHERE (manager_id IS NULL
AND department_name NOT IN (select department_name from departments natural join staff));

# Question 6
select region_name, count(region_name) as num_locations
FROM regions INNER JOIN countries
ON regions.region_id = countries.region_id
INNER JOIN locations
ON countries.country_id = locations.country_id
GROUP BY region_name
ORDER BY count(region_name) DESC
LIMIT 1;

# Question 7
SELECT first_name, last_name, (salary * commission_pct + salary - max_salary) as exceed
FROM staff INNER JOIN jobs
ON staff.job_id = jobs.job_id
WHERE (salary * commission_pct + salary - max_salary) > 0
ORDER BY (salary * commission_pct + salary - max_salary) DESC;

# Question 8a
SELECT city, country_name, region_name
FROM regions INNER JOIN countries
ON regions.region_id = countries.region_id
INNER JOIN locations
ON countries.country_id = locations.country_id
WHERE NOT (countries.country_name = 'United States of America'
OR regions.region_name = 'Europe');

# Question 8b

#Consider this later from below.
SELECT location_id FROM (locations NATURAL JOIN departments NATURAL JOIN staff);

# This is the code to answer Question 8b
SELECT city, country_name, region_name
FROM regions LEFT JOIN countries
ON regions.region_id = countries.region_id
LEFT JOIN locations
ON countries.country_id = locations.country_id
WHERE NOT((country_name = 'United States of America'
OR region_name = 'Europe')
OR locations.location_id IN (SELECT location_id FROM (locations NATURAL JOIN departments NATURAL JOIN staff)));


SELECT city, country_name, region_name


SELECT department_name, department_id, num, 
FROM
(
SELECT departments.department_name, departments.department_id, count(staff_id) as num
FROM staff LEFT JOIN departments
ON staff.department_id = departments.department_id
GROUP BY departments.department_id
UNION
SELECT departments.department_name, departments.department_id, count(staff_id) as num
FROM staff RIGHT JOIN departments
ON staff.department_id = departments.department_id
GROUP BY departments.department_id
) a
WHERE num = 0;

# Question 9
SELECT job_title, end_date, first_name, last_name
FROM job_history INNER JOIN departments
ON departments.department_id = job_history.department_id
INNER JOIN staff
ON departments.manager_id = staff.staff_id
INNER JOIN jobs
ON jobs.job_id = job_history.job_id
WHERE EXTRACT(YEAR FROM end_date) = 2006
AND manager_id NOT IN (SELECT staff_id FROM staff where staff.first_name = 'Steven' AND staff.last_name = 'King');

SELECT jobs.job_title, job_history.end_date, supervised.first_name, supervised.last_name, manager_id
FROM staff supervised INNER JOIN staff supervisor
ON supervised.supervisor_id = supervisor.staff_id 
INNER JOIN job_history
ON supervised.staff_id = job_history.staff_id
INNER JOIN jobs
ON job_history.job_id = jobs.job_id
INNER JOIN departments
ON job_history.department_id = departments.department_id
WHERE EXTRACT(YEAR FROM end_date) = 2006
AND manager_id NOT IN (SELECT staff_id FROM staff where staff.first_name = 'Steven' AND staff.last_name = 'King');

SELECT *
FROM (
SELECT jobs.job_title, job_history.end_date, supervised.first_name, supervised.last_name, manager_id
FROM staff supervised INNER JOIN staff supervisor
ON supervised.supervisor_id = supervisor.staff_id 
INNER JOIN job_history
ON supervised.staff_id = job_history.staff_id
INNER JOIN jobs
ON job_history.job_id = jobs.job_id
INNER JOIN departments
ON job_history.department_id = departments.department_id
WHERE EXTRACT(YEAR FROM end_date) = 2006) a
WHERE a.manager_id NOT IN (SELECT staff_id FROM staff where staff.first_name = 'Steven' AND staff.last_name = 'King');

SELECT manager_id FROM staff where staff.first_name = 'Steven' AND staff.last_name = 'King';


SELECT job_title, end_date, `mngmt fn`, `mngmt ln`
FROM(
SELECT jobs.job_title, job_history.end_date, staff.first_name, staff.last_name, manager_id
FROM staff INNER JOIN job_history
ON staff.staff_id = job_history.staff_id
INNER JOIN jobs
ON job_history.job_id = jobs.job_id
INNER JOIN departments
ON job_history.department_id = departments.department_id
WHERE EXTRACT(YEAR FROM end_date) = 2006) a
INNER JOIN
(SELECT supervised.first_name as 'mngmt fn', supervised.last_name as 'mngmt ln' , supervised.staff_id,  supervisor.staff_id as supervisorid
FROM staff supervised INNER join staff supervisor
ON supervised.supervisor_id = supervisor.staff_id
INNER JOIN departments
ON supervisor.staff_id = departments.manager_id
WHERE NOT (supervisor.first_name = 'Steven' AND supervisor.last_name = 'King') 
) b
ON a.manager_id = b.supervisorid;

# Question 10
SELECT first_name, last_name, salary
FROM staff INNER JOIN job_history
ON staff.staff_id = job_history.staff_id
INNER JOIN jobs
ON job_history.job_id = jobs.job_id
GROUP BY first_name, last_name, salary
HAVING (COUNT(end_date) > 1 AND (salary < AVG(max_salary)));

SELECT *
FROM job_history INNER JOIN staff
ON job_history.staff_id = staff.staff_id
INNER JOIN jobs
ON staff.staff_id = job_history.staff_id;


#8
SELECT city, country_name, region_name
FROM regions LEFT JOIN countries ON
regions.region_id = countries.region_id
LEFT JOIN locations ON
locations.country_id = countries.country_id
LEFT JOIN
(departments LEFT JOIN staff
ON departments.department_id = staff.department_id)
ON locations.location_id = departments.location_id
WHERE staff.department_id IS NULL
AND country_name != "United States of America" AND region_name != "Europe";














