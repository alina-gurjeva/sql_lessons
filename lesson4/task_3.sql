-- task 3
USE vk2;

SHOW tables;

DESCRIBE media_types;

SELECT * FROM media_types;

UPDATE media_types SET name = 'images' WHERE id = 1;
UPDATE media_types SET name = 'audio' WHERE id = 2;
UPDATE media_types SET name = 'docs' WHERE id = 3;
UPDATE media_types SET name = 'books' WHERE id = 4; -- не придумала 4 тип

