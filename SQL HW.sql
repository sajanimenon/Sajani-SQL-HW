use sakila

-- 1a. Display the first and last names of all actors from the table actor.
select first_name,last_name from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
select upper(concat(first_name," ",last_name)) as 'Actor Name' from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
-- What is one query would you use to obtain this information?
select actor_id,first_name,last_name from actor where first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters GEN:
select actor_id,first_name,last_name from actor where last_name like '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. 
-- This time, order the rows by last name and first name, in that order:
select actor_id,last_name,first_name from actor where last_name like '%LI%' order by last_name asc,first_name asc;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id,country from country where country in ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. 
-- You don't think you will be performing queries on a description, so create a column in the table actor 
-- named description and use the data type BLOB 
-- (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
Alter table actor
add column description blob;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column
alter table actor drop description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
select last_name ,count(last_name) as 'count' from actor group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared 
-- by at least two actors
select last_name ,count(last_name) as 'count' from actor  group by last_name  having count(last_name) > 1;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
select * from actor where actor_id = 172; 
update actor
set first_name = 'Harpo' ,last_name='Williams' where first_name ='Groucho' and last_name = 'Williams';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name 
-- after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.

UPDATE actor SET first_name = 'GROUCHO' WHERE first_name = 'HARPO';

-- •	5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
-- o	Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html

describe sakila.address;

-- •	6a. Use JOIN to display the first and last names, as well as the address, of each staff member. 
-- Use the tables staff and address:

select a.first_name, a.last_name, b.address  from staff a join  address b on  a.address_id = b.address_id;

-- •	6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. 
-- Use tables staff and payment.

select a.staff_id, a.first_name,a.last_name, sum(b.amount) from staff a,payment b where a.staff_id = b.staff_id group by a.staff_id; 

-- •	6c. List each film and the number of actors who are listed for that film. 
-- Use tables film_actor and film. Use inner join.

select a.film_id,a.title,sum(b.actor_id) as 'Actor count' from film a
inner join film_actor b 
where  a.film_id = b.film_id group by a.film_id;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select count(*) as 'Copies'  from inventory  where film_id in (select film_id from film where title = 'Hunchback Impossible');

-- •	6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer.
--  List the customers alphabetically by last name:
select a.first_name,a.last_name, sum(b.amount) from customer a join payment b 
where  a.customer_id = b.customer_id group by a.customer_id order by a.last_name;

-- •	7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.

select title from film where film_id in 
   (select film_id from film where title like 'K%' OR title like 'Q%' and language_id in 
         (select language_id from language where name = 'English') );

-- •	7b. Use subqueries to display all actors who appear in the film Alone Trip.
select first_name,last_name  from actor where actor_id in 
   (select actor_id from film_actor where film_id in 
         (select film_id from film where title = 'Alone Trip') );
         
 -- •	7c. You want to run an email marketing campaign in Canada, for which you will need the names 
 -- and email addresses of all Canadian customers. Use joins to retrieve this information. 

 select customer_id,first_name,last_name,email  from customer where address_id in 
   (select address_id from address where city_id in 
   (select city_id from city where country_id in 
         (select country_id from country where country = 'Canada')) );
         
-- •	7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.

select title from film_text where film_id in 
   (select film_id from film_category where category_id in 
         (select category_id from category where name = 'Family'));

--	7e. Display the most frequently rented movies in descending order.

 select  a.title,count(c.rental_id) as 'Rentals' from film a
 join inventory b
 on a.film_id = b.film_id
 join rental c
 on b.inventory_id = c.inventory_id
 group by a.film_id
 order by Rentals Desc;
 

-- •	7f. Write a query to display how much business, in dollars, each store brought in.

select  d.store_id,sum(a.amount)from payment a
inner join rental b 
on a.rental_id = b.rental_id 
inner join inventory c
on b.inventory_id = c.inventory_id
inner join store d
on c.store_id = d.store_id
group by d.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.

select a.store_id,c.city,d.country from store a
inner join address b
on a.address_id = b.address_id
inner join city c
on b.city_id = c.city_id 
inner join country d
on c.country_id = d.country_id ;


-- 	7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, i, p, and r.)

select  a.name, sum(e.amount) as 'Amt' from category a
join film_category b 
on a.category_id = b.category_id 
join inventory c
on b.film_id = c.film_id
join rental d
on c.inventory_id = d.inventory_id
join payment e
on d.rental_id = e.rental_id
group by a.name
ORDER BY Amt DESC LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query 
-- to create a view.

CREATE VIEW Topgenre AS
    select  a.name, sum(e.amount) as 'Amt' from category a
join film_category b 
on a.category_id = b.category_id 
join inventory c
on b.film_id = c.film_id
join rental d
on c.inventory_id = d.inventory_id
join payment e
on d.rental_id = e.rental_id
group by a.name
ORDER BY Amt DESC LIMIT 5;

-- 8b. How would you display the view that you created in 8a?
select * from topgenre

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
Drop view topgenre



