/*Calculate the number of jobs reviewed per hour per day for November 2020?
select *,avg(time_spent)over(rows between 6 preceding and current row) from job_data 

select ds,sum(time_spent),count(job_id) from job_data group by ds

select *,trunc(avg(throughput) OVER(ORDER BY ds ROWS BETWEEN 7 PRECEDING AND CURRENT ROW), 2)
         AS rolling_avg from (select ds,round((count(job_id)*1.0)*3600/sum(time_spent),2) as throughput
from job_data
where 
	ds between '01-11-20'  and '30-11-20' 
group by ds)a

select count(*) from job_data*/

/*most job review in seconds,hardly 1 minute spend thats why jobs reviewed per hour per day is zero */
select 
	ds,round(1.0*hours_spent/jobs_per_day,3) as reviewed_per_hour_per_day 
from 
	(select 
	  ds,
	  sum(time_spent) as second_spent,
	  count(job_id) as jobs_per_day, 
	  sum(time_spent)/3600 as hours_spent 
	from 
	  job_data  
	where 
	 ds between '01-11-20'  and '30-11-20'  
group by ds ) a;
------------------------------------------------------------------------------------
/*Percentage share of each language: Share of each language for different contents.
Your task: Calculate the percentage share of each language in the last 30 days?*/
select 
  language,
  round(language_count/total*100,2) as language_percentage_share 
from 
   (select 
	   language, 
	   count(*) as language_count,
	   sum(count(*)) over(rows between unbounded preceding and unbounded following) as total  
	from 
	   job_data 
	where 
	    ds between '01-11-20'  and '30-11-20' 
	GROUP by language)a 
--------------------------------------------------------------------------------------------------
/*Duplicate rows: Rows that have the same value present in them.
Your task: Let’s say you see some duplicate rows in the data. How will you display duplicates from the table?*/
select 
	job_id,count(job_id),
	language,count(language),
	time_spent,count(time_spent),
	org,count(org),
	ds,count(ds),
	actor_id,count(actor_id),
	event,count(event)
from 
	job_data 
group by
	job_id,language,time_spent,org,ds,actor_id,event
HAVING
	count(job_id)>1 and count(language)>1 and count(time_spent)>1 
	and count(org)>1 
	and count(ds)>1
	and count(actor_id)>1
	and count(event)>1
--------------------------------------------------------------------------------------------------------------------
/*Throughput: It is the no. of events happening per second.
Your task: Let’s say the above metric is called throughput. Calculate 7 day rolling average of throughput? For throughput, do you prefer daily metric or 7-day rolling and why?*/
select *,trunc(avg(throughput) OVER(ORDER BY ds ROWS BETWEEN 7 PRECEDING AND CURRENT ROW), 2)
         AS rolling_avg from (select ds,round((count(job_id)*1.0)*3600/sum(time_spent),2) as throughput
from job_data
where 
	ds between '01-11-20'  and '30-11-20' 
group by ds)a

select *,
   trunc(avg(throughput)OVER(ORDER BY ds ROWS BETWEEN 7 PRECEDING AND CURRENT ROW),2)AS rolling_avg 
FROM
	(select *,trunc((1.0*count_job /total_time),2) as throughput 
	from 
	 (select distinct(ds),
	    sum(time_spent) over(partition by ds  ROWS BETWEEN UNBOUNDED PRECEDING AND unbounded following)as total_time,
	    count(job_id)over(partition by ds ROWS BETWEEN UNBOUNDED PRECEDING AND unbounded following) as count_job
	 from job_data)
	sub1)
  sub2

---------------------------------------------------------------------------------------------------
/*Case Study 2 (Investigating metric spike)*/
select distinct event_type from events
select * from users
select event_type,user_id,extract('week' from occured_at) from events WHERE event_type = 'engagement'

SELECT extract('week' from occured_at) AS WEEK,
            COUNT(user_id) AS Weekly_Active_User
         FROM events
         GROUP BY WEEK
		 order by WEEK

--dip in user engagement
SELECT 
  CONCAT( EXTRACT('week' FROM occured_at), '-', EXTRACT('year' FROM occured_at)) as week_year,
  event_name,
  count(event_name) as event_count
FROM events
WHERE event_type = 'engagement'
GROUP BY
  event_name,
  week_year
ORDER BY 
  event_count desc
-----------------------------------------------------------------------------------------
/*User Engagement: To measure the activeness of a user. Measuring if the user finds quality in a product/service.
Your task: Calculate the weekly user engagement?*/
SELECT
  EXTRACT('week' from occured_at) as week,
  count(DISTINCT user_id) as num_users
FROM events
WHERE event_type = 'engagement'
GROUP BY week
---number of user decline from 32 week 
--------------------------------------------------------------------------------------------
SELECT
  EXTRACT('week' from occured_at) as week,
  count(event_name) as num_events,
  count(DISTINCT user_id) as num_users,
  count(event_name)/count(DISTINCT user_id) as events_per_user
