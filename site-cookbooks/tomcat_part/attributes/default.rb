default['java']['jdk_version'] = 7

default['tomcat_part']['datasource'] = 'jdbc/postgresql'
default['tomcat_part']['database']['type'] = 'postgresql'
default['tomcat_part']['database']['name'] = 'application'
default['tomcat_part']['database']['user'] = 'application'
default['tomcat_part']['database']['password'] = 'todo_replace_random_password'
default['tomcat_part']['database']['host'] = 'localhost'
default['tomcat_part']['database']['port'] = 5432
default['tomcat_part']['jdbc']['postgresql'] = 'http://jdbc.postgresql.org/download/postgresql-9.3-1102.jdbc41.jar'
default['tomcat_part']['jdbc']['mysql'] = 'http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.33.tar.gz'
default['tomcat_part']['jdbc']['oracle'] = 'http://download.oracle.com/otn/utilities_drivers/jdbc/121020/ojdbc7.jar'
