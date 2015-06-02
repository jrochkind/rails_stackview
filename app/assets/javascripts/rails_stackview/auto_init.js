// On page load, look for any elements with a data-stackview-init attribute. 
// That data attribute is expected to include a JSON serialized hash that
// is an init argument to the stackView() initializer. 

// We will initialize element with that argument. 
(function( $ ) {
  // page:load for turbolinks too, not sure if it really works right.     
  $(document).on('ready page:load', function () {
    $("[data-stackview-init]").each(function(i, element) {
      element = $(element);
      element.stackView(element.data("stackviewInit"));
    });   
  });

})( jQuery );
