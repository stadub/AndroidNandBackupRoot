import subprocess

#from subprocess import check_call

$path = adb shell  "cat /etc/init.d/*user* | awk '/run-parts/{print $4}'"



$path = adb shell  "cat /etc/init.d/*user* | awk '/run-parts/{print $4}'"
$path -';'

adb push mount.sh $path\mount
adb shell "chmod 777 $path\mount"

adb shell "ls -l $path\mount | awk '{print $1}'""
Response: -rwxrwxrwx

adb push init_flag.sh $path\init_flag
adb shell "chmod 777 $path\init_flag
adb shell "ls -l $path\init_flag | awk '{print $1}'""
Response: -rwxrwxrwx
