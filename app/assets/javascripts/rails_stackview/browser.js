(function($, undefined) {

  function fitToWindowHeight() {
    var shelfbrowser = $(".shelfbrowser");

    if (shelfbrowser.size() > 0) {
      var topOffset = shelfbrowser.offset().top;
      var height    = $(window).innerHeight() - topOffset;

      shelfbrowser.css("height",  height);
      // set a bunch of elements to have same height, CSS tricks
      // to make it expand to fit weren't working esp in IE. 
      $(".shelfbrowser-stackview").css("height", height);
      $(".shelfbrowser-browser-column").css("height", height);
      $(".shelfbrowser-info-column").css("height", height);
    }
  }

  window.doit = true;

  function loadItem(base_url, panel, item) {
    // Fade out the existing content with a pretty cheesy effect,
    // ends up less confusing when load is slowish. Cheesy implementation.
    panel.wrapInner("<div class='rails-stackview-panel-wrap'></div>");
    panel.find(".rails-stackview-panel-wrap").delay(400).fadeTo(600, 0.2);



    if (window.doit) {
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
        panel.trigger("stackview-item-load");
      },
      error: function(xhr, status, error) {
        panel.html(errorPanel(error));
      },
      complete: function(xhr, status) {
        // Some kind of bug in chrome/webkit is sometimes making
        // parts of the info column be not properly painted, especially
        // on retina screens.  Think we trigger it by changing DOM inside an
        // overflow:auto section.
        // This seems to work around it hackily:
        $(".shelfbrowser-info-column").fadeTo(1, .99).fadeTo(1, 1);

        // If the info column was previously scrolled, we want
        // to go to top for this new content. 
        $(".shelfbrowser-info-column").scrollTop(0);
      }
    });
    }
  }

  function errorPanel(text) {
    return '<div class="alert alert-warning" role="alert">Sorry, we can not display this item.' +
    (text ? (' (' + text + ')') : '') +
    '</div>';
  }

  // We add origin_sort_key=$sort_key into the current
  // URL using pushState, if in a browser that supports. 
  //
  // The intention is to 'remember' the currently selected
  // item on browser back button to this page, etc. 
  //
  // It does assume the host app is supporting ?origin_sort_key=$sort_key
  // and passing it to template, to work. Could make more configurable
  // later. 
  function replaceSelectedState(item) {
    if ('history' in window && 'replaceState' in history && 'sort_key' in item) { 
      var query = location.search;
      if (query.length == 0)
        query = '?';

      // replace origin_sort_key only if it exists
      var re = new RegExp("([\\?&])origin_sort_key=([^&#]*)");
      query = query.replace(re, '$1origin_sort_key=' + encodeURIComponent(item.sort_key));
      
      history.replaceState({}, '', query + location.hash);
    }
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

        var item_attribute_hash = target.closest(".stack-item").data("stackviewItem");

        replaceSelectedState(item_attribute_hash);

        if(item_load_url && panel.length > 0) {
          event.preventDefault();

          loadItem(item_load_url,  panel,  item_attribute_hash );

          $('.active-item').removeClass('active-item');
          $(this).parent().addClass('active-item');
        }
      });

      // Catch stackview.page the FIRST time, so we can find the origin
      // document and add a special class to it, which we'll use to click
      // on it immediately, and set the scroll view so it's centered. 
      $(document).on("stackview.pageload.initial-select", function(event) {
        // Find the .stack-item which has data origin:true set, and click it. 
        // Since we're only executing on first load, this shouldn't be
        // that many items. 

        var item_load_url = $(event.target).closest(".shelfbrowser-browse-column").data('stackviewBrowserItemPath');

        var $origin_item;

        // Add .origin-item to origin, so we can do things with it....
        $(event.target).find(".stack-item").each(function(index, item) {
          if($(item).data("stackviewItem").is_origin_item) {
            $origin_item = $(item);
            // We add stackview-origin class to allow us to
            // find it and position the scroll properly on load. 
            $origin_item.addClass("stackview-origin");
          }
        });

        //... we want to simulate clicking the origin, if we have a load url,
        // so we can load it. 
        if (item_load_url) {
          $origin_item.find("a").trigger('click');
        }

        //... we want to try to set the scroll such that our origin item is
        // centered. 
        // stackview out of the box doesn't quite get this right, it's tricky,
        // we seem to be doing okay. 
        var container = $origin_item.closest("ul.stack-items");
        container.scrollTop( $origin_item.get(0).offsetTop - (container.height() / 2) + ($origin_item.height() / 2) )
        
        // Remove our handler, we only want to do this once. 
        $(document).off("stackview.pageload.initial-select");
      });
    }
  });

})(jQuery);