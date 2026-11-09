

--Add 3 favorite movies to the 'film' table and Fill in rental rates with 4.99, 9.99 and 19.99 and rental durations with 1, 2 and 3 weeks respectively.
INSERT INTO public.film (
title, description, release_year, language_id, rental_duration,
rental_rate, length, replacement_cost, rating, last_update
)
SELECT
'Titanic', 'A seventeen-year-old aristocrat falls in love with a kind but poor artist aboard the luxurious, ill-fated R.M.S. Titanic.', 1997,
(SELECT language_id FROM public.language WHERE name = 'English' LIMIT 1),
1, 4.99, 194, 19.99, 'PG-13', CURRENT_DATE
WHERE NOT EXISTS (
SELECT 1 FROM public.film WHERE title = 'Titanic' AND release_year = 1997
)
RETURNING film_id, title;

INSERT INTO public.film  (
title, description, release_year, language_id, rental_duration,
rental_rate, length, replacement_cost, rating, last_update
)
SELECT
'The Devil Wears Prada', 'A smart but sensible new graduate lands a job as an assistant to Miranda Priestly, the demanding editor-in-chief of a high fashion magazine.', 2006,
(SELECT language_id FROM public.language WHERE name = 'English' LIMIT 1),
2, 9.99, 109, 19.99, 'PG-13', CURRENT_DATE
WHERE NOT EXISTS (
SELECT 1 FROM public.film WHERE title = 'The Devil Wears Prada' AND release_year = 2006
)
RETURNING film_id, title;

INSERT INTO public.film (
title, description, release_year, language_id, rental_duration,
rental_rate, length, replacement_cost, rating, last_update
)
SELECT
'Inception', 'A thief who steals corporate secrets through the use of dream-sharing technology is given the inverse task of planting an idea into the mind of a C.E.O.', 2010,
(SELECT language_id FROM public.language WHERE name = 'English' LIMIT 1),
3, 19.99, 148, 19.99, 'PG-13', CURRENT_DATE
WHERE NOT EXISTS (
SELECT 1 FROM public.film WHERE title = 'Inception' AND release_year = 2010
)
RETURNING film_id, title;

--Add real actors to the 'actor' and 'film_actor' tables
-- Titanic Actors
INSERT INTO public.actor (first_name, last_name, last_update)
SELECT 'Leonardo', 'DiCaprio', CURRENT_DATE
WHERE NOT EXISTS (SELECT 1 FROM public.actor WHERE first_name = 'Leonardo' AND last_name = 'DiCaprio')
RETURNING actor_id;

INSERT INTO public.actor (first_name, last_name, last_update)
SELECT 'Kate', 'Winslet', CURRENT_DATE
WHERE NOT EXISTS (SELECT 1 FROM public.actor WHERE first_name = 'Kate' AND last_name = 'Winslet')
RETURNING actor_id;
-- The Devil Wears Prada Actors
INSERT INTO public.actor (first_name, last_name, last_update)
SELECT 'Meryl', 'Streep', CURRENT_DATE
WHERE NOT EXISTS (SELECT 1 FROM public.actor WHERE first_name = 'Meryl' AND last_name = 'Streep')
RETURNING actor_id;

INSERT INTO public.actor (first_name, last_name, last_update)
SELECT 'Anne', 'Hathaway', CURRENT_DATE
WHERE NOT EXISTS (SELECT 1 FROM public.actor WHERE first_name = 'Anne' AND last_name = 'Hathaway')
RETURNING actor_id;
-- Inception Actors
INSERT INTO public.actor (first_name, last_name, last_update)
SELECT 'Joseph', 'Gordon-Levitt', CURRENT_DATE
WHERE NOT EXISTS (SELECT 1 FROM public.actor WHERE first_name = 'Joseph' AND last_name = 'Gordon-Levitt')
RETURNING actor_id;

INSERT INTO public.actor (first_name, last_name, last_update)
SELECT 'Tom', 'Hardy', CURRENT_DATE
WHERE NOT EXISTS (SELECT 1 FROM public.actor WHERE first_name = 'Tom' AND last_name = 'Hardy')
RETURNING actor_id;

