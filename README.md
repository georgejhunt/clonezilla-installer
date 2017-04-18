## Use Clonezilla as base for USB installer

ref: https://github.com/stevenshiau/clonezilla

#### Features:
* Relatively automated installation of XSCE configured server on UEFI or legacy mbr 64bit servers
* Headless install via ssh (must determine ip address from router)
* Optional interactive generation of new cloned images for replication onto other machines

#### Background:

  1. Compared with MS Windows, Linux is forgiving about the hardware it runs upon. The kernel adjusts to changed hardware easily.
  1. Linux uses partitions to hold file systems. The partitioning scheme used in IIAB is described at https://github.com/XSCE/xsce/wiki/IIAB-Platforms#disk-partitioning. 
  1. To move a configured server (maybe with data), everything needs to fit on the target machine, in terms of hard disk space.
  1. Clonezilla does not know how to fit a larger image onto a smaller disk, even if the used data portions of the source would fit on the target machine.
  1. To successfully move a functioning Operating System to another machine, it it best to shrink the source image so that it is smaller than the target disk. This removes the unused space from the file system, and shrinks the last partition. Then clonezilla moves it to the new target, where the last partition is automatically expanded to use the available space.
  1. Shrinking a file system, changing the partition size, or creating an image, is best done when the source OS is treated as data (not trying to copy itself).
  1. Clonezilla is a small OS on a USB stick, which can treat the hard disk OS as data.
  1. Each server has an identity which must be unique so that ssh, and other network programs, can work properly.
  1. Part of the disk imaging process involves removal of network identity (software keys) so that it can be regenerated when the image starts running on a new hardware base.
  
  #### Software tools:
