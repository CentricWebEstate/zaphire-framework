//require( 'coffee-script-redux/register' );
require ( 'coffee-script' );
Zaphire = require ( './Zaphire' );
Zaphire.root = process.argv[2];
App = Zaphire.getApp();
App.start();