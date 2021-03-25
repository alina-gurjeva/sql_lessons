DROP DATABASE IF EXISTS lesson7;
CREATE DATABASE lesson7;

-- 1. Составьте список пользователей users, которые осуществили хотя бы один заказ orders в интернет магазине.

-- В базу скопировала таблицы из source5 

USE lesson7;
SHOW tables;

SELECT * FROM users LIMIT 5;

SELECT * FROM orders LIMIT 5; -- таблица пустая

-- для нормального запроса все же заполню таблицу, иначе "составьте список" - ответ: пусто, в данном кейсе...

INSERT INTO orders (user_id) VALUES
	(2),
	(4),
	(4),
	(1);
-- связанная таблица (тоже пустая)
INSERT INTO orders_products (order_id, product_id, total) VALUES 
(1, 1, 1),
(2, 3, 2),
(2, 5, 1),
(3, 6, 2),
(4, 6, 1),
(4, 7, 3); -- на самом деле к этому заданию она не нужна заполненной, (достаточно 1й)

-- Само решение
SELECT * FROM users INNER JOIN orders ON orders.user_id = users.id; -- искомый список. Поскольку не указано, какие поля 
-- нужны, выводим все.

-- Усложним задачу. Выведем всех, кто НЕ совершил ни одного заказа
SELECT users.id, name FROM users WHERE users.id NOT IN (SELECT users.id FROM users 
	INNER JOIN orders ON orders.user_id = users.id);

-- 2й способ
SELECT DISTINCT users.id, name FROM users 
	LEFT JOIN orders ON orders.user_id = users.id 
	WHERE orders.user_id IS NULL;

-- Выведем всех, кто совершил больше 1й покупки
SELECT users.id, users.name, count(*) cnt FROM users INNER JOIN orders ON orders.user_id = users.id 
	GROUP BY users.id HAVING cnt > 1;

-- Задание 2

-- Выведите список товаров products и разделов catalogs, который соответствует товару.


-- (в задании не уточнено), вывожу только name из products, т.к. иначе слишком много столбцов ничего не видно
SELECT products.name, catalogs.name FROM products INNER JOIN catalogs
	ON products.catalog_id = catalogs.id;

-- Задание 3

/*(по желанию) Пусть имеется таблица рейсов flights (id, from, to) 
 * и таблица городов cities (label, name). 
 * Поля from, to и label содержат английские названия городов, 
 * поле name — русское. Выведите список рейсов flights с русскими названиями городов.
 * */

-- такой таблицы нет в материалах
CREATE TABLE flights (
	id bigint UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
	from_ varchar(100) NOT NULL, -- english
	to_ varchar(100) NOT NULL -- english
);

-- такой таблицы тоже нет
CREATE TABLE cities (
	label varchar(100) NOT NULL, -- english
	name varchar(100) NOT NULL, -- russian
	PRIMARY KEY (label, name)
);

ALTER TABLE flights ADD CONSTRAINT from_fk FOREIGN KEY (from_) REFERENCES cities (label),
	ADD CONSTRAINT to_fk FOREIGN KEY (to_) REFERENCES cities (label);

INSERT INTO cities VALUES 
	("Moscow", "Москва"),
	("London", "Лондон"),
	("New-York", "Нью-Йорк"),
	("Tirana", "Тирана"),
	("Edinburg", "Эдинбург"),
	("Berlin", "Берлин"),
	("Cair", "Каир"),
	("Tokio", "Токио");

INSERT INTO flights (from_, to_) VALUES
	("Moscow", "London"),
	("London", "New-York"),
	("Edinburg", "Tirana"),
	("Berlin", "London"),
	("Moscow", "Berlin");

-- Само задание
SELECT fr, to_ FROM 
(SELECT flights.id fi, cities.name fr 
FROM flights INNER JOIN cities
ON flights.from_ = cities.label) A
INNER JOIN 
(SELECT flights.id fi, cities.name to_ 
FROM flights INNER JOIN cities
ON flights.to_ = cities.label) B 
ON A.fi = B.fi
ORDER BY A.fi;
















