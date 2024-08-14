/* We have this data set that contains information on olympic sports events (including Summer and Winter) spanning several years.
There is just one issue: I have several questions about the content of this dataset as it is not organized well. Therefore, I will
be manipulating the data and demonstrating SQL querying knowledge. Let's commence!*/

-- First we must call on the database that we are using. In this case we are referencing the 'olympics' database.
USE olympics; 

-- My first question is how many records we have in this dataset. There is a lot of data. 
SELECT COUNT(*)
FROM olympic_data;

-- It says here in the result grid that we have 101749 record entries.

/* Now, as I mentioned before, this data has unorganized data that spans several years.
What I would like to know is what is the earliest recorded year in this data set, as well as the oldest one.*/

SELECT MIN(year)
FROM olympic_data;

SELECT MAX(year)
FROM olympic_data;

-- GREAT! The earliest recorded year in this data set is 1896. And the most current records are from 2016!

-- I now wonder what the olympics looked like in the late 1800s. Specifically, what events were being played?

SELECT DISTINCT event, year
FROM olympic_data
WHERE year = 1896;

-- WOW! there were several events that were played back then.

-- Which countries were playing in that olypmic games?

SELECT DISTINCT team, year
FROM olympic_data
WHERE year = 1896;

-- Only the US, Australia, and a few European countries participated

-- Did the US ever win Gold in this olympic year? If so, what event, and who was the olympian?

SELECT name, team, event
FROM olympic_data
WHERE (NOC = 'USA') AND (medal = 'Gold') AND (year = 1896);

-- We only won gold in track and field events.

-- HMM did we receive any other medals that year?

SELECT name, team, event, medal
FROM olympic_data
WHERE (NOC = 'USA') AND (year = 1896) AND (medal IN ('Silver', 'Bronze'));

-- The US received five other, non-Gold medals that year. GREAT!

-- How many medals have each country received? Let's see

SELECT noc, COUNT(medal)
FROM olympic_data
GROUP BY noc;

/* I wonder which are the top five most decorated countries are. We can see that by just ordering the previous
query in descending order.*/

SELECT noc, COUNT(medal) AS amount_of_medals
FROM olympic_data
GROUP BY noc
ORDER BY amount_of_medals DESC;

-- If we just want the top 5 countries, we can include another part to our query.

SELECT noc, COUNT(medal) AS amount_of_medals
FROM olympic_data
GROUP BY noc
ORDER BY amount_of_medals DESC
LIMIT 5;

/* So the top five most decorated countries in the world are
1. United States
2. Great Britain
3. France
4. Germany
5. Italy */

/* I've always wondered what it would feel like to win an olympic medal. It may be too late for me to know.
But just for fun, lets see the medals won by people in different age groups. Maybe that will make me feel better. 
First, we have to find the bounds of the ages.*/

SELECT DISTINCT age
FROM olympic_data
ORDER BY age DESC;

-- Pause... the oldest olympian is 96. I wonder what they won. I'd be surprised if it was a laborous event. Let's see. 

SELECT name, age, year, team, event, medal
FROM olympic_data
WHERE age = 96;

-- Winslow Homer competed in the Art Competitions Mixed Painting event in 1932 for Team USA. He did not win a medal. But he is nonetheless an Olympian. 
-- Who has been the youngest olympian to compete?

SELECT DISTINCT age
FROM olympic_data
ORDER BY age ASC;

-- Is this event still being played? When was the last time this event was played?

SELECT year, event
FROM olympic_data
WHERE event LIKE 'Art Competitions Mixed Painting%'
ORDER BY year DESC
LIMIT 1;

-- As we can see the last time this was an olympic event was in 1948. Who won the gold?

SELECT year, event, name, age, team, noc, medal
FROM olympic_data
WHERE (event LIKE 'Art Competitions Mixed Painting%') AND (medal = 'Gold')
ORDER BY year DESC
LIMIT 1;

