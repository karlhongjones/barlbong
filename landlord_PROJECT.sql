DROP TABLE IF EXISTS landlord;

CREATE TABLE landlord (
    case_number INTEGER,
    city CHARACTER VARYING,
    zip CHARACTER VARYING,
    filed_date DATE,
    closed_date DATE,
    case_type CHARACTER VARYING,
    type_of_complaint TEXT,
    case_disposition TEXT,
    location CHARACTER VARYING
);

COPY landlord(case_number, city, zip, filed_date, closed_date, case_type, type_of_complaint, case_disposition, location)
FROM 'C:/Users/karlh/Desktop/PostgreSQL/Housing_Landlord-Tenant_Disputes_Cleaned.csv'
DELIMITER ','
CSV HEADER;

SELECT * FROM landlord;



1. Total Number of Cases by Year: Calculate the total number of cases filed each year.

SELECT 
	COUNT(case_number) AS cases_no,
	EXTRACT(YEAR FROM filed_date) AS year
FROM landlord
GROUP BY year
ORDER BY year DESC;

Cases Filed in Cities with High Population:
Find all the cases (case_number, city, filed_date) from the landlord table that were filed in cities with a population greater than 100,000. 
	

	
2. Average Duration of Resolved Cases by City: Calculate the average duration of resolved cases for each city.

SELECT
	ROUND(AVG(EXTRACT(EPOCH FROM (CAST(closed_date AS TIMESTAMP) - CAST(filed_date AS TIMESTAMP))) / 86400)) AS avg_duration_days,
	city
FROM landlord
WHERE closed_date IS NOT NULL
	AND filed_date IS NOT NULL
GROUP BY city
ORDER BY avg_duration_days DESC;
	
	

	
3. Top 5 Cities with Most Pending Cases: Find the top 5 cities with the highest number of pending cases.

SELECT 
    city,
    COUNT(*) AS pending_cases
FROM landlord
WHERE closed_date IS NULL
GROUP BY city
ORDER BY pending_cases DESC
LIMIT 5;




4. Show the distribution of different case types in each city as well at the most common case type.

SELECT city, case_type
FROM landlord
WHERE (city, case_type) IN (
    SELECT city, case_type
    FROM landlord
    GROUP BY city, case_type
    HAVING COUNT(*) = (
        SELECT MAX(case_count)
        FROM (
            SELECT city, case_type, COUNT(*) AS case_count
            FROM landlord
            GROUP BY city, case_type
        ) AS counts
        WHERE counts.city = landlord.city
    )
);

	
5. Percentage of Resolved Cases by Year: Calculate the percentage of resolved cases for each year.

SELECT
	COUNT(closed_date) * 100 / COUNT(*) AS percent_resolved_case,
	EXTRACT(YEAR FROM closed_date) AS year
FROM landlord
WHERE closed_date IS NULL
	OR closed_date IS NOT NULL
GROUP BY year;

	
6 . Cases Resolved Within 30 Days: Calculate the number of cases that were resolved within 30 days of being filed.

SELECT 
    COUNT(*) AS case_resolved_30_days,
	EXTRACT(YEAR FROM filed_date) AS year
FROM 
    landlord
WHERE 
    closed_date IS NOT NULL 
    AND EXTRACT(DAY FROM AGE(closed_date, filed_date)) <= 30
GROUP BY year
ORDER BY year DESC;


	
7. Correlation between Zip Code and Case Type: Analyze if there is any correlation between zip codes and types of cases.

SELECT
	COUNT(*) AS case_no,
	zip,
	case_type
FROM landlord
GROUP BY zip, case_type
ORDER BY zip, case_type;



8. Create a sentence using concatenations

SELECT
	'Case number ' 
	|| case_number 
	|| ' from city ' 
	|| city 
	|| ' with the zip of ' 
	|| zip 
	|| ' filed their case on '
	|| filed_date
	|| ' and was resolved on '
	|| closed_date
	|| '.' AS sentence
FROM landlord

# Finding cases with missing case types

SELECT 
	COALESCE(case_type, 'Unknown') case_type_missing,
	case_number
FROM landlord
WHERE case_type IS NULL
GROUP BY case_number, case_type_missing;
	
	


