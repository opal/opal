# Hello World Example App

This is a very basic example Opal App. To get this running, firstly
install the dependencies (which is just opal):

```
bundle install
```

Next we need the opal runtime. You can either download it from
[http://opalrb.org/opal.js](http://opalrb.org/opal.js), or use
the handy rake task:

```
rake runtime
```

This builds `opal.js`.

Finally, to build the `app.rb` file, run the simple rake task:

```
rake build
```

Which builds the app into `app.js`. Open `index.html` and observe the
alert dialog.