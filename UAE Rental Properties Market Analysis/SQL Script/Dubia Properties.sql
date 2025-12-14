-- TABLE CREATION
CREATE TABLE Dubia_Properties (
	Address	Text,
	Rent Int,
	Bedroom Int,
	Bathroom Int,
	Type Varchar,
	Category Varchar,
	Area_in_sqft float,
	Rent_per_sqft float,
	Rent_category Varchar,
	Frequency Varchar,
	Furnishing Varchar,
	Purpose Varchar,
	Posted_date Date,
	Age_of_listing_in_days Int,
	Location Varchar,
	City Varchar,
	Latitude Float,
	Longitude Float

)

SELECT * FROM Dubia_Properties

-- DATA VALIDATION
-- Check for nulls in critical columns
SELECT
    COUNT(*) FILTER (WHERE Rent IS NULL) AS Missing_Rent,
    COUNT(*) FILTER (WHERE Area_in_sqft IS NULL) AS Missing_Area,
    COUNT(*) FILTER (WHERE City IS NULL) AS Missing_City
FROM Dubia_Properties;

-- Check for impossible values
SELECT *
FROM Dubia_Properties
WHERE Rent <= 0 OR Area_in_sqft <= 0;


-- GENERAL OVERVIEW

-- Total number of listings in the dataset.
SELECT COUNT(*) AS Total_Listing 
FROM Dubia_Properties

-- Number of listings per city.
SELECT City, 
	COUNT(*) AS Total_Number_of_Listing,
	ROUND( (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Dubia_Properties)), 2) AS Percentage
FROM Dubia_Properties
GROUP BY City
ORDER BY Total_Number_of_Listing DESC

-- Count of listings by category.
SELECT Type,
	COUNT(*) AS Total_Number_of_Listing,
	ROUND( (COUNT(*) * 100.0 / (SELECT COUNT (*) FROM Dubia_Properties)), 2) AS Percentage
FROM Dubia_Properties
GROUP BY Type
ORDER BY Total_Number_of_Listing DESC

-- Count of listings by property category.
SELECT Category, 
	COUNT(*) AS Total_Number_of_Listing,
	ROUND( (COUNT(*) * 100.0 / (SELECT COUNT (*) FROM Dubia_Properties)), 2) AS Percentage
FROM Dubia_Properties
GROUP BY Category
ORDER BY Total_Number_of_Listing DESC

-- Count of listings by furnishing status (Furnished vs Unfurnished).
SELECT Furnishing, 
	COUNT(*) AS Total_Number_of_Listing,
	ROUND( (COUNT(*) * 100.0 / (SELECT COUNT (*) FROM Dubia_Properties)), 2) AS Percentage
FROM Dubia_Properties
GROUP BY Furnishing
ORDER BY Total_Number_of_Listing DESC


--RENT ANALYSIS

-- Average, minimum, and maximum rent overall.
SELECT AVG(Rent) AS Average_Rent, MIN(Rent) AS Minimum_Rent, MAX(Rent) AS Maximum_Rent
From Dubia_Properties

-- Average, minimum, and maximum rent per city.
SELECT City,
	AVG(Rent) AS Average_Rent, MIN(Rent) AS Minimum_Rent, MAX(Rent) AS Maximum_Rent
FROM Dubia_Properties
GROUP BY City
ORDER BY Average_Rent DESC

-- Average rent per sqft per city.
SELECT City, COUNT(*),
	ROUND(CAST (AVG(Rent_per_sqft)AS Decimal),2) AS Average_Rent_Per_Sqft
FROM Dubia_Properties
GROUP BY City
ORDER BY Average_Rent_Per_Sqft

-- Number of listings in each rent category (Low, Medium, High).
SELECT Rent_Category,
	COUNT(*) AS Total_Listing,
	ROUND( (COUNT(*) * 100 / (SELECT COUNT(*) FROM Dubia_Properties)),2) AS Percentage
FROM Dubia_Properties
GROUP BY Rent_Category
ORDER BY Total_Listing DESC

-- Identify outlier listings with extremely high or low rents.
-- High Outlier
SELECT City, Type, Rent, Rent_per_sqft, 'High Outlier' As Outlier_Type
FROM Dubia_Properties
WHERE Rent > (SELECT AVG(Rent) * 1.5 FROM Dubia_Properties)
ORDER BY Rent DESC;

-- Low Outlier
SELECT City, Type, Rent, Rent_per_sqft, 'Low Outlier' As Outlier_Type
FROM Dubia_Properties
WHERE  Rent < (SELECT AVG(Rent) * 0.5 FROM Dubia_Properties)
ORDER BY Rent ASC;


-- PROPERTY FEATURES

-- How rent varies with number of bedrooms.
SELECT Bedroom, COUNT(*) AS Total_Listing,
	ROUND( AVG(Rent),2) AS Average_Rent,
	ROUND( (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Dubia_Properties)), 2) AS Percentage
