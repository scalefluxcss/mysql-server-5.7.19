#!/usr/bin/env bash
set -e
cur_dir=`pwd`
src_dir=`pwd`/..
install_dir=/usr/local/mysql
css_mnt_point=/mnt/sfx-card-root
data_dir=${css_mnt_point}/mysql_data

echo "CSS SSD will be mounted at ${css_mnt_point} and CSS-MySQL Server data directory is set to ${data_dir}."

if [ ! -b /dev/sfd0 ];then
echo "CSS block device not detected, please install RPM packages!"
exit 1
fi

sudo chmod 666 /dev/sfx0

if [ -d /usr/local/mysql ]; then
echo "MySQL server is installed at /usr/local/mysql"
else
cd $src_dir && mkdir -p build
(cd ${src_dir}/build && cmake .. -DDOWNLOAD_BOOST=1 -DWITH_BOOST=../boost -DENABLE_DOWNLOADS=1 && make && make install)
fi

if [ ! -f /etc/profile.d/mysql.sh ]; then
  echo -e "if ! echo \$PATH | grep -q /usr/local/mysql/bin; then\nPATH=/usr/local/mysql/bin:\$PATH\nfi" > /etc/profile.d/mysql.sh
  source /etc/profile.d/mysql.sh
fi

if [ ! -f /etc/init.d/rc.d/mysql ]; then
cp -v ${install_dir}/support-files/mysql.server /etc/rc.d/init.d/mysql
fi

if [ ! -f /etc/ld.so.conf.d/mysql.conf ]; then
echo "/usr/local/mysql/lib" > /etc/ld.so.conf.d/mysql.conf
fi

if ! ldconfig -p | grep -q /usr/local/mysql/lib; then
ldconfig 2>/dev/null
fi

fs_type=`blkid -o value -s TYPE /dev/sfd0 2>/dev/null` || fs_type=
if [ -z $fs_type ]; then
mkfs.ext4 /dev/sfd0
fi

if ! mountpoint -q $css_mnt_point; then
mkdir -p $css_mnt_point
mount /dev/sfd0 $css_mnt_point;
fi

cp $cur_dir/my.cnf /etc

if [ ! -z "$(ls -A $data_dir 2>/dev/null)" ]; then
rm -rf $data_dir 
fi

id -u mysql >/dev/null && rc=$? || rc=$?
if [ $rc -eq 1 ]; then
useradd mysql
fi

mysqld --initialize-insecure --user=mysql
