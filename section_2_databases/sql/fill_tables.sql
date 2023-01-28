\c web;
-- Filling members data
INSERT INTO members(id, email, first_name, last_name, date_of_birth, mobile_number)
    VALUES('Dixon3864b', 'William_Dixon@woodward-fuller.biz', 'William', 'Dixon', '10-01-1986', 40601711),
          ('Horn17277', 'Kristen_Horn@lin.com', 'Kristen', 'Horn', '10-09-1974', 52145751),
          ('Changd3c7b', 'Kimberly_Chang@johnson-lopez.biz', 'Kimberly', 'Chang', '12-02-1982', 99681551);

-- Filling items data
INSERT INTO items(id, item_name, manufacturer_name, cost, weight)
    VALUES(1, 'This is item number 1', 'Manufacture number 1', 45.6, 3.5),
          (2, 'This is item number 2', 'Manufacture number 1', 50.2, 2.6),
          (3, 'This is item number 3', 'Manufacture number 1', 31.2, 4.2),
          (4, 'This is item number 4', 'Manufacture number 2', 34.1, 4.0),
          (5, 'This is item number 5', 'Manufacture number 2', 60.1, 1.7);

-- Filling transactions data
INSERT INTO transactions(id, member_id, item_id, item_amount, item_price, item_total_price, item_total_weight)
    VALUES(1, 'Dixon3864b', 1, 2, 61.2, 122.24, 7.0),
          (2, 'Dixon3864b', 1, 3, 71.2, 213.6, 10.5),
          (3, 'Horn17277', 3, 1, 40.1, 40.1, 4.2);