FROM Dubia_Properties
GROUP BY Bedroom
ORDER BY Average_Rent DESC

-- How rent varies with number of bathrooms.
SELECT Bathroom, COUNT(*) AS Total_Listing,
	ROUND( AVG(Rent),2) AS Average_Rent,
	ROUND( (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Dubia_Properties)), 2) AS Percentage
FROM Dubia_Properties
GROUP BY Bathroom
ORDER BY Average_Rent DESC

-- Average rent by property category (Apartment, Villa, Residential).
SELECT Category, COUNT(*) As Total_Listing,
	ROUND( AVG(Rent),2) AS Average_Rent,
	ROUND( (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Dubia_Properties)),2) AS Percentage
FROM Dubia_Properties
GROUP BY Category
ORDER BY Average_Rent

-- Average rent per sqft by property category.
SELECT Category,
	ROUND(CAST (AVG(Rent_Per_sqft)AS Decimal), 2) AS Average_Rent_Per_Sqft,
	ROUND( (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Dubia_Properties)),2) AS Percentage
FROM Dubia_Properties
GROUP BY Category
ORDER BY Average_Rent_Per_Sqft DESC;

-- Distribution of property sizes (area_in_sqft).
SELECT 
  CASE 
    WHEN Area_in_sqft <= 500 THEN '0-500'
    WHEN Area_in_sqft <= 1000 THEN '501-1000'
    WHEN Area_in_sqft <= 1500 THEN '1001-1500'
    ELSE '1501+' 
  END AS Size_Range,
  COUNT(*) AS Total_Listing,
  ROUND(AVG(Area_in_sqft)::numeric) AS Average_Area_in_Range,
  MIN(Area_in_sqft) AS Min_Area_in_Range,
  MAX(Area_in_sqft) AS Max_Area_in_Range
FROM Dubia_Properties
GROUP BY Size_Range
ORDER BY Size_Range;

-- Average rent per city
SELECT City, Bedroom, COUNT(*) AS Total_Listing, 
	ROUND(AVG(Rent),2) AS Average_Rent,
	ROUND( (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Dubia_Properties)),2) AS Percentage
FROM Dubia_Properties
GROUP BY City, Bedroom
ORDER BY City, Average_Rent DESC;

-- TIME BASED INSIGHTS

-- Number of listings posted per month.
SELECT 
    TRIM(TO_CHAR(Posted_date::date, 'Month')) AS Month,
    COUNT(*) AS Total_Listings,
	ROUND(CAST (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Dubia_Properties) AS Decimal),2) AS Percentage
FROM Dubia_Properties
GROUP BY TRIM(TO_CHAR(Posted_date::date, 'Month')), EXTRACT(MONTH FROM Posted_date::date)
ORDER BY EXTRACT(MONTH FROM Posted_date::date);

-- Average age of listings (age_of_listing_in_days) overall and per city.
SELECT City, COUNT(*),
	ROUND(CAST (AVG(Age_of_listing_in_days) AS Decimal),2) AS Average_Age_of_Listing_in_days
FROM Dubia_Properties
GROUP BY City
ORDER BY Average_Age_of_Listing_in_days DESC

-- Are older listings priced differently than newer listings?
SELECT
	CASE
		WHEN Age_of_listing_in_days <= 30 THEN	'0–1 month'
		WHEN Age_of_listing_in_days <= 90 THEN '1–3 months'
		WHEN Age_of_listing_in_days <= 180 THEN '3–6 months'
		WHEN Age_of_listing_in_days <= 365 THEN '6–12 months'
		WHEN Age_of_listing_in_days <= 730 THEN '1–2 years'
		WHEN Age_of_listing_in_days <= 1095 THEN '2–3 years'
		WHEN Age_of_listing_in_days <= 1825 THEN '3–5 years'
		ELSE '5+ years'
	END AS Age_of_Listing,
 	COUNT(*) AS Total_Listing,
	ROUND(CAST (AVG(Rent) AS Decimal),2),
	ROUND(CAST (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Dubia_Properties) AS Decimal),2) AS Percentage
FROM Dubia_Properties
GROUP BY Age_of_Listing
ORDER BY Total_Listing DESC


-- LOCATION AND CITY INSIGHTS

-- Which city has the highest average rent per sqft?
SELECT City, COUNT(*),
	ROUND(CAST (AVG(Rent_per_sqft)AS Decimal),2) AS Average_Rent_Per_Sqft
FROM Dubia_Properties
GROUP BY City
ORDER BY Average_Rent_Per_Sqft

--Top 5 most expensive properties per city (by rent).
SELECT *
FROM (
    SELECT ROW_NUMBER() OVER (PARTITION BY City ORDER BY Rent DESC) AS rank,
		City, Location, Type, Rent, Bedroom, Bathroom, Rent_per_sqft
    FROM Dubia_Properties
) AS ranked
WHERE rank <= 5
ORDER BY City, Rent DESC;

