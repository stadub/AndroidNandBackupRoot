###shell
meName=`basename "$0"`
verbose="false"
use_data_format="false"
command="show_usage"
echo_out="stdout"
port=5556



GetOpt(){
	args="$@"
	index=0
	
	for arg in $args
do
	index=$(($index + 1 ))
		
	paramName="${arg%%=*}"
	paramVal="${arg#*=}"

	case "$paramName" in
		"-l"|"--list") 
			command="list_partitons";;	
			
		"-gs"|"--get-system-partiton")
			command="get_system_partiton";;	
			
		"-v"|"--verbose")
			verbose="true";;
			
		"-d"|"--use_data_format")
			use_data_format="true";;	
			
		"-o"|"--output")
			echo_out="$paramVal";;

		"-p"|"--port")
			port="$paramVal";;

		"--force")
			ForceUpdate=1;;
		*)
			case $index in
				1) File="${arg}";;
				2) PC="${arg}";;
				3) IP="${arg}";;
				*) Usage; exit 1;;
			esac
			;;
    esac
done
}

function set_output(){
	case "$echo_out" in
		"stdout")			
			echo "Output will be sent to the stdout";;
		"host")
			echo "Output will be sent to host(incomming connection):$port";;
			
    esac
}

function list_partitons{
  WriteVerbose "List partitons"
  partitions=`ls -l /dev/block/platform/*1/*name/ | sed  's/.* \(.*\) -> \(.*\)/\1{>_>}\2/'`
  WriteData Partitions "$partitions"
}

function get_system_partiton{
  if [ x"$partitions" -eq x"" ];  then
    list_partitons();
  fi

  WriteVerbose "Find system partition"
  system=`echo "$partitions" | sed -n 's/system{>_>}\(.*\)/\1/p'`
  WriteData System "$system"
}


function attach_busybox{
  if [ x"$system" -eq x"" ];  then
    get_system_partiton();
  fi

  WriteVerbose "Attach busybox"
  mkdir sys_dir
  mount -o rw -t ext4 $system /sys_dir
  cp /sys_dir/xbin/busybox /system
  umount /sys_dir
}

function list_mount{
  #List mounted fs
  mounts=`mount | awk '/^\/dev\/block/{print $3}'`
  WriteVerbose "Phone mounted files systems: \n $mounts"
}

function unmount_system{
  if [ x"$mounts" -eq x"" ]; then
    list_mount();
  fi

  #umount all /dev/block/ partitions
  WriteVerbose "Unmount file systems"
  for mount_point in $mounts
  do
  	WriteVerbose "Unmount $mount_point"
  	umount $mount_point;
  done
}

function get_part_info{
  if [ x"$partitions" -eq x"" ]; then
    list_partitons();
  fi

  #get partitions size via /system/busybox fdisk -l /dev/block/mmcblk0p{0}
  for partition in `echo "$partitions" | sed -n 's/.*{>_>}//p'`
  do
  	partInfo=`fdisk -l  $partition | sed -n "s/Disk \(.*\): \(.*\), \(.*\)/\1{>_>}\2{>_>}\3/p"`
  	WriteVerbose "Partition info: $partInfo"
  	WriteData partInfo "$partInfo"
  done
}

function send_host{
  #send selected partitons
  /system/busybox nc -l -p 5555 -e /system/busybox dd if=$1
}

function send_host_all{
  echo "$partitions" | sed -n 's/' | sed '$!N; /^\(.*\)\n\1$/!P; D'
}

function send_host_all{
  /system/busybox nc -l -p 5555 -e /system/busybox dd if=/dev/block/mmcblk0

  /system/busybox nc -l -p 5555 -e /system/busybox dd if=/dev/block/mmcblk1
}

function WriteVerbose {
	if [x"$verbose" -eq x"true"]; then
		write-host ----====$@====----
	fi
}

function WriteData{
	if [x"$use_data_format" -eq x"true"]; then
		write-host "_________________"
		write-host "$1:"
		write-host "$@"
		write-host "_________________"
	else
		write-host "$@" | sed 's/{>_>}/ /'
	fi
}


function write-host(){
	case "$echo_out" in
		"stdout")			
			echo "$@";;
		"host")
			/system/busybox nc -l -p $port -e echo "$@"
    esac
} 

GetOpt "$@"

set_output()


`$command`;
return;