/*
 * Пусть в таблице users поля created_at и updated_at оказались незаполненными. Заполните их текущими датой и временем.
 * */

-- ! в задании совершенно неясно, откуда брать таблицы. некоторые (вроде)
-- есть в sourse.zip - но не все подходят под условия. 


DROP DATABASE IF EXISTS lesson5;

CREATE DATABASE lesson5;

USE lesson5;

CREATE TABLE users (
	id bigint UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name varchar(100) NOT NULL,
	created_at datetime,
	updated_at datetime
);

INSERT INTO users (name) VALUES
	('Dmitry'),
	('Anatoliy'),
	('Ivan');
	
SELECT * FROM users;

UPDATE users SET created_at = NOW(), updated_at = NOW() WHERE created_at IS NULL AND updated_at IS NULL;
-- если есть записи, где заполнено только одно значение, то нужно по отдельности заполнять каждый из 
-- столбцов - тогда выйдет 2 запроса. (не могу придумать, как покрыть все 3 случая одним запросом, 
-- где либо 1 столбец null либо второй либо оба). 

SELECT * FROM users;

/*
 * Таблица users была неудачно спроектирована. Записи created_at и updated_at были заданы типом VARCHAR 
 * и в них долгое время помещались значения в формате 20.10.2017 8:10. 
 * Необходимо преобразовать поля к типу DATETIME, сохранив введённые ранее значения.
 */

DROP TABLE users;


CREATE TABLE users (
	id bigint UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name varchar(100) NOT NULL,
	created_at varchar(50),
	updated_at varchar(50)
);

INSERT INTO users (name, created_at, updated_at) VALUES 
	('Victor', '20.10.2017 8:10', '21.10.2017 18:10'),
	('Anna', '20.11.2017 1:10', '21.9.2017 22:10'),
	('Vladilen', '20.5.2017 5:10', '21.9.2007 23:10');

SELECT * FROM users;

ALTER TABLE users ADD created_at1 DATETIME;
ALTER TABLE users ADD updated_at1 DATETIME;

-- ????????????
-- почему не сработало в 1 строку?? пыталась сделать так: 
-- ALTER TABLE users ADD created_at1 DATETIME, updated_at1 DATETIME;

UPDATE users SET 
	created_at1 = str_to_date(created_at, '%d.%m.%Y %h:%i'),
	updated_at1 = str_to_date(created_at, '%d.%m.%Y %h:%i');
-- ?????????
-- Тот же самый синтаксис не сработал, когда встречалось значение
-- '20.11.2017 0:10'. Не нашла, как в этом случае обработать ошибку. 

ALTER TABLE users DROP created_at, DROP updated_at;

ALTER TABLE users 
	RENAME COLUMN created_at1 TO created_at,
	RENAME COLUMN updated_at1 TO updated_at;

SELECT * FROM users;


/*3.
 * В таблице складских запасов storehouses_products в поле value могут встречаться 
 * самые разные цифры: 0, если товар закончился и выше нуля, если на складе имеются запасы. 
 * Необходимо отсортировать записи таким образом, чтобы они выводились в порядке 
 * увеличения значения value. Однако нулевые запасы должны выводиться в конце, после всех записей.
 * */

-- Полагаю, эту таблицу можно взять из source (однако она там не заполнена)....