FROM events
WHERE event_type = 'engagement'
GROUP BY week

/*User Growth: Amount of users growing over time for a product.
Your task: Calculate the user growth for product?*/
SELECT *,
user_by_month/(sum(user_by_month)over(partition by device ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)) as per

from 
(SELECT
  device,
  EXTRACT('month' from occured_at) as month,
  count(DISTINCT(user_id)) as user_by_month
FROM events
WHERE event_type = 'engagement'
GROUP BY month,device
ORDER BY device)a
---------------------------------------------------------------------------------------------
/*Weekly Engagement: To measure the activeness of a user. Measuring if the user finds quality in a product/service weekly.
Your task: Calculate the weekly engagement per device?*/
SELECT
  device,
  EXTRACT('week' from occured_at) as week,
  count(*) as user_by_month
FROM events
WHERE event_type = 'engagement'
GROUP BY week,device
ORDER BY device

/*Weekly Retention: Users getting retained weekly after signing-up for a product.
Your task: Calculate the weekly retention of users-sign up cohort?*/
--firts calculate user login by week
SELECT 
	user_id,
    EXTRACT('week' from occured_at) AS login_week
FROM 
	events
WHERE event_name = 'login'
GROUP BY user_id,login_week;

--calculate user who completed sign up we use this user whether this user login on weekly basis or not
SELECT
user_id,
	min(EXTRACT('week' from occured_at)) AS first_week
FROM events
WHERE event_name = 'complete_signup'
GROUP BY user_id

select DISTINCT(event_name) from events

--we get login_week and first_week side by side for each user using the query below, with an INNER JOIN
select a.user_id,a.login_week,b.first_week as first_week  from   
              (SELECT 
					user_id,
					EXTRACT('week' from occured_at) AS login_week
				FROM 
					events
				WHERE event_name = 'login'
				GROUP BY user_id,login_week) a join 
              (SELECT
					user_id,
						min(EXTRACT('week' from occured_at)) AS first_week
				FROM 
			   		events
				WHERE event_name = 'complete_signup'
				GROUP BY user_id)b
        on a.user_id=b.user_id;
		

--calculate the difference between login_week and first_week to calculate week_number (number of week)		
select a.user_id,a.login_week,b.first_week as first_week,
		a.login_week-first_week as week_number  from   
              (SELECT 
					user_id,
					EXTRACT('week' from occured_at) AS login_week
				FROM 
					events
				WHERE event_name = 'login'
				GROUP BY user_id,login_week) a join 
              (SELECT
					user_id,
						min(EXTRACT('week' from occured_at)) AS first_week
				FROM 
			   		events
				WHERE event_name = 'complete_signup'
				GROUP BY user_id)b
        on a.user_id=b.user_id;
		
select first_week,
     SUM(CASE WHEN week_number = 0 THEN 1 ELSE 0 END) AS week_0,
       SUM(CASE WHEN week_number = 1 THEN 1 ELSE 0 END) AS week_1,
       SUM(CASE WHEN week_number = 2 THEN 1 ELSE 0 END) AS week_2,
       SUM(CASE WHEN week_number = 3 THEN 1 ELSE 0 END) AS week_3,
       SUM(CASE WHEN week_number = 4 THEN 1 ELSE 0 END) AS week_4,
       SUM(CASE WHEN week_number = 5 THEN 1 ELSE 0 END) AS week_5,
       SUM(CASE WHEN week_number = 6 THEN 1 ELSE 0 END) AS week_6,
       SUM(CASE WHEN week_number = 7 THEN 1 ELSE 0 END) AS week_7,
       SUM(CASE WHEN week_number = 8 THEN 1 ELSE 0 END) AS week_8,
       SUM(CASE WHEN week_number = 9 THEN 1 ELSE 0 END) AS week_9,
	   SUM(CASE WHEN week_number = 10 THEN 1 ELSE 0 END) AS week_10,
	   SUM(CASE WHEN week_number = 11 THEN 1 ELSE 0 END) AS week_11,
	   SUM(CASE WHEN week_number = 12 THEN 1 ELSE 0 END) AS week_12,
	   SUM(CASE WHEN week_number = 13 THEN 1 ELSE 0 END) AS week_13,
	   SUM(CASE WHEN week_number = 14 THEN 1 ELSE 0 END) AS week_14,
	   SUM(CASE WHEN week_number = 15 THEN 1 ELSE 0 END) AS week_15
    
       from  (
    
       select a.user_id,a.login_week,b.first_week as first_week,a.login_week-first_week as week_number 
		   from   
		   (SELECT 
					user_id,
					EXTRACT('week' from occured_at) AS login_week
				FROM 
					events
				WHERE event_name = 'login'
				GROUP BY user_id,login_week) a join 
              (SELECT
					user_id,
						min(EXTRACT('week' from occured_at)) AS first_week
				FROM 
			   		events
				WHERE event_name = 'complete_signup'
				GROUP BY user_id)b
        on a.user_id=b.user_id) as with_week_number
    
         group by first_week
     order by first_week;
