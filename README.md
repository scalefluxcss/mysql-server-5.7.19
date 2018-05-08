# CSS MySQL Server

CSS MySQL Server has enabled CSSZLIB as the third compression option in Transparent Page Compression. 
## Install Server
### Prerequisites
Prerequisites must be installed before installing MySQL server. Otherwise, Transparent Page Compression might not work.

* Install the following packages before installing MySQL server.
- cmake
- libaio-devel
- ncurse-devel
- perl
```bash
# Ubuntu
sudo apt-get install software-properties-common
sudo add-apt-repository ppa:george-edison55/cmake-3.x
sudo apt-get update
sudo apt-get install -y cmake libaio-dev libncurses5-dev libncursesw5-dev perl

# CentOS
sudo yum install -y libaio-devel ncurses-devel cmake perl
```

* Install ScaleFlux driver and block device

### Install
#### Install via script
```bash
$ cd install-scripts
$ ./install-server.sh
```
#### Install step by step
* Make sure CSS device can be accessed
```bash
$ sudo chmod 666 /dev/sfx0
```
* Compile CSS MySQL
```bash
$ mkdir -p build
$ cd build && cmake .. -DDOWNLOAD_BOOST=1 -DWITH_BOOST=../boost -DENABLE_DOWNLOADS=1
$ make
$ sudo make install
```
* Add CSS MySQL utilities to PATH  
Create a shell script mysql.sh and copy to /etc/profile.d so it will be loaded automatically
```bash
if ! echo $PATH | grep -q /usr/local/mysql/bin; then
PATH=/usr/local/mysql/bin:$PATH
fi
```
* Source the script for current terminal
```
$ sudo source /etc/profile.d/mysql.sh
```
* Start Mysql Server as a service
```bash
$ sudo cp -v /usr/local/mysql/support-files/mysql.server /etc/rc.d/init.d/mysql
```
* Add MySQL Server libraries to the shared library cache
```bash
$ sudo echo "/usr/local/mysql/lib" > /etc/ld.so.conf.d/mysql.conf
```
* Update shared library cache
```bash
$ sudo ldconfig
```
* Set data directory to CSS device
Make filesystem and mount CSS device
```bash
$ sudo mkfs.ext4 /dev/sfd0
$ sudo mount /dev/sfd0 path_to_mount_point
```
Copy install-scripts/my.cnf to /etc or customize /etc/my.cnf for your own needs.
```bash
$ sudo cp my.cnf /etc
```
* Add user mysql
```bash
$ id -u mysql
$ if [ $? -eq 1 ];then 
$ sudo useradd mysql;
$ fi
```
* Initialize MySQL Server data directory
```bash
$ sudo mysqld --initialize-insecure --user=mysql
```

## Start Server
* Start MySQL Server as a service
```bash
$ sudo service mysql start
```
* Set password for root user in MySQL. 
```bash
$ mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'Your_Password';"
$ mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '';" # Set empty root password
```

# Install Client
Skip this step if MySQL Client runs on the same machine with MySQL Server.
### Prerequisites
- cmake
- ncurse-devel
- perl

### Install
#### Install via script
```bash
$ cd install-scripts
$ ./install-client.sh
```
#### Install step by step
* Compile CSS MySQL
```bash
$ mkdir -p build
$ cd build && cmake .. -DDOWNLOAD_BOOST=1 -DWITH_BOOST=../boost -DENABLE_DOWNLOADS=1
$ make
$ sudo make install
```
* Add CSS MySQL utilities to PATH  
Create a shell script mysql.sh and copy to /etc/profile.d so it will be loaded automatically
```bash
if ! echo $PATH | grep -q /usr/local/mysql/bin; then
PATH=/usr/local/mysql/bin:$PATH
fi
```
* Source the script for current terminal
```
$ sudo source /etc/profile.d/mysql.sh
```
* Add MySQL Server libraries to the shared library cache
```bash
$ sudo echo "/usr/local/mysql/lib" > /etc/ld.so.conf.d/mysql.conf
```
* Update shared library cache
```bash
$ sudo ldconfig
```

## Post install configuration
* If MySQL Client and Server are in the same machine, please ignore this part.
* If MySQL Client connects to Server remotely, the following configurations are needed on MySQL Server
Open TCP port 3306 using iptables
```bash
$ yum install iptables-services
$ /sbin/iptables -A INPUT -i <connection_name> -p tcp --destination-port 3306 -j ACCEPT # connection_name can be found via ifconfig
$ service iptables save
$ systemctl enable iptables
$ systemctl restart iptables
```
Allow remote connections in MySQL Server
```bash
mysql> GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '';
mysql> FLUSH PRIVILEGES;
```

## Run Sysbench test
* Grant user sbtest for remote connection in MySQL Server
```bash
mysql> GRANT ALL PRIVILEGES ON *.* TO 'sbtest'@'%' IDENTIFIED BY 'sbtest';
mysql> FLUSH PRIVILEGES;
```
* Run Sysbench tests from MySQL Client to see CSSZLIB advantage in MySQL Transparent Page Compression
To see usage information of the test script.
```bash
$ cd install
$ ./run_test.sh --help
```
Example:
```bash
$ ./run_test.sh
Hostname: localhost
Port: 3306
Number of tables: 4
Each table size: 1024 MB
Number of threads: 16
Time: 60 seconds

CSSZLIB:
Write-Only Test:
Transactions: 12940.55 per sec
Database Size:   5172.07 MB
Read-Only Test:
Transactions: 4838.89 per sec
Database Size:   3536.45 MB
Read-Write Test:
Transactions: 2542.73 per sec
Database Size:   2786.27 MB
No Compression:
Write-Only Test:
Transactions: 8191.94 per sec
Database Size:   5248.02 MB
Read-Only Test:
Transactions: 4914.20 per sec
Database Size:   4960.02 MB
Read-Write Test:
Transactions: 2688.04 per sec
Database Size:   5152.02 MB
ZLIB:
Write-Only Test:
Transactions: 4777.75 per sec
Database Size:   3825.33 MB
Read-Only Test:
Transactions: 4673.84 per sec
Database Size:   3789.01 MB
Read-Write Test:
Transactions: 2302.96 per sec
Database Size:   3736.77 MB
```
