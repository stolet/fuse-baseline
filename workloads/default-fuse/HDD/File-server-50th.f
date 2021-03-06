set mode quit timeout
set $dir=/home/matt/COM_DIR/FUSE_EXT4_FS/
set $nfiles=200000
set $meandirwidth=20
set $nthreads=50
set $size1=128k

define fileset name=bigfileset, path=$dir, size=$size1, entries=$nfiles, dirwidth=$meandirwidth, prealloc=80

define process name=fileserver,instances=1
{
        thread name=fileserverthread, memsize=10m, instances=$nthreads
        {
                flowop createfile name=createfile1,filesetname=bigfileset,fd=1
                flowop writewholefile name=wrtfile1,srcfd=1,fd=1,iosize=1m
                flowop closefile name=closefile1,fd=1
                flowop openfile name=openfile1,filesetname=bigfileset,fd=1
                flowop appendfilerand name=appendfilerand1,iosize=16k,fd=1
                flowop closefile name=closefile2,fd=1
                flowop openfile name=openfile2,filesetname=bigfileset,fd=1
                flowop readwholefile name=readfile1,fd=1,iosize=1m
                flowop closefile name=closefile3,fd=1
                flowop deletefile name=deletefile1,filesetname=bigfileset
                flowop statfile name=statfile1,filesetname=bigfileset
                flowop finishoncount name=finish, value=1000000
                #So all the above operations will happen together for 1 M (HDD) times
        }
}

#prealloc the file on EXT4 F/S (save the time)
system "mkdir -p /home/matt/COM_DIR/FUSE_EXT4_FS/"
system "mkdir -p /home/matt/COM_DIR/EXT4_FS"

create files

#Move everything created under FUSE-EXT4 dir to EXT4
system "mv /home/matt/COM_DIR/FUSE_EXT4_FS/* /home/matt/COM_DIR/EXT4_FS/"

#mounting and unmounting for better stable results
system "sync"
system "umount /home/matt/COM_DIR/"
#change accordingly for HDD(sdc) and SSD(sdd)
system "mount -t ext4 /dev/sdc /home/matt/COM_DIR/"

#mount FUSE FS (default) on top of EXT4
system "/home/matt/fuse-3.7.0/example/stackfs_ll -s --statsdir=/tmp/ -r /home/matt/COM_DIR/EXT4_FS/ /home/matt/COM_DIR/FUSE_EXT4_FS/ > /dev/null &"

system "sync"
system "echo 3 > /proc/sys/vm/drop_caches"

system "echo started >> cpustats.txt"
system "echo started >> diskstats.txt"

psrun -10
