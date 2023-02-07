--Top 5 oldest user 
		select * from users order by created_at desc limit 5;
---------------------------------------------------------------
--user who havent posted single photos
	select users.id, username from users left join photos on users.id=photos.user_id where photos.image_url is null
----------------------------------------------------

select * from photos
select * from likes
select users.username,photos.id,photos.image_url,count(*) as total_likes from likes 
join photos on photos.id=likes.photo_id
join users on users.id=likes.photo_id group by photos.id order by total_likes  desc limit 10;

select photo_id, count(*) as total_likes from likes group by photo_id order by total_likes desc;

select id from (select user_id,id,count(*) as total from photos group by id) photo


--user who gets the most likes on a single photo 
	select users.username,photos.id as photo_id,photo_like.total_likes 
	from photos 
	inner join 
		(select photo_id, count(*) as total_likes from likes group by photo_id) as photo_like 
	on photos.id=photo_like.photo_id
	join users 
	on users.id=photos.user_id 
	order by 
		total_likes desc limit 5
	----------------------------------------

select count(*) as total_count ,tag_id from photos_tags group by tag_id order by total_count desc
select * from tags

---- top 5 most commonly used hashtags on the platform
	select 
		tags.tag_name,tags.id,tag_counts.total_count 
	from tags 
	JOIN 
		(select count(*) as total_count ,tag_id from photos_tags group by tag_id order by total_count desc) as tag_counts 
	on tags.id=tag_counts.tag_id 
	order by 
		total_count desc limit 10;
---------------------------------------------

select * from comments

----What day of the week do most users register on
select * from users;

select 
	count(*) as total_account_created,to_char(created_at,'day') as "Day" 
from 
	users 
group by "Day" order by total_account_created desc;

---Provide data on users (bots) who have liked every single photo on the site (since any normal user would not be able to do this).
select count(distinct(photo_id)) as total_post from likes union 
select count(distinct(id)) as total_users from users;
select user_id,count(photo_id) as count  from likes group by user_id order by count  desc
select user_id,count(photo_id) as Total_post_like  from likes group by user_id having count(photo_id)=257

----Provide how many times does average user posts on Instagram. Also, provide the total number of photos on Instagram/total number of users

select (select count(*) from photos)/(select count(*) from users)

SELECT count(*) as total_users,ROUND((SELECT COUNT(*)FROM photos)/(SELECT COUNT(*) FROM users),2)as avg_post_per_user from users;

---Provide how many times does average user posts on Instagram.
/*some user are highely active as they are posting 10 to 12 photos */
SELECT users.username,COUNT(photos.image_url)
FROM users
JOIN photos ON users.id = photos.user_id
GROUP BY users.id
ORDER BY 2 DESC;