set mode quit timeout
set $dir=/home/matt/EXT4_FS
set $nfiles=1
set $nthreads=32
#Fixing combined I/O amount to be some 1 G (HDD)
set $memsize=4k
set $iterations=8192

define file name=bigfileset, path=$dir, size=60g, prealloc

define process name=fileopen, instances=1
{
        thread name=fileopener, memsize=$memsize, instances=$nthreads
        {
                flowop openfile name=open1, filesetname=bigfileset, fd=1
                flowop read name=read-file, filesetname=bigfileset, random, iosize=$memsize, iters=$iterations, fd=1
                flowop closefile name=close1, fd=1
                flowop finishoncount name=finish, value=1
        }
}
create files
#mounting and unmounting for better stable results
system "sync"
system "umount /home/matt/EXT4_FS/"
#change accordingly for HDD(sdc) and SSD(sdd)
system "mount -t ext4 /dev/sdc /home/matt/EXT4_FS"

#warm up the cache (RAM)
system "sync"
system "echo 3 > /proc/sys/vm/drop_caches"
system "dd if=/home/matt/EXT4_FS/bigfileset/00000001/00000001 of=/dev/null bs=4096 count=1048576 &> /dev/null"

system "echo started >> cpustats.txt"
system "echo started >> diskstats.txt"
psrun -10
