/*
 * Урок 6.
*/
-- Модифицируем таблицу profiles

ALTER TABLE profiles MODIFY COLUMN photo_id bigint UNSIGNED;

ALTER TABLE profiles ADD CONSTRAINT profiles_photo_fk 
FOREIGN KEY (photo_id) REFERENCES media (id);

DESCRIBE profiles;

-- Модифицируем таблицу friends_requests

CREATE TABLE friend_requests_types
(
	id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(128) UNIQUE NOT NULL
);

ALTER TABLE friend_requests DROP COLUMN accepted;

ALTER TABLE friend_requests ADD COLUMN request_type INT UNSIGNED NOT NULL;

ALTER TABLE friend_requests ADD CONSTRAINT fk_friends_types 
FOREIGN KEY (request_type) REFERENCES friend_requests_types (id);

ALTER TABLE friend_requests ADD COLUMN created_at DATETIME DEFAULT CURRENT_TIMESTAMP;


/*
 * Запрос 1. Выбираем основную информацию пользователя с id=1.
*/

-- Выбираем данные пользователя с id 1
SELECT 
	first_name,
	last_name,
	'city', 
	'profile_photo'
FROM users 
WHERE id = 1;

-- находим город
SELECT city FROM profiles WHERE user_id = 1;

-- находим id фотографии профиля

SELECT photo_id FROM profiles WHERE user_id = 1;

-- находим имя файла с id фотографии профиля

SELECT file_name 
FROM media 
WHERE id = 
(
	SELECT photo_id FROM profiles WHERE user_id = 1
);

-- Расписываем
SELECT 
	first_name, 
	last_name, 
	(SELECT city FROM profiles WHERE user_id = 1) AS city,
	(SELECT file_name FROM media WHERE id = 
	    (SELECT photo_id FROM profiles WHERE user_id = 1)
	) AS main_photo
FROM users 
WHERE id = 1;

-- Ссылаемся на id извне
SELECT 
	first_name, 
	last_name, 
	(SELECT city FROM profiles WHERE user_id = users.id) AS city,
	(SELECT file_name FROM media WHERE id = 
	    (SELECT photo_id FROM profiles WHERE user_id = users.id)
	) AS main_photo
FROM users 
WHERE id = 1;

/*
 * Задание 2. Поиск медиафайлов пользователя с id = 1.
*/

-- Ищем все картинки пользователя
SELECT file_name 
FROM media
WHERE user_id = 1
	AND media_types_id = 'image_id'; -- заглушка

-- Ищем номер типа картинки
SELECT id FROM media_types WHERE name = 'image';

SELECT file_name 
FROM media
WHERE user_id = 1
	AND media_types_id = (
		SELECT id FROM media_types WHERE name = 'image')
;

-- если не знаем id пользователя
SELECT file_name 
FROM media
WHERE user_id = (SELECT id FROM users WHERE email = 'greenfelder.antwan@example.org')
	AND media_types_id = (
		SELECT id FROM media_types WHERE name = 'image')
;

-- если хотим вывести только *.png
SELECT file_name 
FROM media
WHERE user_id = 1 AND file_name LIKE '%.png';

-- если хотим вывести только *.png и *.jpg
SELECT file_name 
FROM media
WHERE user_id = 1 AND (file_name LIKE '%.png' OR file_name LIKE '%.jpg');

/*
 * Задание 3. Посчитаем количество медиафайлов каждого типа.
*/

-- количество всех файлов в таблице media
SELECT COUNT(*)
FROM media;

-- считаем количество медиафайлов по каждому типу
SELECT COUNT(*), media_types_id 
FROM media
GROUP BY media_types_id;

-- считаем количество медиафайлов по каждому типу с названиями типов
SELECT COUNT(*),
       (SELECT name FROM media_types WHERE id = media.media_types_id) AS name
FROM media
GROUP BY media_types_id;

/*
 * Задание 4. Посчитаем количество медиафайлов каждого типа для каждого пользователя.
*/

SELECT COUNT(*),
       (SELECT name FROM media_types WHERE id = media.media_types_id) AS name,
       user_id
FROM media
GROUP BY media_types_id, user_id
ORDER BY user_id;

/*
 * Задание 5. Выбираем друзей пользователя с id = 1.
*/

