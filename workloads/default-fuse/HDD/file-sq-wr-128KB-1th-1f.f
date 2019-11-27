set mode quit timeout
set $dir=$HOME/COM_DIR/FUSE_EXT4_FS/
set $nthreads=1
#Fix I/O amount to 60 G
define file name=bigfile, path=$dir, size=60g
define process name=fileopen, instances=1
{
        thread name=fileopener, memsize=128k, instances=$nthreads
        {
                flowop createfile name=create1, filesetname=bigfile
                flowop write name=write-file, filesetname=bigfile, iosize=128k,iters=491520
                flowop closefile name=close1
                flowop finishoncount name=finish, value=1
        }
}
#prealloc the file on EXT4 F/S (save the time)
system "mkdir -p $HOME/COM_DIR/FUSE_EXT4_FS"
system "mkdir -p $HOME/COM_DIR/EXT4_FS"

create files

#Move everything created under FUSE-EXT4 dir to EXT4 (Though nothing in this case)
system "mv $HOME/COM_DIR/FUSE_EXT4_FS/* $HOME/COM_DIR/EXT4_FS/"

system "sync"
system "echo 3 > /proc/sys/vm/drop_caches"

#mount FUSE FS (default) on top of EXT4
system "$HOME/fuse-3.7.0/example/stackfs_ll -s --statsdir=/tmp/ -r $HOME/COM_DIR/EXT4_FS/ $HOME/COM_DIR/FUSE_EXT4_FS/ > /dev/null &"

system "echo started >> cpustats.txt"
system "echo started >> diskstats.txt"
psrun -10
