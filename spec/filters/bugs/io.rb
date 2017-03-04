opal_filter "IO" do
  fails "IO::EAGAINWaitReadable combines Errno::EAGAIN and IO::WaitReadable" # NameError: uninitialized constant IO::EAGAINWaitReadable
  fails "IO::EAGAINWaitReadable is the same as IO::EWOULDBLOCKWaitReadable if Errno::EAGAIN is the same as Errno::EWOULDBLOCK" # NameError: uninitialized constant Errno::EAGAIN
  fails "IO::EAGAINWaitWritable combines Errno::EAGAIN and IO::WaitWritable" # NameError: uninitialized constant IO::EAGAINWaitWritable
  fails "IO::EAGAINWaitWritable is the same as IO::EWOULDBLOCKWaitWritable if Errno::EAGAIN is the same as Errno::EWOULDBLOCK" # NameError: uninitialized constant Errno::EAGAIN
  fails "IO::EWOULDBLOCKWaitReadable combines Errno::EWOULDBLOCK and IO::WaitReadable" # NameError: uninitialized constant IO::EWOULDBLOCKWaitReadable
  fails "IO::EWOULDBLOCKWaitWritable combines Errno::EWOULDBLOCK and IO::WaitWritable" # NameError: uninitialized constant IO::EWOULDBLOCKWaitWritable
end
