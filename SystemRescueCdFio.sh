#!/bin/bash
#SystemRescueCdFio.sh
fio_ver=3.29
tmp_dir=/tmp/fio
cpu_num=`grep -c ^processor /proc/cpuinfo`
if ! command -v fio &> /dev/null
then
    echo "nameserver 1.1.1.1" > /etc/resolv.conf
    rdate -s rdate.cpanel.net
    rm -rf $tmp_dir
    mkdir -p $tmp_dir
    cd /tmp/fio
    wget https://brick.kernel.dk/snaps/fio-${fio_ver}.tar.gz --no-check-certificate
    tar zxvf fio-${fio_ver}.tar.gz
    cd fio-${fio_ver}
    ./configure
    make -j${cpu_num}
    make install
    rm -rf $tmp_dir
fi



for disk in $(ls /dev/sd*[a-z]);
  do
    echo "=== ${disk} START ===";
    smartctl -i ${disk} | grep 'Device Model\|Serial Number:\|User Capacity:\|Rotation Rate:\|Form Factor:\|SATA Version is:'
    fio --filename=${disk} --direct=1 --rw=read --bs=64k --ioengine=libaio --iodepth=64 --runtime=300 --numjobs=4 --time_based --group_reporting --name=throughput-test-job --eta-newline=1 --readonly --output-format=json | python3 -c "import sys, json; speed=json.load(sys.stdin)['jobs'][0]['read']['bw_bytes']; speed=speed/1024/1024; print('Test Result: %s MB/s' % int(speed))"
    echo "=== ${disk} END ===";
    echo "";
done; 

   

