set mode quit timeout
set $dir=/home/matt/COM_DIR/FUSE_EXT4_FS/
set $nthreads=1
#Fix I/O amount to 60 G
define file name=bigfile, path=$dir, size=60g
define process name=fileopen, instances=1
{
        thread name=fileopener, memsize=1024k, instances=$nthreads
        {
                flowop createfile name=create1, filesetname=bigfile
                flowop write name=write-file, filesetname=bigfile, iosize=1024k,iters=61440
                flowop closefile name=close1
                flowop finishoncount name=finish, value=1
        }
}
#prealloc the file on EXT4 F/S (save the time)
system "mkdir -p /home/matt/COM_DIR/FUSE_EXT4_FS"
system "mkdir -p /home/matt/COM_DIR/EXT4_FS"

create files

#Move everything created under FUSE-EXT4 dir to EXT4 (Though nothing in this case)
system "mv /home/matt/COM_DIR/FUSE_EXT4_FS/* /home/matt/COM_DIR/EXT4_FS/"

system "sync"
system "echo 3 > /proc/sys/vm/drop_caches"

#mount max_write+wbc+splice FUSE FS (default) on top of EXT4
system "/home/matt/fuse-3.7.0/example/stackfs_ll --statsdir=/tmp/ -o max_write=131072 -o writeback_cache -o splice_read -o splice_write -o splice_move -r /home/matt/COM_DIR/EXT4_FS/ /home/matt/COM_DIR/FUSE_EXT4_FS/ > /dev/null &"

system "echo started >> cpustats.txt"
system "echo started >> diskstats.txt"
psrun -10
