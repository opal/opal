Bundle class
------------

 The `Bundle` class and its associated `BundleTask` class are the
easiest way to build ruby source files ready to use in the browser. It
basically looks in the current directories `lib/` folder for all ruby
source files, then compiles them all and bundles them together into a
single javascript output file.

Setting up
==========

To get bundling working, you need a Rakefile with a `bundle` task. This
can be manually setup, but the easiest way is to use the `init` command
from opal. To create a test project, run:

```
$ opal init test_project
```

and replace "test_project" with the name of your application. This will
place all generated files into a directory of the same name. If you
ommit the project name then the files will be placed in the current
working directory.

You should end up with the given project structure:

```
test_project/
 |-js/
    |-opal.js
    |-opal-parser.js
 |-lib/
    |-test_project.rb
 |-index.html
 |-Rakefile
```

### js folder

This folder contains the prebuilt versions of the opal runtime and the
opal parser.

### lib folder

This is where all your ruby code goes. It already has a template ruby
file which just prints a message.

### index.html

Simple html document which will load the opal runtime and your built
project file.

### Rakefile

Simple rakefile that has the task to build the bundle. It can be
customized (see below).

Building the project
====================

Although the application doesn't do much, it is ready to be built and
run. To do this, run:

```
$ rake bundle
```

This will generate a file called `test\_project-0.0.1.js` in the current
directory. The name will vary if you change the values in the Rakefile.

Once built, open index.html in any browser and observe its debug log.
You should see the message printed there. Everytime you edit the ruby
sources you will need to re-run this rake task to rebuild the bundle.

If you observe the built file, you can see that `Bundle` just compiles
the ruby sources, it does not require them automatically. There is a
small snippet inside the html document that does this:

```html
<script type="javascript">
  opal.require("test_project");
</script>
```

