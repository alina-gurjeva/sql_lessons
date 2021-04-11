-- 1. В базе данных shop и sample присутствуют одни и те же таблицы, учебной базы данных. 
-- Переместите запись id = 1 из таблицы shop.users в таблицу sample.users. Используйте транзакции.



-- т.к. типа таблицы одинаковые - значит и записи в них должны быть одинаковые?...... Непонятно, как переместить
-- запись, которая очевидно будет дублироваться .. Что ж, опять играем в "угадай что имели в виду авторы"

-- Предположим, они имели в виду, что sample.users не заполненная. И что shop.sql нужно сначала создать базу данных
-- shops и исполнить в ней этот скрипт, а потом - базу данных sample, и исполнить скрипт только заполнения таблицами. 

-- (скрипт заполнения)
CREATE DATABASE IF NOT EXISTS sample1; -- sample - неудачное название, уже есть такая БД
CREATE DATABASE IF NOT EXISTS shop;

USE shop;

-- скопировано из source6
DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Имя покупателя',
  birthday_at DATE COMMENT 'Дата рождения',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Покупатели';

INSERT INTO users (name, birthday_at) VALUES
  ('Геннадий', '1990-10-05'),
  ('Наталья', '1984-11-12'),
  ('Александр', '1985-05-20'),
  ('Сергей', '1988-02-14'),
  ('Иван', '1998-01-12'),
  ('Мария', '1992-08-29');

 USE sample1;
DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Имя покупателя',
  birthday_at DATE COMMENT 'Дата рождения',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Покупатели';

-- Посмотрим что теперь находится в искомых таблицах: 

SELECT * FROM sample1.users;
SELECT * FROM shop.users;

-- Само задание

START TRANSACTION;

INSERT INTO sample1.users SELECT * FROM shop.users WHERE id = 1;
DELETE FROM shop.users WHERE id = 1;

COMMIT;


-- 2 -- 
-- Создайте представление, которое выводит название name товарной позиции из таблицы products 
-- и соответствующее название каталога name из таблицы catalogs.

-- копируем из source6 то что есть по таблицам с этими названиями

USE shop;
DROP TABLE IF EXISTS catalogs;
CREATE TABLE catalogs (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название раздела',
  UNIQUE unique_name(name(10))
) COMMENT = 'Разделы интернет-магазина';

INSERT INTO catalogs VALUES
  (NULL, 'Процессоры'),
  (NULL, 'Материнские платы'),
  (NULL, 'Видеокарты'),
  (NULL, 'Жесткие диски'),
  (NULL, 'Оперативная память');
 
 DROP TABLE IF EXISTS products;
CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название',
  description TEXT COMMENT 'Описание',
  price DECIMAL (11,2) COMMENT 'Цена',
  catalog_id INT UNSIGNED,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY index_of_catalog_id (catalog_id)
) COMMENT = 'Товарные позиции';

INSERT INTO products
  (name, description, price, catalog_id)
VALUES
  ('Intel Core i3-8100', 'Процессор для настольных персональных компьютеров, основанных на платформе Intel.', 7890.00, 1),
  ('Intel Core i5-7400', 'Процессор для настольных персональных компьютеров, основанных на платформе Intel.', 12700.00, 1),
  ('AMD FX-8320E', 'Процессор для настольных персональных компьютеров, основанных на платформе AMD.', 4780.00, 1),
  ('AMD FX-8320', 'Процессор для настольных персональных компьютеров, основанных на платформе AMD.', 7120.00, 1),
  ('ASUS ROG MAXIMUS X HERO', 'Материнская плата ASUS ROG MAXIMUS X HERO, Z370, Socket 1151-V2, DDR4, ATX', 19310.00, 2),
  ('Gigabyte H310M S2H', 'Материнская плата Gigabyte H310M S2H, H310, Socket 1151-V2, DDR4, mATX', 4790.00, 2),
  ('MSI B250M GAMING PRO', 'Материнская плата MSI B250M GAMING PRO, B250, Socket 1151, DDR4, mATX', 5060.00, 2);
 
 -- само задание
 -- (вспоминаем неточность из прошлого дз где по этим же таблицам имелось в виду, что в каталогах
 -- может быть NULL (нет каталога для продукта)
 
 
 -- Создайте представление, которое выводит название name товарной позиции из таблицы products 
-- и соответствующее название каталога name из таблицы catalogs.
CREATE VIEW name_cat AS  
	SELECT products.name AS products_name, catalogs.name AS catalogs_name
	FROM 
	products LEFT JOIN catalogs -- Null catalog тоже нужен
	ON products.catalog_id = catalogs.id;

SELECT * FROM name_cat;

-- 3 --
-- по желанию) Пусть имеется таблица с календарным полем created_at. 
-- В ней размещены разряженые календарные записи за август 2018 года '2018-08-01', 
-- '2016-08-04', '2018-08-16' и 2018-08-17. Составьте запрос, который выводит полный 
-- список дат за август, выставляя в соседнем поле значение 1, 
-- если дата присутствует в исходном таблице и 0, если она отсутствует.



