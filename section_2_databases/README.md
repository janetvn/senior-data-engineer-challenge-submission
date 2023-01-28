# SECTION 2: DATABASES
This sections contains the setup for a simple PostgreSQL container database, which stores sales transactions, and the analytical SQL statements for the analysts. 

## POSTGRESQL DATABASE

### Prerequisites 
- Install Docker Desktop 

## **Set up PostgreSQL:**
1. Navigate to folder `postgresql`
2. Make the Bash script `setup_postgresql.sh` executable by running the following command:

```
chmod +x setup_postgresql.sh
```

3. Run the bash script `setup_postgresql.sh`:
``
./setup_postgresql.sh
``
4. After the script finishes running, you can connect to the database using software like **DBeaver** or **PgAdmin** with the following login credentials login:
```
host: locahost
port: 5432
database: web
user: application
password: XfQFEiqZsMOz
```
5. The database `web` includes 3 tables: `members`, `items`, and `transactions`

![ER Digram](postgresql/er_diagram.png?raw=true "Title")


## ANALYTICAL SQL QUERY 

### Which are the top 10 members by spending

Run the SQL query in file ``section_2_databases/analytical_sql/top_3_items_frequently_bought.sql``

### Which are the top 3 items that are frequently brought by members

Run the SQL query in file ``section_2_databases/analytical_sql/top_10_members_by_spending.sql``