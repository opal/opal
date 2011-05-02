# We need to require rquery lib
require 'rquery'

# Run code only when the document becomes ready
$document.ready? do
  # $document is ready so do stuff
end

# Including RQuery brings the core classes/modules top level
include RQuery

# Document module now an alternative to $document
Document.ready? do
  # Document ready
end

# Show an alert when clicking a link
$document.ready? do
  $document['a'].click { alert "Hello world!" }
end

# Adding some css classes
$document.ready? do
  $document['#orderedlist'].add_class('red').find('li').add_class 'blue'
end

# Loop over each element individually
$document.ready? do
  $document['li'].each { |elem| puts elem.html }
end

$document.ready? do
  $document.click do
    puts "clicked doc!"
  end
end

