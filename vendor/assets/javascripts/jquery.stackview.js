// Not copied from stackview directly, our own rails_stackview
// file to use sprockets to include JS src copied from stackview
//
// The list of assets is explicit below to preserve any neccesary ordering. 
// If stackview adds more JS source files, you will have to update
// this list below, to keep it in sync with the list in stackview's
// own Makefile. 
//
//= require ./stackview/microtemplating.js
//= require ./stackview/jquery.easing.1.3.js
//= require ./stackview/jquery.stackview.base.js 
//= require ./stackview/jquery.stackview.infinite.js
//= require ./stackview/jquery.stackview.navigation.js
//= require ./stackview/jquery.stackview.ministack.js
//= require ./stackview/jquery.stackview.stackcache.js
//= require ./stackview/jquery.stackview.templates.js
//= require ./stackview/types/book.js
//= require ./stackview/types/serial.js
//= require ./stackview/types/soundrecording.js
//= require ./stackview/types/videofilm.js
//= require ./stackview/types/webpage.js