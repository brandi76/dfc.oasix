#!/usr/bin/perl
use CGI;
$date=`/bin/date +%y%m%d'_'%T`;
print $date;
system ("/usr/bin/mysqldump -u root FLY >/home/backup/fly/fly.$date");
system ("/bin/gzip /home/backup/fly/fly.$date");