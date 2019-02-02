USE sakila;
#1a select first name and last name from actor table
SELECT first_name, last_name
FROM actor;
#1b Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`
SELECT CONCAT(first_name, ' ', last_name) as actor
FROM actor;
#2afind id_number, last_name for actor with first_name joe 
SELECT actor_id AS id_number, first_name, last_name
FROM actor
WHERE first_name = 'Joe'
#2b Find all actors whose last name contain the letters `GEN`
SELECT actor_id AS id_number, first_name, last_name
FROM actor
WHERE last_name LIKE '%Gen%'
#2c call actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order
SELECT last_name AS last_name, first_name AS first_name
FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name;
#2d Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country, country_id
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');
#3a add column called description to actor table and use data type BLOB
ALTER TABLE actor
ADD COLUMN description blob AFTER last_name;
#3b delete description column
ALTER TABLE actor
DROP COLUMN description;
#4a List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name) 
FROM actor
GROUP BY last_name
HAVING COUNT(last_name) >= 1;
#4b last name of actors and names of actors with that last names that are shared by at least 2 actors
SELECT last_name, COUNT(last_name) 
FROM actor
GROUP BY last_name
HAVING COUNT(last_name) >= 2;
#4c GROUCHO WILLIAMS-->`HARPO WILLIAMS`
UPDATE actor
SET first_name = 'Harpo'
WHERE first_name = 'GROUCHO' and last_name='WILLIAMS';
#4d change it back to GROUCHO
UPDATE actor
SET first_name = 'GROUCHO'
WHERE first_name = 'HARPO' and last_name='WILLIAMS';
#5a show table address
SHOW CREATE TABLE address;
#6a Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`: 
SELECT address_id from address;
SELECT first_name, last_name, address_id FROM staff;
SELECT s.first_name, s.last_name, a.address
 FROM staff s
 INNER JOIN address a
 ON (s.address_id = a.address_id);
#6b Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
#SELECT amount, payment_date FROM payment
SELECT p.staff_id, SUM(p.amount)
FROM payment AS p
JOIN staff AS s ON p.staff_id=s.staff_id
WHERE payment_date LIKE '%2005-08%'
GROUP BY staff_id;
#6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT title, COUNT(actor_id)
FROM film
INNER JOIN film_actor ON
film.film_id = film_actor.film_id
GROUP BY title;
#6dHow many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT COUNT(inventory_id)
FROM inventory
WHERE film_id IN
(
 SELECT film_id
 FROM film
 WHERE title ="Hunchback Impossible"
);
#6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer
#List the customers alphabetically by last name:
SELECT c.first_name, c.last_name, SUM(p.amount)
FROM customer c
INNER JOIN payment p 
ON c.customer_id = p.customer_id
GROUP BY last_name ASC;
# 7a. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
SELECT title
FROM film
WHERE title LIKE 'K%' OR 'Q%' IN
(
 SELECT title 
 FROM film
 WHERE language_id IN
 (
  SELECT language_id
  FROM language
  WHERE name = 'English'
  )
);
# Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT first_name, last_name
FROM actor
WHERE actor_id IN
(
 SELECT actor_id 
 FROM film_actor
 WHERE film_id IN
 (
  SELECT film_id
  FROM film
  WHERE title = 'Alone Trip'
 )
);
# 7c. names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT first_name, last_name, email
FROM customer
WHERE address_id IN
(
 SELECT address_id 
 FROM address
 WHERE city_id IN
 (
  SELECT city_id
  FROM city
  WHERE country_id IN
  (
   SELECT country_id
   FROM country
   WHERE country = 'Canada'
   )
 )
);
# 7d. Identify all movies categorized as _family_ films.
SELECT name FROM category
SELECT title
FROM film
WHERE film_id IN
(
 SELECT film_id 
 FROM film_category
 WHERE category_id IN
 (
  SELECT category_id
  FROM category
  WHERE name = 'family'
 )
);
#7eDisplay the most frequently rented movies in descending order******
SELECT * FROM rental;
SELECT title, COUNT(r.inventory_id) AS 'frequency of rental'
FROM rental As r
INNER JOIN inventory AS i ON r.inventory_id = i.inventory_id
INNER JOIN film AS f ON i.film_id = f.film_id
GROUP BY title
ORDER BY COUNT(r.inventory_id) DESC;

#7f. Write a query to display how much business, in dollars, each store brought in.

SELECT store_id, SUM(p.amount) AS 'total business($)'
FROM payment As p
INNER JOIN customer AS c ON p.customer_id = c.customer_id
GROUP BY store_id
ORDER BY SUM(p.amount) DESC;
#7g. Write a query to display for each store its store ID, city, and country
SELECT city, country, store_id
FROM city as c
JOIN country AS y ON c.country_id=y.country_id
JOIN address AS a ON c.city_id=a.city_id
JOIN customer AS r ON a.address_id=r.address_id
GROUP BY store_id;

#7h. List the top five genres in gross revenue in descending order.
#(**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT c.name, SUM(p.amount) AS 'Income'
FROM category as c
JOIN film_category AS f ON c.category_id=f.category_id
JOIN film AS x ON f.film_id=x.film_id
JOIN inventory AS i ON x.film_id=i.film_id
JOIN rental AS r ON i.inventory_id=r.inventory_id
JOIN payment AS p ON r.rental_id=p.rental_id
GROUP BY name
ORDER BY SUM(amount) DESC;
#8a
CREATE VIEW V_GENRE_SALES
#SELECT A1.name CATEGORY, SUM(A6.amount)
#FROM category A1, film_category A2, film A3, inventory A4, rental A5, payment A6
#WHERE A1.category_id=A2.category_id
#WHERE A2.film_id=A3.film_id
#WHERE A3.film_id=A4.film_id
#WHERE A4.inventory_id=A5inventory_id
#WHERE A5.rental_id=A6.rental_id
#GROUP BY A6.SUM(amount);

CREATE VIEW top_5_genre_rev AS
SELECT c.name, SUM(p.amount) AS 'Income'
FROM category as c
JOIN film_category AS f ON c.category_id=f.category_id
JOIN film AS x ON f.film_id=x.film_id
JOIN inventory AS i ON x.film_id=i.film_id
JOIN rental AS r ON i.inventory_id=r.inventory_id
JOIN payment AS p ON r.rental_id=p.rental_id
GROUP BY name
ORDER BY SUM(amount) DESC;
8b. How would you display the view that you created in 8a?
SELECT * FROM top_5_genre_rev
LIMIT 5;
#8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW top_5_genre_rev;



