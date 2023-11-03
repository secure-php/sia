#! /bin/bash
echo "DROP DATABASE IF EXISTS testdb;" | sudo mysql
echo "CREATE DATABASE testdb;" | sudo mysql
echo "CREATE USER 'username'@'localhost' identified by 'password';"| sudo mysql
echo "GRANT ALL PRIVILEGES on testdb.* to 'username'@'localhost';FLUSH PRIVILEGES;"| sudo mysql
echo "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '';"| sudo mysql
#
#
echo 'CREATE TABLE `user` (`id` int(11) NOT NULL AUTO_INCREMENT,`username` varchar(255) NOT NULL, PRIMARY KEY (id)) ENGINE=InnoDB DEFAULT CHARSET=latin1;' | sudo mysql testdb
echo 'INSERT INTO `user` (`username`) VALUES ("trickE");' |sudo mysql testdb
echo 'INSERT INTO `user` (`username`) VALUES ("tester");' |sudo mysql testdb
