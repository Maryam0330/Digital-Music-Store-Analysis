/* Question Set 1 - Easy */


/* Q1: Who is the senior most employee based on job title? */

SELECT 
	title, 
	first_name, 
	last_name
FROM employee
ORDER BY levels DESC
LIMIT 1


/* Q2: Which countries have the most Invoices? */

SELECT 
	COUNT(*) AS invoice_count,
	billing_country
FROM invoice
GROUP BY billing_country
ORDER BY invoice_count DESC


/* Q3: What are top 3 values of total invoice? */

SELECT total 
FROM invoice
ORDER BY total DESC
LIMIT 3
  

/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

SELECT 
	billing_city,
	SUM(total) AS invoice_total
FROM invoice
GROUP BY billing_city
ORDER BY invoice_total DESC
LIMIT 1

ANS: Prague city has the best customers because they have purchased the most music albums.


/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(i.total) AS invoice_total
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY
    c.customer_id, 
    c.first_name, 
    c.last_name
ORDER BY invoice_total DESC
LIMIT 1



/* Question Set 2 - Moderate */

/* Q1: Write query to return the email, first name, last name, & Genre of all 'Rock' Music listeners. 
Return your list ordered alphabetically by email starting with A. */

/* Method 1 */

SELECT
	c.email,
	c.first_name,
	c.last_name
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
WHERE track_id IN (
	SELECT track_id 
	FROM track t
    	JOIN genre g ON t.genre_id = g.genre_id
    	WHERE g.name LIKE 'ROCK')
ORDER BY email 


/* Method 2 */

SELECT 
	DISTINCT(c.email) AS email,
	c.first_name,
	c.last_name,
	g.name
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN genre g on t.genre_id =  g.genre_id
WHERE g.name LIKE 'ROCK'
ORDER BY email


/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

SELECT
	ar.artist_id,
	ar.name,
	COUNT(ar.artist_id) AS no_of_songs
FROM artist ar 
JOIN album ab ON ar.artist_id = ab.artist_id
JOIN track t ON ab.album_id = t.album_id 
JOIN genre g ON t.genre_id = g.genre_id 
WHERE g.name LIKE 'ROCK'
GROUP BY 
	ar.artist_id, 
	ar.name
ORDER BY no_of_songs DESC
LIMIT 10
  

/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

SELECT 
	name,
	milliseconds
FROM track
WHERE milliseconds > (
	SELECT AVG(milliseconds) AS avg_song_length
	FROM track)
ORDER BY milliseconds DESC


/* Question Set 3 - Advance */

/* Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */

WITH best_selling_artist AS(
	SELECT 
		ar.artist_id, 
        	ar.name, 
        	SUM(il.unit_price * il.quantity) AS total_spent
	FROM artist ar
	JOIN album al ON ar.artist_id = al.artist_id
        JOIN track t ON al.album_id = t.album_id
    	JOIN invoice_line il ON t.track_id = il.track_id 
    	GROUP BY 1, 2
    	ORDER BY 3 DESC
    	LIMIT 1
)

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    bsa.name AS artist_name,
    SUM(il.unit_price * il.quantity) AS total_spent
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN album al ON t.album_id = al.album_id
JOIN best_selling_artist bsa ON al.artist_id = bsa.artist_id
GROUP BY 1, 2, 3, 4
ORDER BY 5 DESC


/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

/* Using CTE method */

WITH popular_music_genre AS(
	SELECT 
		COUNT(il.quantity) AS purchases, 
		c.country,
		g.genre_id,
		g.name,
		ROW_NUMBER() OVER (PARTITION BY c.country ORDER BY COUNT(il.quantity) DESC) AS row_num
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    JOIN invoice_line il ON i.invoice_id = il.invoice_id
    JOIN track t ON il.track_id = t.track_id
    JOIN genre g ON t.genre_id = g.genre_id
    GROUP BY 2, 3, 4
    ORDER BY 
	2 ASC, 
	1 DESC
)
    
SELECT *
FROM popular_music_genre
WHERE row_num <= 1

	
/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

/* Using CTE method */ 

WITH highest_spending_customer AS(
	SELECT
	c.customer_id,
        c.first_name,
        c.last_name,
        i.billing_country,
        SUM(i.total) AS total_spending,
        ROW_NUMBER() OVER (PARTITION BY i.billing_country ORDER BY SUM(i.total) DESC) AS row_num
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY 1, 2, 3, 4
    ORDER BY 
	4 ASC, 
        5 DESC
)
    
SELECT *
FROM highest_spending_customer
WHERE row_num <= 1
