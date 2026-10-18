# Concert Management Database — CS6401

A relational database project developed for the CS6401 Database Systems module. The project models concert management, including artists, albums, songs, concerts, fans, tickets, and seat reservations.

## Project Overview

The database uses MySQL to demonstrate relational database design, data integrity, SQL queries, and database programmability.

## Features

- Relational schema with primary keys and foreign keys
- Many-to-many relationships between artists, albums, songs, and concerts
- Concert ticket and seat reservation management
- SQL view using joins, grouping, and a HAVING condition
- BEFORE and AFTER triggers for reservation validation and auditing
- Stored function to count reserved seats for a concert
- Stored procedure to associate songs with albums and handle release dates
- SQL test cases covering functionality and integrity constraints

## Technologies

- MySQL
- DBeaver Community Edition
- SQL

## Repository Structure

- `sql/modified_concerts_schema.sql` — database schema
- `sql/data.sql` — sample data
- `sql/code.sql` — view, triggers, function, and procedure
- `sql/tests.sql` — SQL test cases
- `report/` — project report and ER diagram

## Getting Started

1. Install MySQL and a database client such as DBeaver.
2. Execute `modified_concerts_schema.sql`.
3. Execute `data.sql`.
4. Execute `code.sql`.
5. Execute `tests.sql`, running statements marked as expected errors separately.
6. Read the project report for the design rationale and test explanations.

**Note:** The schema script drops and recreates project tables. Run it only in a dedicated project database, as existing data may be lost.

## Academic Project

This repository documents an academic database project. Refer to the report for the project scope, design decisions, and evaluation.