-- выбираем кому пользователь отправил заявки
SELECT to_user_id FROM friend_requests WHERE from_user_id = 1;

-- выбираем кому пользователь отправил заявки, заявки приняты
SELECT to_user_id FROM friend_requests WHERE from_user_id = 1 AND request_type = 1;

-- выбираем от кого пользователю пришли заявки, заявки приняты
SELECT from_user_id FROM friend_requests WHERE to_user_id = 1 AND request_type = 1;

-- объединяем две группы, чтобы получить всех друзей
SELECT to_user_id FROM friend_requests WHERE from_user_id = 1 AND request_type = 1
UNION
SELECT from_user_id FROM friend_requests WHERE to_user_id = 1 AND request_type = 1

/*
 * Задание 6. Выводим имя и фамилию друзей пользователя с id = 1
*/

SELECT CONCAT(first_name, ' ', last_name) AS name 
FROM users WHERE id IN (1, 2, 3); -- заглушка

SELECT CONCAT(first_name, ' ', last_name) AS name 
FROM users WHERE id IN (
	SELECT to_user_id FROM friend_requests WHERE from_user_id = 1 AND request_type = 1
	UNION
	SELECT from_user_id FROM friend_requests WHERE to_user_id = 1 AND request_type = 1
);

-- если не знаем, что accepted тип 1
SELECT CONCAT(first_name, ' ', last_name) AS name 
FROM users WHERE id IN (
	SELECT to_user_id FROM friend_requests WHERE from_user_id = 1
		AND request_type = (SELECT id FROM friend_requests_types WHERE name = 'accepted')
	UNION
	SELECT from_user_id FROM friend_requests WHERE to_user_id = 1
		AND request_type = (SELECT id FROM friend_requests_types WHERE name = 'accepted')
);

/*
 * Задание 7. Выводим красиво информацию о друзьях. Выводим имя, фамилию, пол, возраст.
*/

-- красиво выводим пол
SELECT user_id, CASE (gender) 
	   WHEN 'f' THEN 'female'
	   WHEN 'm' THEN 'man'
	   WHEN 'x' THEN 'not defined'
	   END AS gender
FROM profiles;

-- выводим возраст
SELECT user_id, TIMESTAMPDIFF(YEAR, birthday, NOW()) AS age
FROM profiles;

SELECT user_id,
       CASE (gender) 
	   WHEN 'f' THEN 'female'
	   WHEN 'm' THEN 'man'
	   WHEN 'x' THEN 'not defined'
	   END AS gender,
       TIMESTAMPDIFF(YEAR, birthday, NOW()) AS age
FROM profiles WHERE user_id IN (
	SELECT to_user_id FROM friend_requests WHERE from_user_id = 1
		AND request_type = (SELECT id FROM friend_requests_types WHERE name = 'accepted')
	UNION
	SELECT from_user_id FROM friend_requests WHERE to_user_id = 1
		AND request_type = (SELECT id FROM friend_requests_types WHERE name = 'accepted')
);

/*
 * Задание 8. Выводим все непрочитанные сообщения пользователя с id = 1.
*/

-- выводим все сообщения пользователя, сортируем по дате
SELECT from_user_id, to_user_id, txt, is_delivered, created_at
FROM messages
WHERE from_user_id = 1 OR to_user_id = 1
ORDER BY created_at DESC;

-- выводим все непрочитанные сообщения из диалогов
SELECT from_user_id, to_user_id, txt, is_delivered, created_at
FROM messages
WHERE (from_user_id = 1 OR to_user_id = 1) AND is_delivered = FALSE
ORDER BY created_at DESC;

-- выводим сверху непрочитанные сообщения пользователя
SELECT from_user_id, to_user_id, txt, is_delivered, created_at
FROM messages
WHERE (from_user_id = 1 OR to_user_id = 1) AND is_delivered = FALSE
ORDER BY (from_user_id = 1), created_at DESC;

/*
 * Задание 8. Ищем фамилии пользователей определенного паттерна.
*/
SELECT DISTINCT first_name
FROM users
WHERE first_name LIKE 'E%';

SELECT DISTINCT first_name
FROM users
WHERE first_name RLIKE '^E.*n$';