-- Titanic (Leonardo DiCaprio, Kate Winslet)
INSERT INTO public.film_actor (actor_id, film_id, last_update)
SELECT a.actor_id, f.film_id, CURRENT_DATE
FROM public.actor a, public.film f
WHERE a.first_name = 'Leonardo' AND a.last_name = 'DiCaprio'
AND f.title = 'Titanic'
AND NOT EXISTS (SELECT 1 FROM public.film_actor fa WHERE fa.actor_id = a.actor_id AND fa.film_id = f.film_id);

INSERT INTO public.film_actor (actor_id, film_id, last_update)
SELECT a.actor_id, f.film_id, CURRENT_DATE
FROM public.actor a, public.film f
WHERE a.first_name = 'Kate' AND a.last_name = 'Winslet'
AND f.title = 'Titanic'
AND NOT EXISTS (SELECT 1 FROM public.film_actor fa WHERE fa.actor_id = a.actor_id AND fa.film_id = f.film_id);

-- The Devil Wears Prada (Meryl Streep, Anne Hathaway)
INSERT INTO public.film_actor (actor_id, film_id, last_update)
SELECT a.actor_id, f.film_id, CURRENT_DATE
FROM public.actor a, public.film f
WHERE a.first_name = 'Meryl' AND a.last_name = 'Streep'
AND f.title = 'The Devil Wears Prada'
AND NOT EXISTS (SELECT 1 FROM public.film_actor fa WHERE fa.actor_id = a.actor_id AND fa.film_id = f.film_id);

INSERT INTO public.film_actor (actor_id, film_id, last_update)
SELECT a.actor_id, f.film_id, CURRENT_DATE
FROM public.actor a, public.film f
WHERE a.first_name = 'Anne' AND a.last_name = 'Hathaway'
AND f.title = 'The Devil Wears Prada'
AND NOT EXISTS (SELECT 1 FROM public.film_actor fa WHERE fa.actor_id = a.actor_id AND fa.film_id = f.film_id);

-- Inception (Leonardo DiCaprio, Joseph Gordon-Levitt, Tom Hardy)
INSERT INTO public.film_actor (actor_id, film_id, last_update)
SELECT a.actor_id, f.film_id, CURRENT_DATE
FROM public.actor a, public.film f
WHERE a.first_name = 'Leonardo' AND a.last_name = 'DiCaprio'
AND f.title = 'Inception'
AND NOT EXISTS (SELECT 1 FROM public.film_actor fa WHERE fa.actor_id = a.actor_id AND fa.film_id = f.film_id);

INSERT INTO public.film_actor (actor_id, film_id, last_update)
SELECT a.actor_id, f.film_id, CURRENT_DATE
FROM public.actor a, public.film f
WHERE a.first_name = 'Joseph' AND a.last_name = 'Gordon-Levitt'
AND f.title = 'Inception'
AND NOT EXISTS (SELECT 1 FROM public.film_actor fa WHERE fa.actor_id = a.actor_id AND fa.film_id = f.film_id);

INSERT INTO public.film_actor (actor_id, film_id, last_update)
SELECT a.actor_id, f.film_id, CURRENT_DATE
FROM public.actor a, public.film f
WHERE a.first_name = 'Tom' AND a.last_name = 'Hardy'
AND f.title = 'Inception'
AND NOT EXISTS (SELECT 1 FROM public.film_actor fa WHERE fa.actor_id = a.actor_id AND fa.film_id = f.film_id);

COMMIT;


--Add movies to any store's inventory
INSERT INTO public.inventory (film_id, store_id, last_update)
SELECT f.film_id, 1, CURRENT_DATE
FROM public.film f
WHERE f.title IN ('Titanic', 'The Devil Wears Prada', 'Inception')
AND NOT EXISTS (
SELECT 1 FROM public.inventory i
WHERE i.film_id = f.film_id AND i.store_id = 1
)
RETURNING inventory_id, film_id;