-- Albert Decaris won the gold medal for the last Art Competitions Mixed Painting event for team France in 1948 at the age of 47.

-- Pause... the youngest recorded olympian was an 11 year old. I must see what they competed in. 
SELECT name, age, year, team, event, medal
FROM olympic_data
WHERE age = 11;

/* So there have been several children that have competed at the Olympic games at the age of 11.
The only one of these 11 year olds to win a medal was
Luigina Giavotti who won a silver medal in the Gymnastics Women's Team All- Around event in 1928 for team Italy.*/
 -- Okay, back to the task at hand.
 
SELECT
CASE WHEN age < 11 THEN '0-10'
	 WHEN age BETWEEN 11 AND 20 THEN '11-20'
	 WHEN age BETWEEN 21 AND 30 THEN '21-30'
     WHEN age BETWEEN 31 AND 40 THEN '31-40'
     WHEN age BETWEEN 41 AND 50 THEN '41-50'
     WHEN age BETWEEN 51 AND 60 THEN '51-60'
     WHEN age BETWEEN 61 AND 70 THEN '61-70'
     WHEN age BETWEEN 71 AND 80 THEN '71-80'
     WHEN age BETWEEN 81 AND 90 THEN '81-90'
     WHEN age BETWEEN 91 AND 100 THEN '91-100'
     WHEN age > 100 THEN '100+'
     END AS age_groups,
     SUM(CASE WHEN medal = 'Gold' THEN 1 END) AS gold_medals,
     SUM(CASE WHEN medal = 'Silver' THEN 1 END) AS silver_medals,
     SUM(CASE WHEN medal = 'Bronze' THEN 1 END) AS bronze_medals
FROM olympic_data
GROUP BY age_groups
ORDER BY age_groups;

/* I am skeptical about the results of this query. So, I would like to test it. In total, the '11-20' age group has 1949 medals.
Let's see if that matches up with the following individual query.*/

SELECT COUNT(medal)
FROM olympic_data
WHERE (age BETWEEN 11 AND 20) AND medal IS NOT NULL;

-- AND IT WORKED!!!! this counted 1949 medals in total just like the previous query.
/* Although it worked, there is a NULL age group that contains medal counts. This leads me to believe that there may some NULL values in the age field. 
Let's test this out to see if my hunch is correct.*/

SELECT COUNT(*)
FROM olympic_data
WHERE age IS NULL;

-- OH WOW! There are 3755 entries that contain a NULL value as an age. Let's see how many medals were won by people with 'NULL' ages. 

SELECT COUNT(*)
FROM olympic_data
WHERE (age IS NULL) AND (medal IS NOT NULL);

/* So only 268 of the 3755 entries with a NULL value in the age field have placed within the top three of any olympic event. 
This matches up with the information in the big query by age_groups. I believe it is safe to say that that query is correct!*/

-- What are the youngest and oldest ages that have competed in the olympics by each country?

SELECT noc, MIN(age) AS mini, MAX(age) AS maxi
FROM olympic_data
GROUP BY noc
ORDER BY mini ASC, maxi DESC;

-- Cool!

-- Finally, I would love to see the amount of each medals won by each country!
SELECT noc,
	   SUM(CASE WHEN medal = 'Gold' THEN 1 END) AS gold_medals,
       SUM(CASE WHEN medal = 'Silver' THEN 1 END) AS silver_medals,
       SUM(CASE WHEN medal = 'Bronze' THEN 1 END) AS bronze_medals
FROM olympic_data
GROUP BY noc
ORDER BY gold_medals DESC, silver_medals DESC, bronze_medals DESC;

-- How many women have won olympic medals?
SELECT SUM(CASE WHEN women_data.gender = 'F' THEN 1 END) AS women_num
FROM (SELECT sex AS gender, medal
	  FROM olympic_data
	  WHERE sex = 'F') AS women_data
WHERE medal IN ('Gold', 'Silver', 'Bronze');


/* There are more queries that can be made. I believe i've made a pretty solid dent to this data.*/
      
