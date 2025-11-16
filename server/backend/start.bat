
CREATE USER 'app'@'10.0.1.%' IDENTIFIED BY 'yy1234yy';
SELECT user, host FROM mysql.user WHERE user = 'app' AND host = 'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP ON homeinventory.* TO 'app'@'10.0.1.%';
GRANT ALL ON homeinventory.* TO 'app'@'localhost';
FLUSH PRIVILEGES;


uvicorn app.main:app --reload --host 10.0.1.6