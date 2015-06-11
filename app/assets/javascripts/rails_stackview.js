// rails_stackview sprockets JS manifest that includes vendored stackview JS as well as custom JS
//
//= require jquery.stackview.js
//= require ./rails_stackview/plain.js
//
// Important to load browser, which adjusts the size of the stackview div,
// BEFORE auto-init, to make sure the div is the right size when stackview
// gets init'd, since it will base some things on the size of the div. 
//= require ./rails_stackview/browser.js
//
//= require ./rails_stackview/auto_init.js