-------------------------------------------------------------------------------------------------------------------------------
/* Users engaging with the email service.
Your task: Calculate the email engagement metrics?*/

SELECT
  action,
  EXTRACT('month' FROM occured_at) AS month,
  count(action) as num_emails,
  sum(count(action))over(partition by action  ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
FROM email_events
GROUP BY
action, month
ORDER BY
action, month

/* I noticed that there was a steady increase in the number of emails sent 
(weekly digest and re-engagement) and emails opened
but but there was a decrease in clickthrough rates. From July to August,
there was a 6.5% increase in emails open but a 27% decline in clickthrough rates.*/

with emails as(
SELECT 
  *,
  CONCAT(EXTRACT('day' FROM occured_at), '-', EXTRACT('month' FROM occured_at), '-',  EXTRACT('year' FROM occured_at)) as date,
  EXTRACT('month' FROM occured_at) as month
FROM email_events emails
), events as (
  SELECT DISTINCT 
    user_id,
    CONCAT(EXTRACT('day' FROM occured_at), '-', EXTRACT('month' FROM occured_at), '-',  EXTRACT('year' FROM occured_at)) as date,
    device,
    EXTRACT('month' FROM occured_at) as month
  FROM events
  ORDER BY user_id ASC
)
SELECT 
  device,
  emails.month,
  count(emails.user_id)
FROM emails
LEFT JOIN events ON
  emails.user_id = events.user_id
  AND emails.date = events.date
WHERE action = 'email_clickthrough'
GROUP BY device, emails.month
/*Using the query above, I noticed that the clickthrough rates on laptops and computers were stable from July to August,
but not the tablets and cellphones.*/


with emails as(
SELECT 
  *,
  CONCAT(EXTRACT('day' FROM occured_at), '-', EXTRACT('month' FROM occured_at), '-',  EXTRACT('year' FROM occured_at)) as date,
  EXTRACT('month' FROM occured_at) as month
FROM email_events emails
), events as (
  SELECT DISTINCT 
    user_id,
    CONCAT(EXTRACT('day' FROM occured_at), '-', EXTRACT('month' FROM occured_at), '-',  EXTRACT('year' FROM occured_at)) as date,
    device,
    EXTRACT('month' FROM occured_at) as month
  FROM events
  ORDER BY user_id ASC
)
SELECT 
  CASE
    WHEN device IN ('amazon fire phone', 'nexus 10', 'iphone 5', 'nexus 7', 'iphone 5s', 'nexus 5', 'htc one', 'iphone 4s', 'samsung galaxy note', 'nokia lumia 635', 'samsung galaxy s4') THEN 'mobile'
    WHEN device IN ('ipad mini', 'samsung galaxy tablet', 'kindle fire', 'ipad air') THEN 'tablet_ipad'
    WHEN device IN ('dell inspiron desktop', 'macbook pro', 'asus chromebook', 'windows surface', 'macbook air', 'lenovo thinkpad', 'mac mini', 'acer aspire desktop', 'acer aspire notebook', 'dell inspiron notebook', 'hp pavilion desktop') THEN 'laptop_comp'
    ELSE null end as device_type,
  emails.month,
  count(emails.user_id)
FROM emails
LEFT JOIN events ON
  emails.user_id = events.user_id
  AND emails.date = events.date
WHERE action = 'email_clickthrough'
GROUP BY device_type, emails.month

/*it seems to be the case that the drop in clickthrough rates was attributed specifically to mobile devices and tablets.*/


/* lack of engagement is due to a decrease in email clickthrough rates from July to August. To gather more information, 
I want to see if we can narrow the problem even further by email type.*/

with one as (
SELECT 
  *,
  EXTRACT('month' from occured_at) as month,
  CASE WHEN (LEAD(action, 1) OVER (PARTITION BY user_id ORDER BY occured_at ASC)) = 'email_open' THEN 1 ELSE 0 END AS opened_email,
  CASE WHEN (LEAD(action, 2) OVER (PARTITION BY user_id ORDER BY occured_at ASC)) = 'email_clickthrough' THEN 1 ELSE 0 END AS clicked_email
FROM
  email_events
)
SELECT 
  action,
  month,
  count(action),
  sum(opened_email) as num_open,
  sum(clicked_email) as num_clicked
FROM
  one
WHERE action in ('sent_weekly_digest','sent_reengagement_email')
GROUP BY
  action,
  month
ORDER BY
  action,
  month