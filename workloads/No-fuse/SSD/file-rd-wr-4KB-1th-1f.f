set mode quit timeout
set $dir=/home/stolet/EXT4_FS
set $nfiles=1
set $meandirwidth=1
set $nthreads=1
#I/O amount equal to 60 G(SSD)
set $memsize=4k
set $iterations=15728640

define file name=bigfileset, path=$dir, size=60g, prealloc

define process name=fileopen, instances=1
{
        thread name=fileopener, memsize=$memsize, instances=$nthreads
        {
                flowop openfile name=open1, filesetname=bigfileset, fd=1
                flowop write name=write-file, filesetname=bigfileset, random, iosize=$memsize, iters=$iterations, fd=1
                flowop closefile name=close1, fd=1
                flowop finishoncount name=finish, value=1
        }
}
create files
#mount and unmount for stable results
system "sync"
system "umount /home/stolet/EXT4_FS"
#Change accordingly for HDD(sdb) and SSD(sdc1)
system "mount -t ext4 /dev/sdc1 /home/stolet/EXT4_FS"
system "sync"
system "echo 3 > /proc/sys/vm/drop_caches"
system "echo started >> cpustats.txt"
system "echo started >> diskstats.txt"
psrun -10