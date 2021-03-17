USE vk;

/*
 * Задание 2
 * Придумать 2-3 таблицы для БД vk, которую мы создали на занятии (с перечнем полей, указанием индексов и внешних ключей). 
 * Прислать результат в виде скрипта *.sql.

Возможные таблицы:
a. Посты пользователя
b. Лайки на посты пользователей, лайки на медиафайлы
c. Черный список
d. Школы, университеты для профиля пользователя
e. Чаты (на несколько пользователей)
f. Посты в сообществе
 */

-- Посты пользователя


CREATE TABLE users_posts (
	post_id bigint UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
	user_id bigint UNSIGNED NOT NULL,
	created_at datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
	post text NOT NULL,
	INDEX user_id_inx (user_id),
	CONSTRAINT user_id_fk FOREIGN KEY (user_id) REFERENCES users (id)	
);

-- Лайки на посты пользователей, лайки на медиафайлы


CREATE TABLE posts_likes (
	post_id bigint UNSIGNED NOT NULL,
	liked_by bigint UNSIGNED NOT NULL,
	PRIMARY KEY (post_id, liked_by),
	INDEX liked_by_inx (liked_by), -- поиск всех постов, которые лайкнул конкретный юзер
	INDEX post_id_inx (post_id), -- поиск поста
	CONSTRAINT post_id_fk FOREIGN KEY (post_id) REFERENCES users_posts (post_id),
	CONSTRAINT liked_by_fk FOREIGN KEY (liked_by) REFERENCES users (id)
);

-- Лайки на медиа файлы

CREATE TABLE IF not EXISTS media_likes (
	media_id bigint UNSIGNED NOT NULL,
	liked_by bigint UNSIGNED NOT NULL,
	PRIMARY KEY (media_id, liked_by),
	CONSTRAINT media_id_fk FOREIGN KEY (media_id) REFERENCES media (id),
	CONSTRAINT liked_by_fk1 FOREIGN KEY (liked_by) REFERENCES users (id)
);

-- Черный список

CREATE TABLE black_lists (
	user_id bigint UNSIGNED NOT NULL,
	user_in_black bigint UNSIGNED NOT NULL,
	PRIMARY KEY (user_id, user_in_black),
	CONSTRAINT user_id_fk FOREIGN KEY (user_id) REFERENCES users (id),
	CONSTRAINT user_in_black_fk FOREIGN KEY (user_id) REFERENCES users (id)
);

-- Школы, университеты для профиля пользователя

CREATE TABLE schools (
	school_id bigint UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
	school_name varchar(245) NOT NULL,
	street varchar(245) NOT NULL,
	num_house MEDIUMINT unsigned NOT NULL,
	korpus TINYINT UNSIGNED DEFAULT NULL,
	city varchar(50) NOT NULL, 
	number_school varchar(10) -- в номерах школ могут встречаться буквы
);

CREATE TABLE university (
	university_id bigint UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
	university_name varchar(245) NOT NULL,
	street varchar(245) NOT NULL,
	num_house MEDIUMINT unsigned NOT NULL,
	korpus TINYINT UNSIGNED DEFAULT NULL,
	city varchar(50) NOT NULL
);

CREATE TABLE user_school (
	user_id bigint UNSIGNED NOT NULL PRIMARY KEY,
	school_id bigint UNSIGNED DEFAULT NULL,
	CONSTRAINT user_id_edu_fk FOREIGN KEY (user_id) REFERENCES users (id),
	CONSTRAINT school_id_fk FOREIGN KEY (school_id) REFERENCES schools (school_id)
);


CREATE TABLE user_university (
	user_id bigint UNSIGNED NOT NULL PRIMARY KEY,
	university_id bigint UNSIGNED DEFAULT NULL,
	CONSTRAINT user_id_edu_fk FOREIGN KEY (user_id) REFERENCES users (id),
	CONSTRAINT university_id_fk FOREIGN KEY (university_id) REFERENCES university (university_id)
);


-- Чаты (на несколько пользователей)
DROP TABLE IF EXISTS chats;

CREATE TABLE chats (
	chat_id bigint UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
	chat_name varchar(145) NOT NULL,
	creator bigint UNSIGNED NOT NULL,
	created_at datetime NOT NULL DEFAULT current_timestamp,
	CONSTRAINT creator_fk FOREIGN KEY (creator) REFERENCES users (id)
);

CREATE TABLE chat_messages(
	message_id bigint UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
	message_text text NOT NULL,
	created_by bigint UNSIGNED NOT NULL,
	created_at datetime NOT NULL DEFAULT current_timestamp,
	in_chat_id bigint UNSIGNED NOT NULL,
	INDEX created_by_inx (created_by),
	INDEX in_chat_id_inx (in_chat_id),
	CONSTRAINT created_by_fk FOREIGN KEY (created_by) REFERENCES users (id),
	CONSTRAINT in_chat_id_fk FOREIGN KEY (in_chat_id) REFERENCES chats(chat_id)
);

CREATE TABLE chat_members (
	chat_id bigint UNSIGNED NOT NULL,
	member_id bigint UNSIGNED NOT NULL,
	PRIMARY KEY (chat_id, member_id),
	CONSTRAINT chat_id_fk FOREIGN KEY (chat_id) REFERENCES chats (chat_id),
	CONSTRAINT member_id_fk FOREIGN KEY (member_id) REFERENCES users (id)
);

-- Посты в сообществе

CREATE TABLE community_posts (
	post_id bigint UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
	post_text text NOT NULL,
	created_by bigint UNSIGNED NOT NULL,
	created_at datetime NOT NULL DEFAULT current_timestamp,
	in_community_id bigint UNSIGNED NOT NULL,
	INDEX created_by_user_inx (created_by),
	INDEX in_community_id_inx (in_community_id),
	CONSTRAINT created_by_fk FOREIGN KEY (created_by) REFERENCES users (id),
	CONSTRAINT in_community_id_fk FOREIGN KEY (in_community_id) REFERENCES communities (id)
);






