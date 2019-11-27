set mode quit timeout
set $dir=$HOME/COM_DIR/FUSE_EXT4_FS/

#Fixing I/O Amount to 2M files
set $nfiles=2000000
set $meandirwidth=1000
set $nthreads=1

define fileset name=bigfileset, path=$dir, entries=$nfiles, dirwidth=$meandirwidth, dirgamma=0, size=4k, prealloc

define process name=fileopen, instances=1
{
        thread name=fileopener, memsize=4k, instances=$nthreads
        {
                flowop deletefile name=delete-file, filesetname=bigfileset
        }
}
#prealloc the file on EXT4 F/S (save the time)
system "mkdir -p $HOME/COM_DIR/FUSE_EXT4_FS"
system "mkdir -p $HOME/COM_DIR/EXT4_FS"

create files

#Move everything created under FUSE-EXT4 dir to EXT4
system "mv $HOME/COM_DIR/FUSE_EXT4_FS/* $HOME/COM_DIR/EXT4_FS/"

#mounting and unmounting for better stable results
system "sync"
system "umount $HOME/COM_DIR/"
#change accordingly for HDD(sdc) and SSD(sdd)
system "mount -t ext4 /dev/sdc $HOME/COM_DIR/"

#mount FUSE FS (default) on top of EXT4
system "$HOME/fuse-3.7.0/example/stackfs_ll -s --statsdir=/tmp/ -r $HOME/COM_DIR/EXT4_FS/ $HOME/COM_DIR/FUSE_EXT4_FS/ > /dev/null &"

system "sync"
system "echo 3 > /proc/sys/vm/drop_caches"
system "echo started >> cpustats.txt"
system "echo started >> diskstats.txt"
psrun -10
