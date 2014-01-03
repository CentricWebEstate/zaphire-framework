require( 'coffee-script-redux/register' );

Zaphire = require ( './Zaphire' );
Zaphire.root = process.argv[2];
App = Zaphire.getApp();
App.start();