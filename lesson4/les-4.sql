/*
 * Модифицируем базу
 */

-- CHECK CONSTRAINTS
USE vk;

SHOW tables;

-- совершенствуем таблицу дружбы
DROP TABLE friend_requests;

CREATE TABLE friend_requests (
  from_user_id BIGINT UNSIGNED NOT NULL,
  to_user_id BIGINT UNSIGNED NOT NULL,
  accepted BOOLEAN DEFAULT False,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (from_user_id, to_user_id),
  INDEX fk_friend_requests_from_user_idx (from_user_id),
  INDEX fk_friend_requests_to_user_idx (to_user_id),
  CONSTRAINT fk_friend_requests_users_1 FOREIGN KEY (from_user_id) REFERENCES users (id),
  CONSTRAINT fk_friend_requests_users_2 FOREIGN KEY (to_user_id) REFERENCES users (id)
);

-- добавляем ограничение, что отправитель запроса на дружбу 
-- не может быть одновременно и получателем
ALTER TABLE friend_requests 
ADD CONSTRAINT sender_not_reciever_check 
CHECK (from_user_id != to_user_id);

-- меняем тип колонки users на char(11)
ALTER TABLE users MODIFY COLUMN phone VARCHAR(11);

-- добавляем ограничение, что номер телефона должен состоять из 11
-- символов и только из цифр
ALTER TABLE users 
ADD CONSTRAINT phone_check
CHECK (REGEXP_LIKE(phone, '^[0-9]{11}$'));

-- смотрим, как создана таблица messages
SHOW CREATE TABLE messages;

-- модифицируем поле updated_at, чтобы значения обновлялись
ALTER TABLE messages MODIFY COLUMN updated_at DATETIME DEFAULT NULL ON UPDATE NOW();

-- делаем id photo пользователей уникальными
ALTER TABLE profiles MODIFY COLUMN photo_id BIGINT UNSIGNED DEFAULT NULL UNIQUE;

-- делаем все названия типов медиа уникальными
ALTER TABLE media_types MODIFY COLUMN name VARCHAR(45) NOT NULL UNIQUE;

/* 
  C - Create = INSERT
  R - Read   = SELECT
  U - Update = UPDATE
  D - Delete = DELETE
*/

/*
 * INSERT
 * https://dev.mysql.com/doc/refman/8.0/en/insert.html
 */

USE vk;

DESCRIBE users;

-- добавляем пользователя
INSERT INTO users (id, first_name, last_name, email, phone, password_hash)
VALUES (DEFAULT, 'Alex', 'Stepanov', 'alex@mail.com', '89213546566', 'aaa');

-- смотрим содержимое таблицы users
SELECT * FROM users;

-- добавляем повторно того же пользователя, ошибка не возникает
INSERT IGNORE INTO users (id, first_name, last_name, email, phone, password_hash)
VALUES (DEFAULT, 'Alex', 'Stepanov', 'alex@mail.com', '89213546566', 'aaa');

-- не указываем default значения
INSERT INTO users (first_name, last_name, email, phone)
VALUES ('Lena', 'Stepanova', 'lena@mail.com', '89213546568');

-- не указываем названия колонок
INSERT INTO users VALUES 
(DEFAULT, 'Chris', 'Ivanov', 'chris@mail.com', '89213546560', DEFAULT, DEFAULT);

-- явно задаем id
INSERT INTO users (id, first_name, last_name, email, phone) VALUES 
(55, 'Jane', 'Kvanov', 'jane@mail.com', '89293546560');

-- пробуем добавить id меньше текущего
INSERT INTO users (id, first_name, last_name, email, phone) VALUES 
(45, 'Jane', 'Night', 'jane_n@mail.com', '89293946560');

-- добавляем несколько пользователей
INSERT INTO users (first_name, last_name, email, phone)
VALUES ('Igor', 'Petrov', 'igor@mail.com', '89213549560'),
       ('Oksana', 'Petrova', 'oksana@mail.com', '89213549561');
      
-- добавляем через SET
INSERT INTO users
SET first_name = 'Iren',
    last_name = 'Sidorova',
    email = 'iren@mail.com',
    phone = '89213541560';
   
-- добавляем через SELECT

# INSERT INTO users (first_name, last_name, email, phone)
# SELECT (first_name, last_name, email, phone) FROM vk2.users;
   
-- добавляем через SELECT и производную таблицу
INSERT INTO users (first_name, last_name, email, phone)
SELECT * FROM (
  SELECT 'Alina', 'Kobrina', 'alina@mail.com', '89210549561'
 ) AS default_user;


/*
 * SELECT
 * https://dev.mysql.com/doc/refman/8.0/en/select.html
 */

-- выбираем константы
SELECT 1;

SELECT 10 + 1;

-- выбираем все поля users
SELECT * FROM users;

-- выбираем только имена users
SELECT first_name
FROM users;

-- выбираем только уникальные имена
SELECT DISTINCT first_name
FROM users;

-- выбираем пользователей, у которых есть hash пароля 
SELECT *
FROM users
WHERE password_hash IS NOT NULL;

-- выбираем пользователей, у которых нет hash пароля 
SELECT *
FROM users
WHERE password_hash IS NULL;

-- выбираем четырех первых пользователей
SELECT *
FROM users
ORDER BY id
LIMIT 4;

-- выбираем четвертого пользователя (четвертый номер id по порядку)
SELECT *
FROM users
ORDER BY id
LIMIT 1 offset 3;

/*
 * UPDATE
 * https://dev.mysql.com/doc/refman/8.0/en/update.html 
*/

INSERT INTO messages (from_user_id, to_user_id, txt)
VALUES (45, 55, 'Hi!');

INSERT INTO messages (from_user_id, to_user_id, txt)
VALUES (45, 55, 'I hate you!');

SELECT * FROM messages;

-- меняем статус на сообщение доставлено
UPDATE messages
SET 
	is_delivered = TRUE;

-- меняем текст сообщения
UPDATE messages
SET 
	txt = 'I love you'
WHERE id = 2;

/*
 * DELETE
 * https://dev.mysql.com/doc/refman/8.0/en/update.html 
 * TRUNCATE
 * https://dev.mysql.com/doc/refman/8.0/en/truncate-table.html
*/

-- удаляем пользователя с фамилией Степанов
DELETE FROM users WHERE last_name = 'Stepanov';

-- удаляем все строки из messages
TRUNCATE TABLE messages;

-- Нельзя так почистить таблицу, на которую есть внешние ключи
# TRUNCATE TABLE users;

-- удаляем все строки из таблицы users
DELETE FROM users;

-- обнуляем auto_increment
ALTER TABLE users AUTO_INCREMENT = 1;

-- обнуляем ограничение на проверку наличия на таблицу внешних ключей,
-- чистим таблицы, возвращаем проверку
SET FOREIGN_KEY_CHECKS = 0; 
TRUNCATE TABLE users;
SET FOREIGN_KEY_CHECKS = 1;

/*
 * Заполняем таблицы
 */

-- делаем дамп базы
-- mysqldump -u root -p vk > vk-empty.sql



