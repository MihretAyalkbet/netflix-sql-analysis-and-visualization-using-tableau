-- ############################################################
-- FILE: 01_netflix_data_setup.sql
-- PURPOSE: Clean and transform Netflix dataset for analysis
-- AUTHOR: Mihret Ayalkbet
-- DATE: 2025-09-26
-- ############################################################

-- Drop the table if it already exists
DROP TABLE IF EXISTS netflix_cleaned;

-- Create a cleaned Netflix table
CREATE TABLE netflix_cleaned AS
SELECT DISTINCT
    -- Clean Title (remove extra spaces)
    TRIM(Title) AS Title,

    -- Type (Movie / TV Show)
    TRIM(Type) AS Type,

    -- Clean Director & Cast, replace NULL with 'Unknown'
    TRIM(COALESCE(Director, 'Unknown')) AS Director,
    TRIM(COALESCE(Cast, 'Unknown')) AS Cast,

    -- Clean Country, replace NULL with 'Unknown'
    TRIM(COALESCE(Country, 'Unknown')) AS Country,

    -- Clean Rating (uppercase, replace spaces with '-')
    COALESCE(
        CASE 
            WHEN Rating IS NULL OR Rating = '' THEN 'Unknown'
            ELSE UPPER(TRIM(REPLACE(Rating, ' ', '-')))
        END,
        'Unknown'
    ) AS Rating,

    -- Clean Date_Added, handle NULLs
    CAST(NULLIF(TRIM(Date_Added), '') AS DATE) AS Date_Added,
    EXTRACT(YEAR FROM CAST(NULLIF(TRIM(Date_Added), '') AS DATE)) AS Year_Added,

    -- Release Year
    Release_Year,

    -- Genre (original column = listed_in)
    TRIM(COALESCE(Genre, 'Unknown')) AS Genre,

    -- Duration split into number & type
    CASE 
        WHEN Duration LIKE '%Season%' THEN CAST(SUBSTRING(Duration FROM '([0-9]+)') AS INT)
        WHEN Duration LIKE '%min%' THEN CAST(SUBSTRING(Duration FROM '([0-9]+)') AS INT)
        ELSE NULL
    END AS Duration_Number,
    CASE
        WHEN Duration LIKE '%Season%' THEN 'Seasons'
        WHEN Duration LIKE '%min%' THEN 'Minutes'
        ELSE NULL
    END AS Duration_Type

FROM netflix_raw
WHERE Title IS NOT NULL -- remove rows without titles
ORDER BY Date_Added DESC;


