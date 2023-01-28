-- Create user 'application' and alter their passwords
CREATE USER application;
ALTER USER postgres with PASSWORD 'XfQFEiqZsMOz';
ALTER USER application with PASSWORD 'XfQFEiqZsMOz';

-- Create database 'web' and grant all privileges of this database to user 'application'
CREATE DATABASE web;
\c web;
GRANT ALL PRIVILEGES ON DATABASE web TO application;

-- Create table users
CREATE TABLE IF NOT EXISTS members (
	id varchar(255) NOT NULL,
	email varchar(255) NOT NULL DEFAULT ''::character varying,
	created_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
	updated_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
	deleted_at timestamp NULL,
	first_name varchar(255) NOT NULL,
	last_name varchar(255) NOT NULL,
	date_of_birth date,
	mobile_number int8,
	is_deleted bool NOT NULL DEFAULT false,
	CONSTRAINT users_pkey PRIMARY KEY (id)
);
CREATE INDEX idx_ead_searching ON members USING btree (first_name, last_name, email, id);
CREATE INDEX idx_users_created_at_date ON members USING btree (date(created_at));
CREATE INDEX index_users_on_deleted_at ON members USING btree (deleted_at);

-- Create table items
CREATE TYPE item_status AS ENUM ('active', 'pending', 'sold_out', 'deleted');

CREATE TABLE IF NOT EXISTS items (
	id serial4 NOT NULL,
	item_name varchar(255) NOT NULL DEFAULT ''::character varying,
	manufacturer_name varchar(255) NOT NULL DEFAULT ''::character varying,
	cost numeric(30, 18) NULL,
	weight numeric(30, 18) NULL,
	created_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
	updated_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
	deleted_at timestamp NULL,
	status ITEM_STATUS NOT NULL DEFAULT 'active',
	is_deleted bool NOT NULL DEFAULT false,
	CONSTRAINT items_pkey PRIMARY KEY (id)
);
CREATE INDEX idx_item_created_at_date ON items USING btree (date(created_at));
CREATE INDEX idx_item_status ON items USING btree (status);
CREATE INDEX idx_item_cost ON items USING btree (cost);

-- Create table transactions
CREATE TYPE transactions_status AS ENUM ('pending', 'active', 'done', 'cancelled');

CREATE TABLE transactions (
	id serial4 NOT NULL,
	member_id varchar(255) NOT NULL,
	item_id int8 NOT NULL,
	item_amount numeric(30, 18) NULL,
	item_price numeric(30, 18) NULL,
	item_total_price numeric(30, 18) NULL,
	item_total_weight numeric(30, 18) NULL,
	created_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
	updated_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
	status TRANSACTIONS_STATUS NOT NULL DEFAULT 'active',
	CONSTRAINT transactions_pkey PRIMARY KEY (id),
	CONSTRAINT membership FOREIGN KEY (member_id) REFERENCES members(id),
	CONSTRAINT item_sold FOREIGN KEY (item_id) REFERENCES items(id)
);
CREATE INDEX idx_transactions_created_at_date ON transactions USING btree (date(created_at));
CREATE INDEX index_transactions_on_item_id ON transactions USING btree (item_id);
CREATE INDEX index_transactions_on_member_id ON transactions USING btree (member_id);
