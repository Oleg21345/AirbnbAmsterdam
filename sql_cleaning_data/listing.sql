DELETE FROM airbnb.listings
WHERE latitude NOT BETWEEN 52.28 AND 52.42
   OR longitude NOT BETWEEN 4.73 AND 5.05;


CREATE TABLE airbnb.listings_staging (
  LIKE airbnb.listings
);


INSERT INTO airbnb.listings_staging
SELECT *
FROM airbnb.listings;



WITH duplicate_cte AS (
  SELECT *,
         ROW_NUMBER() OVER (PARTITION BY host_id, latitude, longitude, neighbourhood) AS row_num
  FROM airbnb.listings_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;


CREATE TABLE airbnb.listings_staging_2 (
    id BIGINT,
    name TEXT,
    host_id BIGINT,
    host_name TEXT,
    neighbourhood_group TEXT,
    neighbourhood TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    room_type TEXT,
    price NUMERIC,
    minimum_nights INTEGER,
    number_of_reviews INTEGER,
    last_review DATE,
    reviews_per_month DOUBLE PRECISION,
    calculated_host_listings_count INTEGER,
    availability_365 INTEGER,
    number_of_reviews_ltm INTEGER,
    license TEXT,
    row_num INT
);



INSERT INTO airbnb.listings_staging_2
    SELECT *, ROW_NUMBER() OVER (PARTITION BY host_id, latitude, longitude, neighbourhood)
          FROM airbnb.listings_staging;


DELETE FROM airbnb.listings_staging_2
WHERE row_num > 1;

UPDATE airbnb.listings_staging_2
SET host_name = TRIM(host_name),
neighbourhood = REGEXP_REPLACE(
        TRIM(INITCAP(LOWER(neighbourhood))),
        E'\\s*-\\s*',
        '-',
        'g');

DELETE FROM airbnb.listings_staging_2
WHERE price IS NULL;


SELECT *
FROM airbnb.listings_staging_2
WHERE number_of_reviews = 0
  AND last_review IS NOT NULL;


SELECT DISTINCT room_type
FROM airbnb.listings_staging_2;


SELECT
  PERCENTILE_CONT(0.01) WITHIN GROUP (ORDER BY price) AS p01,
  PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY price) AS p99
FROM airbnb.listings_staging_2;


SELECT MIN(calculated_host_listings_count)
FROM airbnb.listings_staging_2;


CREATE OR REPLACE VIEW airbnb.listings_enriched AS
SELECT
  id,
  host_id,
  price,
  CASE
    WHEN price < 67 THEN 'Very Low'
    WHEN price BETWEEN 67 AND 150 THEN 'Low'
    WHEN price BETWEEN 151 AND 300 THEN 'Medium'
    WHEN price BETWEEN 301 AND 962 THEN 'High'
    ELSE 'Luxury'
  END AS price_category
FROM airbnb.listings_staging_2;


DROP TABLE IF EXISTS airbnb.listings_staging;

























































