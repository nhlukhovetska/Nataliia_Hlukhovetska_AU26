-- Drop the view if it already exists to ensure the script is re-runnable
DROP VIEW IF EXISTS sales_revenue_by_category_qtr;

-- Create the view
CREATE OR REPLACE VIEW sales_revenue_by_category_qtr AS
WITH current_date_info AS (
-- Dynamically determine the current year and quarter
SELECT
EXTRACT(YEAR FROM CURRENT_DATE)::INT AS current_year,
EXTRACT(QUARTER FROM CURRENT_DATE)::INT AS current_quarter
)
SELECT
c.name AS category,
SUM(p.amount) AS total_revenue
FROM
payment p
JOIN
rental r ON p.rental_id = r.rental_id
JOIN
inventory i ON r.inventory_id = i.inventory_id
JOIN
film_category fc ON i.film_id = fc.film_id
JOIN
category c ON fc.category_id = c.category_id
CROSS JOIN
current_date_info cdi
WHERE
EXTRACT(YEAR FROM p.payment_date) = cdi.current_year
AND EXTRACT(QUARTER FROM p.payment_date) = cdi.current_quarter
GROUP BY
c.name;

--Task 2. Create a query language function
-- Drop the function if it exists to ensure re-runnability
DROP FUNCTION IF EXISTS get_sales_revenue_by_category_qtr(INT, INT);

-- Create the function. We use PL/pgSQL here for the ability to raise exceptions.
CREATE OR REPLACE FUNCTION get_sales_revenue_by_category_qtr(
p_year INT,
p_quarter INT
)
RETURNS TABLE (
category VARCHAR,
total_revenue NUMERIC
) AS $$
BEGIN
-- Validate input quarter
IF p_quarter < 1 OR p_quarter > 4 THEN
RAISE EXCEPTION 'Invalid quarter: %. Quarter must be between 1 and 4.', p_quarter;
END IF;

-- Return the query result
RETURN QUERY
SELECT
c.name::VARCHAR AS category,
SUM(p.amount)::NUMERIC AS total_revenue
FROM
payment p
JOIN
rental r ON p.rental_id = r.rental_id
JOIN
inventory i ON r.inventory_id = i.inventory_id
JOIN
film_category fc ON i.film_id = fc.film_id
JOIN
category c ON fc.category_id = c.category_id
WHERE
EXTRACT(YEAR FROM p.payment_date) = p_year
AND EXTRACT(QUARTER FROM p.payment_date) = p_quarter
GROUP BY
c.name;
END;
$$ LANGUAGE plpgsql;

--Task 3. Create procedure language functions

DROP FUNCTION IF EXISTS most_popular_films_by_countries(TEXT[]);

CREATE OR REPLACE FUNCTION most_popular_films_by_countries(countries_array TEXT[])
RETURNS TABLE (
country VARCHAR,
film VARCHAR,
rating VARCHAR,
language VARCHAR,
length SMALLINT,
release_year SMALLINT
) AS $$
BEGIN
RETURN QUERY
WITH FilmRentals AS (
SELECT
co.country::VARCHAR,
f.title::VARCHAR AS film,
f.rating::VARCHAR,
l.name::VARCHAR AS language,
f.length,
f.release_year::smallint AS release_year,
COUNT(r.rental_id) AS rental_count,
-- Rank films per country by rental count. Ties are broken alphabetically by film title.
ROW_NUMBER() OVER(
PARTITION BY co.country
ORDER BY COUNT(r.rental_id) DESC, f.title ASC
) as rn
FROM
country co
JOIN city ci ON co.country_id = ci.country_id
JOIN address a ON ci.city_id = a.city_id
JOIN customer c ON a.address_id = c.address_id
JOIN rental r ON c.customer_id = r.customer_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
JOIN language l ON f.language_id = l.language_id
WHERE
co.country = ANY(countries_array)
GROUP BY
co.country, f.film_id, f.title, f.rating, l.name, f.length, f.release_year
)
SELECT
fr.country,
fr.film,
fr.rating,
fr.language,
fr.length,
fr.release_year
FROM
FilmRentals fr
WHERE
fr.rn = 1; -- Only take the top film per country
END;
$$ LANGUAGE plpgsql;

--Task 4. Create procedure language functions


DROP FUNCTION IF EXISTS films_in_stock_by_title(TEXT);

CREATE OR REPLACE FUNCTION films_in_stock_by_title(title_pattern TEXT)
RETURNS TABLE (
row_num BIGINT,
film_title VARCHAR,
language VARCHAR,
customer_name VARCHAR,
rental_date TIMESTAMP without time zone
) AS $$
DECLARE
match_count INT;
BEGIN
-- Check if any records match the pattern to provide a helpful notice
SELECT COUNT(*) INTO match_count
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
WHERE f.title ILIKE title_pattern AND r.return_date IS NULL;

IF match_count = 0 THEN
RAISE NOTICE 'No currently rented movies found matching pattern: %', title_pattern;
END IF;

RETURN QUERY
SELECT
ROW_NUMBER() OVER (ORDER BY r.rental_date DESC) AS row_num,
f.title::VARCHAR,
l.name::VARCHAR,
(c.first_name || ' ' || c.last_name)::VARCHAR AS customer_name,
r.rental_date::timestamp as rental_date
FROM
film f
JOIN language l ON f.language_id = l.language_id
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
JOIN customer c ON r.customer_id = c.customer_id
WHERE
f.title ILIKE title_pattern
AND r.return_date IS NULL; -- "In stock" here implies currently rented out as per the requested columns
END;
$$ LANGUAGE plpgsql;

--Task 5. Create procedure language functions
DROP FUNCTION IF EXISTS new_movie(VARCHAR, INT, VARCHAR);

CREATE OR REPLACE FUNCTION new_movie(
p_title VARCHAR,
p_release_year INT DEFAULT EXTRACT(YEAR FROM CURRENT_DATE)::INT,
p_language VARCHAR DEFAULT 'Klingon'
)
RETURNS void AS $$
DECLARE
v_language_id INT;
v_new_film_id INT;
BEGIN
-- 1. Prevent duplicates
IF EXISTS (SELECT 1 FROM film WHERE title = p_title) THEN
RAISE EXCEPTION 'Movie with title "%" already exists.', p_title;
END IF;
-- 2. Validate language existence (Insert if it doesn't exist to maintain consistency)
SELECT language_id INTO v_language_id FROM language WHERE name = p_language;

IF NOT FOUND THEN
INSERT INTO language (name) VALUES (p_language) RETURNING language_id INTO v_language_id;
END IF;

-- 3. Generate unique ID safely using the sequence (standard for dvdrental)
-- If sequence doesn't exist, use SELECT MAX(film_id) + 1 INTO v_new_film_id FROM film;
SELECT nextval('film_film_id_seq') INTO v_new_film_id;

-- 4. Insert the new movie
INSERT INTO film (
film_id, title, release_year, language_id, rental_duration, rental_rate, replacement_cost
) VALUES (
v_new_film_id, p_title, p_release_year, v_language_id, 3, 4.99, 19.99
);

EXCEPTION
WHEN OTHERS THEN
RAISE EXCEPTION 'Failed to insert movie. Error: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

