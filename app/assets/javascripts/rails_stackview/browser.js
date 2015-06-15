(function($, undefined) {

  function fitToWindowHeight() {
    var topOffset = $(".shelfbrowser").offset().top;

    $(".shelfbrowser").css("height", $(window).height() - topOffset);
  }

  $( document ).on("ready", function() {
    fitToWindowHeight();
  });
  $( window ).on("resize", function() {
    fitToWindowHeight();
  });

})(jQuery);