-- ! я не понимаю, что значит "разряженые" календарные записи............

-- конечно же в source такой таблицы нет...... 

CREATE TABLE strange (
	id serial PRIMARY KEY,
	created_at date NOT null
);

INSERT INTO strange (created_at) VALUES 
	('2018-08-01'),
	('2016-08-04'),
	('2018-08-16'),
	('2018-08-17');

-- в августе 31 день. 
CREATE TEMPORARY TABLE dates (DAY int);
INSERT INTO dates VALUES (1), (2), (3), (4), (5), (6), (7), (8), (9), (10), (11), (12), (13),
	(14), (15), (16), (17), (18), (19), (20), (21), (22), (23), (24), (25), (26), (27), (28),
	(29), (30), (31);

SELECT T.d, NOT ISnull(T.str) AS num
FROM 
(SELECT dates.DAY d, day(strange.created_at) AS str FROM 
dates LEFT JOIN strange
ON dates.DAY = day(strange.created_at)) T;


-- 4-- 
-- (по желанию) Пусть имеется любая таблица с календарным полем created_at. Создайте запрос, 
-- который удаляет устаревшие записи из таблицы, оставляя только 5 самых свежих записей.

-- добавим записи в strange таблицу и продолжим использовать ее
INSERT INTO strange (created_at) VALUES 
	('2019-12-01'),
	('2020-09-04'),
	('2021-02-16'),
	('2020-04-17'),
	('2019-05-01'),
	('2021-01-04'),
	('2021-03-16'),
	('2019-07-17');

CREATE TEMPORARY TABLE freshday (date_ date);
INSERT INTO freshday SELECT created_at FROM strange ORDER BY created_at DESC LIMIT 5;
DELETE FROM strange WHERE created_at NOT IN (SELECT * FROM freshday);

SELECT * FROM strange; -- осталось 5 записей


-- Практическое задание по теме “Администрирование MySQL”

-- 1-- 
-- Создайте двух пользователей которые имеют доступ к базе данных shop. 
-- Первому пользователю shop_read должны быть доступны только запросы на чтение данных, 
-- второму пользователю shop — любые операции в пределах базы данных shop.

CREATE USER 'only_read'@'localhost' IDENTIFIED WITH sha256_password BY 'pass';
GRANT SELECT, SHOW VIEW ON shop.* TO 'only_read'@'localhost';

CREATE USER 'all_can'@'localhost' IDENTIFIED WITH sha256_password BY 'pass2';
GRANT all ON shop.* TO 'all_can'@'localhost';

-- и удалить чтобы не висели

DROP USER 'only_read'@'localhost';
DROP USER 'all_can'@'localhost';

-- 2-- 

/*(по желанию) Пусть имеется таблица accounts содержащая три столбца id, name, password, 
содержащие первичный ключ, имя пользователя и его пароль. 
Создайте представление username таблицы accounts, предоставляющий доступ к столбца id и name. 
Создайте пользователя user_read, который бы не имел доступа к таблице accounts, 
однако, мог бы извлекать записи из представления username.*/

CREATE TABLE accounts (
	id int UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
	name varchar (200),
	pswd varchar (200)
);
INSERT INTO accounts (name, pswd) VALUES 
	("ktulhu", "1234"),
	("asag-tot", "2345"),
	("hastur", "3456"),
	("sothoth", "4567");

CREATE VIEW onlyname AS SELECT id, name FROM accounts;