COMMIT;

--Find a customer with >= 43 rentals and payments.
SELECT c.customer_id, c.first_name, c.last_name, COUNT(DISTINCT r.rental_id) as rentals, COUNT(DISTINCT p.payment_id) as payments
FROM public.customer c
JOIN public.rental r ON c.customer_id = r.customer_id
JOIN public.payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(DISTINCT r.rental_id) >= 43 AND COUNT(DISTINCT p.payment_id) >= 43
LIMIT 1;

--Change  personal data to my
UPDATE public.customer
SET
    first_name = 'Nataliia',
    last_name = 'Hlukhovetska',
    email = 'nglukhovetska@gmail.com',
    address_id = 599,
    last_update = CURRENT_DATE
WHERE customer_id = (
    SELECT c.customer_id
    FROM public.customer AS c
    JOIN public.rental AS r
        ON c.customer_id = r.customer_id
    JOIN public.payment AS p
        ON c.customer_id = p.customer_id
    GROUP BY c.customer_id
    HAVING COUNT(DISTINCT r.rental_id) >= 43
       AND COUNT(DISTINCT p.payment_id) >= 43
    LIMIT 1
)
RETURNING customer_id, first_name, last_name;
COMMIT;

--Remove any records related to you (as a customer) from all tables except 'Customer' and 'Inventory'
-- SELECT check for Payments
SELECT * FROM public.payment
WHERE customer_id = (SELECT customer_id FROM public.customer WHERE first_name = 'Nataliia' AND last_name = 'Hlukhovetska' LIMIT 1);

-- Delete Payments
DELETE FROM public.payment
WHERE customer_id = (SELECT customer_id FROM public.customer WHERE first_name = 'Nataliia' AND last_name = 'Hlukhovetska' LIMIT 1)
RETURNING payment_id;

-- SELECT check for Rentals
SELECT * FROM public.rental
WHERE customer_id = (SELECT customer_id FROM public.customer WHERE first_name = 'Nataliia' AND last_name = 'Hlukhovetska' LIMIT 1);

-- Delete Rentals
DELETE FROM public.rental
WHERE customer_id = (SELECT customer_id FROM public.customer WHERE first_name = 'Nataliia' AND last_name = 'Hlukhovetska' LIMIT 1)
RETURNING rental_id;

COMMIT;

--Rent favorite movies and pay for them
--Insert into rental table
INSERT INTO public.rental (rental_date, inventory_id, customer_id, return_date, staff_id, last_update)
SELECT
CURRENT_DATE,
i.inventory_id,
c.customer_id,
CURRENT_DATE + INTERVAL '7 days', -- Assuming a 7-day rental
1,
CURRENT_DATE
FROM public.inventory i
JOIN public.film f ON i.film_id = f.film_id
JOIN public.customer c ON c.first_name = 'Nataliia' AND c.last_name = 'Hlukhovetska'
WHERE f.title IN ('Titanic', 'The Devil Wears Prada', 'Inception')
AND NOT EXISTS (
SELECT 1 FROM public.rental r
WHERE r.inventory_id = i.inventory_id AND r.customer_id = c.customer_id
)
RETURNING rental_id, inventory_id, customer_id;

-- Insert into payment table
INSERT INTO public.payment (customer_id, staff_id, rental_id, amount, payment_date)
SELECT
r.customer_id,
1,
r.rental_id,
f.rental_rate,
'2017-05-15'::date
FROM public.rental r
JOIN public.inventory i ON r.inventory_id = i.inventory_id
JOIN public.film f ON i.film_id = f.film_id
JOIN public.customer c ON r.customer_id = c.customer_id
WHERE c.first_name = 'Nataliia' AND c.last_name = 'Hlukhovetska'
AND f.title IN ('Titanic', 'The Devil Wears Prada', 'Inception')
AND NOT EXISTS (
SELECT 1 FROM public.payment p WHERE p.rental_id = r.rental_id
)
RETURNING payment_id, rental_id, amount;

COMMIT;
