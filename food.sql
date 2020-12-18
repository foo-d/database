DROP DATABASE IF EXISTS food;
CREATE DATABASE IF NOT EXISTS food;
USE food;
CREATE TABLE employee
(
    id INT NOT NULL AUTO_INCREMENT
    ,last_name VARCHAR(100) NOT NULL
    ,first_name VARCHAR(100) NOT NULL
    ,email VARCHAR(255) NOT NULL
    ,date_of_birth DATE NOT NULL
    ,country VARCHAR(255) NOT NULL
    ,city VARCHAR(255) NOT NULL
    ,zip_code VARCHAR(5) NOT NULL
    ,date_of_hire DATE NOT NULL
    ,password VARCHAR(255) NOT NULL
    ,remaining FLOAT NOT NULL
    ,used FLOAT NOT NULL
    ,PRIMARY KEY (id)
);
CREATE TABLE leaves
(
    id INT NOT NULL AUTO_INCREMENT
    ,start DATETIME NOT NULL
    ,end DATETIME NOT NULL
    ,full_day VARCHAR(9) NOT NULL
    ,reason VARCHAR(255)
    ,id_employee INT NOT NULL
    ,PRIMARY KEY (id)
    ,FOREIGN KEY (id_employee) REFERENCES employee (id)
);
/* FUNCTION */
DROP FUNCTION IF EXISTS login;
DELIMITER //
CREATE FUNCTION login (email0 VARCHAR(255), password0 VARCHAR(255))
    RETURNS INT
BEGIN
    DECLARE temp INT;
    SELECT id INTO temp FROM employee WHERE email = email0 AND password = password0;
    RETURN (temp);
END
//
DELIMITER ;
/* PROCEDURE */
DROP PROCEDURE IF EXISTS refresh;
DELIMITER //
CREATE PROCEDURE refresh (IN id0 INT)
BEGIN
    UPDATE employee
    SET remaining = DATEDIFF(CURDATE(), date_of_hire) * 2.5 / 28 - used
    WHERE id = id0;
END
//
DELIMITER ;
/* TRIGGER */
DROP TRIGGER IF EXISTS add_leave;
DROP TRIGGER IF EXISTS remove_leave;
DELIMITER //
CREATE TRIGGER add_leave
AFTER INSERT ON leaves
FOR EACH ROW
BEGIN
    UPDATE employee
    SET used = used + TIMEDIFF(new.end, new.start) / 240000
    WHERE id = new.id_employee;
    CALL refresh(new.id_employee);
END;
CREATE TRIGGER remove_leave
AFTER DELETE ON leaves
FOR EACH ROW
BEGIN
    UPDATE employee
    SET used = used - TIMEDIFF(old.end, old.start) / 240000
    WHERE id = old.id_employee;
    CALL refresh(old.id_employee);
END
//
DELIMITER ;
INSERT INTO employee VALUES (NULL, "Sanquirgo", "Tanguy", "tanguy.sanquirgo@foo-d.fr", "1998-12-15", "France", "Boulogne-Billancourt", "92100", "2020-10-07", "temp", (DATEDIFF(CURDATE(), "2020-10-07") * 2.5) / 28, 0);
INSERT INTO leaves VALUES (NULL, "2020-12-15 12:00:00", "2020-12-16 00:00:00", "Afternoon", "Birthday party", 1);
INSERT INTO leaves VALUES (NULL, "2020-12-24 00:00:00", "2020-12-26 00:00:00", "Yes", "Christmas holidays", 1);
SELECT * FROM employee;
SELECT * FROM leaves;
SELECT login("tanguy.sanquirgo@foo-d.fr", "temp");