CREATE USER 'user_read'@'localhost' IDENTIFIED WITH sha256_password BY 'pass';
GRANT SELECT (id, name) ON shop.onlyname TO 'user_read'@'localhost';

DROP USER 'user_read'@'localhost';


-- Практическое задание по теме “Хранимые процедуры и функции, триггеры"

/*
 * Создайте хранимую функцию hello(), которая будет возвращать приветствие, 
 * в зависимости от текущего времени суток. С 6:00 до 12:00 функция должна возвращать 
 * фразу "Доброе утро", с 12:00 до 18:00 функция должна возвращать фразу 
 * "Добрый день", с 18:00 до 00:00 — "Добрый вечер", с 00:00 до 6:00 — "Доброй ночи".
 * */

CREATE PROCEDURE hello ()
BEGIN
  SELECT VERSION();
END

-- delimiter. с ними вообще что-то не так. - не стал разделителем, работает только если выделить запрос + enter
DELIMITER -


CREATE FUNCTION hello ()
RETURNS TINYTEXT NO sql
BEGIN
	DECLARE h int;
	SET h = hour(current_timestamp());
	CASE 
	WHEN h BETWEEN 0 AND 5 THEN RETURN "good night";
 	WHEN h BETWEEN 6 AND 12 THEN RETURN "good morning";
 	WHEN h BETWEEN 13 AND 18 THEN RETURN "good afternoon";
 	WHEN h BETWEEN 19 AND 23 THEN RETURN "good evening";
END CASE;
END

DELIMITER ;

SELECT hello ();

/*В таблице products есть два текстовых поля: name с названием товара и description с его описанием. 
 * Допустимо присутствие обоих полей или одно из них. Ситуация, когда оба поля принимают 
 * неопределенное значение NULL неприемлема. Используя триггеры, добейтесь того, чтобы одно 
 * из этих полей или оба поля были заполнены. При попытке присвоить полям NULL-значение необходимо отменить операцию.
 * 
 * */

SELECT * FROM products;

-- delimiter. вообще перестал работать :(((( здесь. 
DELIMITER -
DELIMITER $$ -- ни один не работает 

-- скрипт выполнила в cmd , здесь дублирую (  Также сделала скриншот выполнения в cmd 
CREATE TRIGGER check_fields_insert BEFORE INSERT ON products
FOR EACH ROW BEGIN 
	IF NEW.name IS NULL AND NEW.description IS NULL THEN SIGNAL SQLSTATE '45000'; END IF;
END$$


CREATE TRIGGER check_fields_update BEFORE update ON products
FOR EACH ROW BEGIN 
	IF NEW.name IS NULL AND NEW.description IS NULL THEN SIGNAL SQLSTATE '45000'; END IF;
END$$


-- 3 --
/*(по желанию) Напишите хранимую функцию для вычисления произвольного числа Фибоначчи. 
 * Числами Фибоначчи называется последовательность в которой число равно сумме двух предыдущих чисел. 
 * Вызов функции FIBONACCI(10) должен возвращать число 55.
 * 
 */
 
-- здесь честное пасс )) т.к. без понятия как здесь сделать цикл или тем более рекурсию, это на питоне запросто
-- а тут.. - скажу сразу, погуглила, нашла "простое" решение типа: 

CREATE FUNCTION fib(num int)
RETURNS int DETERMINISTIC
BEGIN
	DECLARE f double;
	SET f = sqrt(5);
	RETURN (Pow((1+f)/2.0, num) + pow((1-f)/2.0, num)) /f;
END

-- также находила страшные решения-монстры типа:

CREATE FUNCTION Fib (@Digit INT)
	RETURNS NUMERIC(38)
	AS
BEGIN
	DECLARE @Counter INT, @One NUMERIC(38), @Two NUMERIC(38)
	
	SET @Two = 1
	
	IF @Digit > 2
		BEGIN
			SET @Counter = 3
			SET @One = 1
			
			WHILE @Digit >= @Counter
				BEGIN
					SET @Two = @One + @Two
					SET @One = @Two - @One
					SET @Counter = @Counter + 1
				END
		END	
 
	RETURN @Two
END

-- но это НЕ МОИ решения, исходя из материалов лекций и даже гугла - не додумалась бы до этого