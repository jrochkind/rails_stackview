(function($, undefined) {

  function fitToWindowHeight() {
    var shelfbrowser = $(".shelfbrowser");

    if (shelfbrowser.size() > 0) {
      var topOffset = shelfbrowser.offset().top;

      shelfbrowser.css("height", $(window).height() - topOffset);
    }
  }

  function loadItem(base_url, panel, item) {
    $.ajax({
      url: base_url,
      data: {
        'id': item.system_id,
        'sort_key': item.sort_key,
        'sort_key_display': item.sort_key_display,
        'sort_key_type': item.sort_key_type
      },
      dataType: "html",
      success: function(html, status, xhr) {
        panel.html( html );
      }
    });
  }

  $( document ).on("ready", function() {
    if ($(".shelfbrowser").length > 0) {
      fitToWindowHeight();

      $( window ).on("resize", function() {
        fitToWindowHeight();
      });
      
      // If stackview_browser_item_path is defined, click on item
      // should load partial via AJAX, and preventDefault. 
      $(document).on("click", ".shelfbrowser .stack-item a", function(event) {
        var target        = $(event.target);
        var item_load_url = target.closest(".shelfbrowser-browse-column").data('stackviewBrowserItemPath');
        var panel         = target.closest(".shelfbrowser").find(".shelfbrowser-info-column .stack-item-panel").filter(":visible");

        if(item_load_url && panel.length > 0) {
          event.preventDefault();   

          var item_attribute_hash = target.closest(".stack-item").data("stackviewItem");

          loadItem(item_load_url,  panel,  item_attribute_hash );
        }
      });
    }
  });

})(jQuery);