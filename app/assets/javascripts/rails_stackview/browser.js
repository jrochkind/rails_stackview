(function($, undefined) {

  function fitToWindowHeight() {
    $(".shelfbrowser").css("height", $(window).height());
  }

  $( document ).on("ready", function() {
    fitToWindowHeight();
  });
  $( window ).on("resize", function() {
    fitToWindowHeight();
  });

})(jQuery);