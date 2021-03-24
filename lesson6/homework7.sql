USE vk2; -- сюда применила изменения vk-db-DATA.SQL

/*1. Пусть задан некоторый пользователь.
Из всех друзей этого пользователя найдите человека, который больше всех общался с нашим пользователем. 
(можете взять пользователя с любым id).
 * */

-- пусть id = 3

SHOW tables;

-- Для начала найдем всех друзей пользователя. 

SELECT id FROM friend_requests_types WHERE name = "accepted";  -- для определения id что заявка на дружбу принята
SELECT * FROM friend_requests fr WHERE (from_user_id = 3 OR to_user_id = 3)
  AND request_type = (SELECT id FROM friend_requests_types WHERE name = "accepted"); -- нашли все принятые заявки

SELECT from_user_id FROM friend_requests fr WHERE to_user_id = 3
	AND request_type = (SELECT id FROM friend_requests_types WHERE name = "accepted")
	UNION 
SELECT to_user_id FROM friend_requests fr WHERE from_user_id = 3
	AND request_type = (SELECT id FROM friend_requests_types WHERE name = "accepted"); -- получили id всех друзей

-- Теперь найдем с кем больше всего из них общался 3й юзер

-- Итоговый запрос вышел таким.  Очень долго догадывалась, что нужно UNION таблицу (главную) сделать 
-- как подзапрос (иначе выдавал какой-то бред при попытке group by: группировал по одинаковым id). 

SELECT count(*) AS k_txt, id FROM
(SELECT txt, from_user_id AS id FROM messages WHERE to_user_id = 3 
	AND from_user_id IN 
	(SELECT from_user_id FROM friend_requests fr WHERE to_user_id = 3
		AND request_type = (SELECT id FROM friend_requests_types WHERE name = "accepted")
		UNION 
	SELECT to_user_id FROM friend_requests fr WHERE from_user_id = 3
		AND request_type = (SELECT id FROM friend_requests_types WHERE name = "accepted")) -- 1я часть: сообщения 6-му
	UNION ALL 
SELECT txt, to_user_id FROM messages WHERE from_user_id = 3 -- 2я часть сообщени
	AND to_user_id IN 
	(SELECT from_user_id FROM friend_requests fr WHERE to_user_id = 3
		AND request_type = (SELECT id FROM friend_requests_types WHERE name = "accepted")
		UNION 
	SELECT to_user_id FROM friend_requests fr WHERE from_user_id = 3
		AND request_type = (SELECT id FROM friend_requests_types WHERE name = "accepted"))) T
GROUP BY T.id
ORDER BY k_txt DESC LIMIT 1;


/*2. Подсчитать общее количество лайков на посты, которые получили пользователи младше 18 лет.
 * */

SHOW tables;

SELECT count(*) FROM posts_likes pl WHERE like_type = 1 AND 
	post_id IN -- выбираем посты которые оставили юзеры моложе 18
	(SELECT id FROM posts 
	WHERE user_id IN (SELECT user_id FROM profiles p2 WHERE TIMESTAMPDIFF(YEAR, birthday, NOW()) < 18));

/*3. Определить, кто больше поставил лайков (всего) - мужчины или женщины?
 * */

SELECT * FROM profiles p LIMIT 5;

SELECT count(*) AS k,
	(SELECT gender FROM profiles p2 WHERE p2.user_id = pl.user_id) AS gender 
	FROM posts_likes pl GROUP BY gender -- получить результат по 3м группам
	ORDER BY k DESC LIMIT 1; -- вывести только топ результат

/*4. (по желанию) Найти пользователя, который проявляет наименьшую активность в использовании социальной сети.
 * */

SHOW tables;
-- За активность будем считать: оставлять посты, состоять в сообществах, посылать запросы в друзья,
-- отправлять сообщения, лайкать посты

SELECT count(*) AS act_k, user_id FROM 
(SELECT count(*), user_id FROM posts p2 GROUP BY user_id
UNION ALL 
SELECT count(*), user_id FROM communities_users cu GROUP BY user_id
UNION ALL 
SELECT count(*), from_user_id FROM friend_requests fr GROUP BY from_user_id
UNION ALL 
SELECT count(*), from_user_id FROM messages m GROUP BY from_user_id
UNION ALL 
SELECT count(*), user_id FROM posts_likes pl GROUP BY user_id) T 
GROUP BY T.user_id
ORDER BY act_k; -- здесь могло быть limit 1, но по факту оказалось, что их 4 одинаковой активности

















