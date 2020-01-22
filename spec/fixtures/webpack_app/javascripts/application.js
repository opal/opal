// import and load opal ruby files
import init_app from 'opal_loader.rb';
init_app();
Opal.load('opal_loader');

// allow for hot reloading
if (module.hot) { module.hot.accept(); }