DROP TABLE IF EXISTS storehouses_products;
CREATE TABLE storehouses_products (
  id SERIAL PRIMARY KEY,
  storehouse_id INT UNSIGNED,
  product_id INT UNSIGNED,
  value INT UNSIGNED COMMENT 'Запас товарной позиции на складе',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Запасы на складе';

INSERT INTO storehouses_products (storehouse_id, product_id, value) VALUES 
	(1, 1, 1),
	(2, 2, 0),
	(2, 2, 7),
	(1, 1, 1),
	(5, 7, 2),
	(3, 7, 0),
	(3, 7, 0),
	(3, 7, 11),
	(1, 2, 10);

-- честно говоря, не знаю как это сделать не прибегая к костылям. Костыльное решение приходит такое:

ALTER TABLE storehouses_products ADD COLUMN is_not_null boolean;

UPDATE storehouses_products SET is_not_null = 1 WHERE value > 0;

SELECT value FROM storehouses_products ORDER BY is_not_null DESC, value;


--- Добавлено позднее: нашла любопытную функцию field, пока делала 5е задание. Наверное можно сделать так:
SELECT value FROM storehouses_products ORDER BY field(value, 0) ASC, value; 


/*
 * (по желанию) Из таблицы users необходимо извлечь пользователей, родившихся в августе и мае. 
 * Месяцы заданы в виде списка английских названий (may, august)
 * */

-- Снова неясно откуда брать таблицу. В source есть, но спорная по подходящести: непонятно, это они в таблице 
-- должны быть заданы изначально как (may, august) ? (тогда слишком простое задание выходит).
-- Или нужно извлечь их так, чтобы месяц отображался так? 
-- Исходя из имеющейся таблицы в source предполагаю 2й вариант. 

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
  ('Мария', '1992-08-29'); -- скопировала из source
  
  
-- Наверное можно как-то проще но не знаю как
SELECT name,
CASE 
 	WHEN MONTH(birthday_at) = 5 THEN 'may'
 	WHEN MONTH(birthday_at) = 8 THEN 'august'
END AS bm
FROM users where MONTH(birthday_at) = 5 OR MONTH(birthday_at) = 8;

/* 5.
 * (по желанию) Из таблицы catalogs извлекаются записи при помощи запроса. 
 * SELECT * FROM catalogs WHERE id IN (5, 1, 2); 
 * Отсортируйте записи в порядке, заданном в списке IN.
 * */

-- нашла такую таблицу в source
DROP TABLE IF EXISTS catalogs;
CREATE TABLE catalogs (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название раздела',
  UNIQUE unique_name(name(10))
) COMMENT = 'Разделы интернет-магазина';

-- там вставлены данные вот так:
INSERT INTO catalogs VALUES
  (NULL, 'Процессоры'),
  (NULL, 'Материнские платы'),
  (NULL, 'Видеокарты'),
  (NULL, 'Жесткие диски'),
  (NULL, 'Оперативная память');
 
SELECT * FROM catalogs WHERE id IN (5, 1, 2) ORDER BY field(id, 5,1,2);

/* 1.
 * Подсчитайте средний возраст пользователей в таблице users.
 * */
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
 
 SELECT avg((TO_DAYS(now()) - TO_DAYS(birthday_at))/365.25) FROM users;

/* 2.
 * Подсчитайте количество дней рождения, которые приходятся на каждый из дней недели. 
 * Следует учесть, что необходимы дни недели текущего года, а не года рождения.
 * */

-- совсем не понятно условие про "текущего" года... что это значит? мы должны применить день и месяц 
-- к текущему году и взять какая была бы неделя если бы пользователь родился в этом году??....... 
-- очень запутанное условие.


SELECT count(*), 
weekday(DATE_ADD(birthday_at, INTERVAL (year(now()) - YEAR(birthday_at)) year)) as week_date FROM users
GROUP BY week_date;

/*
 * (по желанию) Подсчитайте произведение чисел в столбце таблицы.
 * */

----- ????????????????? в столбце какой из таблиц?.....

CREATE TABLE strange_table(
	values_t int UNSIGNED NOT NULL
);

INSERT INTO strange_table VALUES
(1),
(5),
(6),
(10);

-- логарифм произведения равен сумме логарифмов. EXP - обратен логарифму. Честно сказать, это 
-- страшное выражение подсказал гугл.  
SELECT EXP(SUM(LOG(values_t))) FROM strange_table;


---- Впрочем ВОЗМОЖНО имелась в виду эта таблица из source4 (прям нравится это д\з, угадайка)

CREATE TABLE tbl (
  id INT NOT NULL,
  value INT DEFAULT NULL
);
INSERT INTO tbl VALUES (1, 230);
INSERT INTO tbl VALUES (2, NULL);
INSERT INTO tbl VALUES (3, 405);
INSERT INTO tbl VALUES (4, NULL);

-- тогда все получается куда "интереснее", т.к. в столбце value есть NULL. В этом случае непонятно, какой ответ 
-- должен быть канонически верным: по sql правилам любые операции с NULL должны равняться NULL. Мы должны 
-- проверить, есть ли NULL и если нет - вывести произведение , а если да - то вывести NULL?.........

-- тут пришлось поломать голову
SELECT 
CASE 
	WHEN count(*) != count(value) THEN NULL
	WHEN count(*) = count(value) THEN EXP(SUM(LOG(value)))
END AS mult
FROM tbl;

-- ИЛИ предполагается, что мы должны перемножить все значения кроме null?...................

-- тогда можно попробовать заменить null на 1, чтобы не мешались
SELECT EXP(SUM(LOG(ifnull(value,1)))) FROM tbl;

-- короче жесть.  :) 




