# NOTE: run bin/format-filters after changing this file
opal_filter "File" do
  fails "File::Stat#dev_major returns nil" # Expected 0 to be nil
  fails "File::Stat#dev_minor returns nil" # Expected 0 to be nil
  fails "File::Stat#executable_real? returns true if named file is readable by the real user id of the process, otherwise false" # Expected false == true to be truthy but was false
  fails "File::Stat#gid returns the group owner attribute of a File::Stat object" # Expected 0 == -1 to be truthy but was false
  fails "File::Stat#mode returns the mode of a File::Stat object" # Expected 438 == 420 to be truthy but was false
  fails "File::Stat#owned? returns true if the file is owned by the user" # Expected #<File::Stat dev=0, ino=5066549581073667, mode=81b6, nlink=1, uid=0, gid=0, rdev=0, size=0, blksize=4096, blocks=0, atime=2025-04-10 19:06:24 -0000, mtime=2025-04-10 19:06:24 -0000, ctime=2025-04-10 19:06:24 -0000, birthtime=2025-04-10 18:46:44 -0000.owned? to be truthy but was false
  fails "File::Stat#rdev_major returns nil" # Expected 0 to be nil
  fails "File::Stat#rdev_minor returns nil" # Expected 0 to be nil
  fails "File::Stat#uid returns the owner attribute of a File::Stat object" # Expected 0 == -1 to be truthy but was false
end
