-- lesson 10

-- Создайте таблицу logs типа Archive. Пусть при каждом создании записи в таблицах 
-- users, catalogs и products в таблицу logs помещается время и дата создания записи, 
-- название таблицы, идентификатор первичного ключа и содержимое поля name.

DROP DATABASE IF EXISTS lesson10;
CREATE DATABASE lesson10;

USE lesson10;

-- таблицы users, catalogs и products копирую из source9

DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Имя покупателя',
  birthday_at DATE COMMENT 'Дата рождения',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Покупатели';

DROP TABLE IF EXISTS catalogs;
CREATE TABLE catalogs (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название раздела',
  UNIQUE unique_name(name(10))
) COMMENT = 'Разделы интернет-магазина' ENGINE=InnoDB;

DROP TABLE IF EXISTS products;
CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название',
  desription TEXT COMMENT 'Описание',
  price DECIMAL (11,2) COMMENT 'Цена',
  catalog_id INT UNSIGNED,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY index_of_catalog_id (catalog_id)
) COMMENT = 'Товарные позиции';

-- Теперь создаем таблицу logs 

DROP TABLE IF EXISTS logs;
CREATE TABLE logs(
	id bigint UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
	created_at datetime NOT NULL DEFAULT current_timestamp,
	table_name varchar(200) NOT NULL,
	id_row bigint UNSIGNED NOT NULL,
	name_row VARCHAR(255)
) engine=archive;

-- Создаем триггеры для заполнения

DROP TRIGGER IF EXISTS log_info;

delimiter $$ -- как всегда в Dbeaver не работает поэтому эта часть скопирована и выполнена в cmd

CREATE TRIGGER log_info_users AFTER INSERT ON users
FOR EACH ROW BEGIN
	INSERT INTO logs (id_row, table_name, name_row) VALUES (NEW.id, "users", NEW.name);	
END$$

CREATE TRIGGER log_info_products AFTER INSERT ON products
FOR EACH ROW BEGIN
	INSERT INTO logs (id_row, table_name, name_row) VALUES (NEW.id, "products", NEW.name);	
END$$

CREATE TRIGGER log_info_catalogs AFTER INSERT ON catalogs
FOR EACH ROW BEGIN
	INSERT INTO logs (id_row, table_name, name_row) VALUES (NEW.id, "catalogs", NEW.name);	
END$$
delimiter ;

-- Теперь вставляем записи во все 3 таблицы (заполнение взято из source9)

INSERT INTO users (name, birthday_at) VALUES
  ('Геннадий', '1990-10-05'),
  ('Наталья', '1984-11-12'),
  ('Александр', '1985-05-20'),
  ('Сергей', '1988-02-14'),
  ('Иван', '1998-01-12'),
  ('Мария', '1992-08-29');
 
 INSERT INTO catalogs VALUES
  (NULL, 'Процессоры'),
  (NULL, 'Материнские платы'),
  (NULL, 'Видеокарты'),
  (NULL, 'Жесткие диски'),
  (NULL, 'Оперативная память');
 
 DELETE FROM products; -- случайно заполнила до catalogs - посмотрим как это отразится в логах
  
 INSERT INTO products
  (name, desription, price, catalog_id)
VALUES
  ('Intel Core i3-8100', 'Процессор для настольных персональных компьютеров, основанных на платформе Intel.', 7890.00, 1),
  ('Intel Core i5-7400', 'Процессор для настольных персональных компьютеров, основанных на платформе Intel.', 12700.00, 1),
  ('AMD FX-8320E', 'Процессор для настольных персональных компьютеров, основанных на платформе AMD.', 4780.00, 1),
  ('AMD FX-8320', 'Процессор для настольных персональных компьютеров, основанных на платформе AMD.', 7120.00, 1),
  ('ASUS ROG MAXIMUS X HERO', 'Материнская плата ASUS ROG MAXIMUS X HERO, Z370, Socket 1151-V2, DDR4, ATX', 19310.00, 2),
  ('Gigabyte H310M S2H', 'Материнская плата Gigabyte H310M S2H, H310, Socket 1151-V2, DDR4, mATX', 4790.00, 2),
  ('MSI B250M GAMING PRO', 'Материнская плата MSI B250M GAMING PRO, B250, Socket 1151, DDR4, mATX', 5060.00, 2);
 
 SELECT * FROM logs; -- в таблице отразились все вставки
 
 -- Задание 2
 
 -- (по желанию) Создайте SQL-запрос, который помещает в таблицу users миллион записей.

 
 CREATE TABLE new_users (
	id int UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
	login varchar(200),
	created_at datetime DEFAULT current_timestamp
 );


-- можно здесь создать процедуру..... но в задании не уточнено никак, какими должны быть записи. 1000000 = 10**6. то есть нам нужно
-- 10 записей, которые потом можно "перемножить" каждую с каждой.
-- Создадим эти 10 записей.

INSERT INTO new_users (login) VALUES 
("Abracham"),
("Black_bat"),
("Vampire_kiss"),
("Gothic_sphinx"),
("Nindzya"),
("Rowbow_ponie"),
("Blood_door"),
("Key_for_nothing"),
("Batman"),
("Nanny_Egg");

-- Теперь мы можем выполнить задание:

START TRANSACTION;
INSERT INTO new_users (login)
(SELECT new_users1.login FROM 
new_users AS new_users1,
new_users AS new_users2,
new_users AS new_users3,
new_users AS new_users4,
new_users AS new_users5,
new_users AS new_users6);

-- На моем компьютере эта операция заняла ровно 10 секунд :)

SELECT count(*) FROM new_users; -- получили 1000010 записей (10 были изначально)
SELECT * FROM new_users LIMIT 5; 
-- получили полностью заполненную таблицу. Конечно, логины повторяются, но при 
-- любой реализации этого задания данные не будут осмысленны :) если только не сидеть и не придумывать эти 1000000 записей)) 

ROLLBACK; -- мы ведь не хотим реально сохранять в памяти столько ненужных строк

-- проверяем, что операция благополучно откатилась назад

SELECT count(*) FROM new_users; -- получили 10 как и ожидалось


 