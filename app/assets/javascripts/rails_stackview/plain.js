(function($, window, undefined) {
  /*
      A very poorly-designed type meant for 'other', meant to look
      sort of like a simple box with a typed sticky label.  

      Trigger with "format: 'plain'", OR add a format label on the end
      too:

          format: "plain: VHS"

      The 'title' and extra format info will be displayed, along with pub_date. 
      Author display not currently included. 

      measurement_height_numeric can control box height, like 'book'
      type. Box width is fixed though. 
  */
 $.extend(true, window.StackView.defaults, {
    selectors: {
      plain: '.stack-plain'
    },
    plain: {
      max_height_percentage: 100,
      max_height: 39,
      min_height_percentage: 20,
      min_height: 10
    }
  });

  /*
     #translate(number, number, number, number, number) - Private
  
     Takes a value (the first argument) and two ranges of numbers. Translates
     this value from the first range to the second range.  E.g.:
  
     translate(0, 0, 10, 50, 100) returns 50.
     translate(10, 0, 10, 50, 100) returns 100.
     translate(5, 0, 10, 50, 100) returns 75.
  
     http://stackoverflow.com/questions/1969240/mapping-a-range-of-values-to-another
  */
  var translate = function(value, start_min, start_max, end_min, end_max) {
    var start_range = start_max - start_min,
        end_range = end_max - end_min,
        scale = (value - start_min) / (start_range);
    
    return end_min + scale * end_range;
  };

  /*
     #get_height(StackView, object) - Private
  
     Takes a StackView options object and a book object. Returns a
     normalized book height percentage, taking into account the minimum
     height, maximum height, height multiple, and translating them onto
     the percentage range specified in the stack options.
  */
  var get_height = function(options, book) {
    var height = parseInt(book.measurement_height_numeric, 10),
        min = options.book.min_height,
        max = options.book.max_height;
    
    if (isNaN(height)) {
      height = min;
    }
    height = Math.min(Math.max(height, min), max);
    height = translate(
      height,
      options.plain.min_height,
      options.plain.max_height,
      options.plain.min_height_percentage,
      options.plain.max_height_percentage
    );
    return height + '%';
  };

  /*
     #get_author(object) - Private
  
     Takes an item and returns the item's author, taking the first
     author if an array of authors is defined.
  */
  var get_author = function(item) {
    var author = item.creator && item.creator.length ? item.creator[0] : '';
    
    if(/^([^,]*)/.test(author)) {
      author = author.match(/^[^,]*/);
    }
    
    return author;
  };


  window.StackView.register_type({
    name: 'plain',

    match: function(item) {
      return item.format === 'plain' || item.format.match(/^plain\:/);
    },

    adapter: function(item, options) {
      return {
        heat: window.StackView.utils.get_heat(item.shelfrank),
        box_height: get_height(options, item),
        link: item.link,
        title: item.title,
        author: get_author(item),
        year: item.pub_date,
        format_descr: item.format.match(/^plain\:/) ? item.format.replace(/^plain\:/, '') : undefined
      };
    },

    template: '\
      <li class="stack-item stack-plain heat<%= heat %>" style="width:<%= box_height %>">\
        <a href="<%= link %>" target="_blank">\
          <span class="spine-text">\
              <p class="plain-title"><%= title %></p>\
              <p class="plain-format"><%= format_descr %></p>\
              <p class="plain-author"><%= author %></p>\
          </span>\
          <span class="spine-year"><%= year %></span>\
          <span class="plain-top item-colors"></span>\
          <span class="plain-edge item-colors"></span>\
        </a>\
      </li>'
  });
})(jQuery, window);