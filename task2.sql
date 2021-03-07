/* LESSON 2

task 2

Создайте базу данных example, разместите в ней таблицу users, 
состоящую из двух столбцов, числового id и строкового name. */

create database example;
use example;

-- Создание таблицы

create table users (
id int unsigned not null auto_increment primary key,
name varchar(50) not null
)





