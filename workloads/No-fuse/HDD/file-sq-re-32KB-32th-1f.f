set mode quit timeout
set $dir=/home/matt/EXT4_FS
set $nfiles=1
set $meandirwidth=1
set $nthreads=32

define fileset name=bigfileset, path=$dir, entries=$nfiles, dirwidth=$meandirwidth, size=60g, prealloc

define process name=fileopen, instances=1
{
        thread name=fileopener, memsize=32k, instances=$nthreads
        {
                flowop openfile name=open1, filesetname=bigfileset, fd=1
                flowop read name=read-file, filesetname=bigfileset, iosize=32k, iters=1966080, fd=1
                flowop closefile name=close1, fd=1
                flowop finishoncount name=finish, value=1
        }
}
create files
#unmount and mount for better stability results
system "sync"
system "umount /home/matt/EXT4_FS"
#Change accordingly for HDD(sdc) and SSD(sdd)
system "mount -t ext4 /dev/sdc /home/matt/EXT4_FS"
system "sync"
system "echo 3 > /proc/sys/vm/drop_caches"
system "echo started >> cpustats.txt"
system "echo started >> diskstats.txt"
psrun -10
