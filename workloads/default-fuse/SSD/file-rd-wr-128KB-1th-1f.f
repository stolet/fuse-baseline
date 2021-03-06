set mode quit timeout
set $dir=/home/matt/COM_DIR/FUSE_EXT4_FS/
set $nfiles=1
set $meandirwidth=1
set $nthreads=1
#I/O amount equal to 60 G
set $memsize=128k
set $iterations=491520

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

#prealloc the file on EXT4 F/S (save the time)
system "mkdir -p /home/matt/COM_DIR/FUSE_EXT4_FS"
system "mkdir -p /home/matt/COM_DIR/EXT4_FS"

create files

#Move everything created under FUSE-EXT4 dir to EXT4
system "mv /home/matt/COM_DIR/FUSE_EXT4_FS/* /home/matt/COM_DIR/EXT4_FS/"

#mounting and unmounting for better stable results
system "sync"
system "umount /home/matt/COM_DIR/"
#Change accordingly for HDD(sdc) and SSD(sdb)
system "mount -t ext4 /dev/sdb /home/matt/COM_DIR/"

#mount FUSE FS (default) on top of EXT4
system "/home/matt/fuse-3.7.0/example/stackfs_ll -s --statsdir=/tmp/ -r /home/matt/COM_DIR/EXT4_FS/ /home/matt/COM_DIR/FUSE_EXT4_FS/ > /dev/null &"

system "sync"
system "echo 3 > /proc/sys/vm/drop_caches"

system "echo started >> cpustats.txt"
system "echo started >> diskstats.txt"
psrun -10
