[![Build Status](https://travis-ci.org/jrochkind/rails_stackview.svg?branch=master)](https://travis-ci.org/jrochkind/rails_stackview) [![Gem Version](https://badge.fury.io/rb/rails_stackview.svg)](http://badge.fury.io/rb/rails_stackview)

# RailsStackview

Packages the assets from teh Harvard Library Innovation Lab's [stackview](https://github.com/harvard-lil/stackview) for the Rails asset pipeline, and provides additional optional integration support with a controller and a template. 

This is not an out of the box solution, integrating it into your app will require some development.

The hardest part, for call-number browse, is typically arranging your call numbers somewhere
so they can be accessed in sorted order. 

RailsStackview contains the original stackview assets, arranged for the Rails asset pipeline. Along with some higher-level components. These higher-level have been created for my own use cases and needs; while I've tried to give a nod to future expandability, they haven't been created to be fully robust and configurable for all use cases. In this project, for a change, I've tried to be guided by keeping it simple and [YAGNI](http://martinfowler.com/bliki/Yagni.html). 

My focused use case is 'shelf browse', browse through a very long list of ordered
items, starting at a specified point in the middle. 

## Requirements

The Stackview code needs JQuery, so you should have JQuery loaded in your app. 

This code is meant for integration with a Rails app. It does not assume Blacklight,
although is usable with Blacklight. 

Add it to your app like any other gem, by listing in the Gemfile. 

## Usage

### Stackview assets are available. 

To use the stackview assets directly, include them in your asset pipeline. 

You can include just the original stackview JS and CSS:

~~~ruby
# app/assets/javascripts/application.js
//= require jquery.stackview.js
~~~

~~~ruby 
# app/assets/stylesheets/application.css
*= require stackview/jquery.stackview.scss
~~~

Now Stackview will be available in your app, via the asset pipeline,
using the documented stackview API. (eg `$(something).stackView(something)`)

Or alternatley you can include all RailsStackview JS/CSS, which provides some
support for higher level features, along with the original stackview assets:

~~~ruby
# app/assets/javascripts/application.js
//= require rails_stackview
~~~

~~~ruby 
# app/assets/stylesheets/application.css
*= require rails_stackview
~~~

One additional feature included is an automatic application of stackview
to any `<div>` with a `data-stackview-init` attribute, containing JSON
serialization of stackview init arguments. 

This can be convenient for integrating with Rails, letting you for instance
specify your own rails controller as a data provider to stackview:

~~~erb
<%= content_tag("div", "",
    :id => "whatever_you_want",
    :class => "whatever you want",
    :data => {
        :stackview_init => {
            :id => 0,
            :url => your_route_helper(some_args),
            :search_type => "loc_sort_order"
        }
    })
%>
~~~

The data-stackview-init hash can be whatever you like, as initialization
arguments for the original stackview. 

### Back-End Support: The StackviewDataController to feed data to stackview

The [StackviewDataController](./app/controllers/stackview_data_controller.rb) is provided
to feed data to a stackview UI,
with the use case of 'call number browse', or starting at an arbitrary
point in a very long list of items, and paging both back and forwards. 

The current implementation of the StackviewDataController counts
on a table of individual call numbers existing in your database. 
It is difficult to get the querries we need out of Solr directly, and
we opted to create a duplicate 'denormalized' database table with
exactly the info needed to support the front-end. 

Once you've added `rails_stackview` to your Gemfile, you can
install a migration into your app to create the `stackview_call_numbers` table,
with:

    bundle exec rake rails_stackview_engine:install:migrations

It is up to you to fill this table with call number data. If you
use [traject](https://github.com/traject/traject) to index
MARC to Solr, you can look at [this example of how I handle
creating the stackview_call_numbers table at the same time
I do my Solr indexing](./docs/traject-indexing.example.rb)

Here are the elements of the `stackview_call_numbers` table:

* `system_id` (string), the primary key of the original item
   in your overall system, used for linking from stackview
   to your system. 
* `sort_key` (string), a _sortable_ representation of your call
   number or other ordering. Used for sorting the stack. If you
   are using LC Call Numbers and populating this table in ruby,
   we suggest the [Lcsort](https://github.com/pulibrary/lcsort) gem for turning a call number
   into a sortable representation. Some features will end up less confusing if
   sort_keys are unique, although they aren't required to be -- I append
   the bibID to the end of each sort_key, to make them unique even if two
   bibs share the same call number. 
* `sort_key_display` (string, optional), the original human-displayable
   call number, can be used for display.
* `title` (string), title to use in stackview representation. 
* `creator` (string, optional), author to use in stackview representation. 
* `pub_date` (string, optional), publication year (as string) to use in stackview representation. 
* `measurement_page_numeric` (int, optional), page count, passed to stackview for represnetation width.
* `measurement_height_numeric` (int, optional), item height (usually in cm), passed to stackview for representation height
* `shelfrank` (int, optional), 1-100, passed to stackview for "heatmap" intensity coloring of representation. Normally a count of number of times checked out. 
* `created_at` (datetime, optional), can set to row creation date for your administrative convenience. 
* `format`: Passed to stackview to choose a format-specific view template, should be one of magic words from stackview's own source (case-sensitive, not entirely consistent): `book` `Serial`, `Sound Recording`, `Video/Film`, `webpage`. Also our own special `plain` format, which can also take a specific description etc `plain:VHS`.  See more at "Custom Plain Format" below. 
* `sort_key_type` (string): Eventually we plan to support multiple separate call number runs, which will
be identified by `sort_key_type`. We have the beginnings of such an architecture, but
it may not be fully fleshed out and may have performance implications. For now recommend always setting
this to the default, `lc`. 

Once you've filled this database, you can use it with our Browser front-end, or you can construct your own stackview front-end telling stackview to use this to use this controller as a source for:

Add routing to the StackviewDataController in your own `./config/routes.rb`

~~~ruby
    get 'stackview_data/:call_number_type', :to => "stackview_data#fetch", :as => "stackview_data"
~~~

(That specific `:as => 'stackview_data'` is needed if you are using our Browser front-end)

When you initialize a stackview UI element, you have to tell it what item to start at, by giving it a `sort_key` (normalized sortable call number representation) value.  One way to get a sort_key for
a known item, is simply to look it up from the existing `stackview_call_numbers` table:

~~~ruby
# may be nil if no such system_id recorded
origin_sort_key = StackviewCallNumber.where(:system_id => document.id).order("created_at").pluck(:sort_key).first 
~~~

Now you can initialize a stackview UI element, using the RailsStackview feature
to automatically init a stackview from a data-stackview-init attribute:

~~~erb
    <%= content_tag("div", "",
        :id => "my_stackview",
        :data => {
            :stackview_init => {
                :id => 0,
                :url => stackview_data_path("lc", :origin_sort_key => origin_sort_key),
                :search_type => "loc_sort_order"
            }
        })
    %>
~~~

If you pass an :origin_sort_key that doesn't actually exist in the database,
the StackviewDataController will still put the user into the stacks at the closest
point to that theoretical call number. 

#### Set the link URL

To set the `link` property on the JS objects passed to stackview, which will be used
as the `href` on stackview item hyperlinks, set a lambda/proc as configuration, perhaps
in an initializer. The proc gets the already constructed stackview hash as a parameter,
and will be executed in the context of the controller so you can use controller
methods, such as Rails route helpers. 

      StackviewDataController.set_config_for_type("default", {
        :link => lambda do |hash|
          catalog_path(hash["system_id"])
        end
      })

Above is similar to the default, which should work for at least some versions
of Blacklight by default. 


#### What's it doing then?

To use the current stackview API (as far as what it fetches from it's back-end), in
a flexible and high-performance way, we do something a bit odd. 

The URL fixes the controller to have an 'origin' you specify. Stackview, in "search_type: loc_sort_order" (stackview's terminology) will then send it negative and positive offsets as the user browses -- eg asking
for items 10 to 20, or -25 to -35. The controller will use SQL `OFFSET` to page forwards and backwards
around the origin.  This ends up pretty performant, although it is odd. 

The Stackview `loc_sort_order` mode is under-documented on stackview's site, but it's meant
for 'infinite' scrolling both forwards and back around an origin. Stackview assumes
you're initialize it to the actual i-index `id` where you want to start; but we set
a "logical" id starting point of 0, and encode our actual origin in the URL instead. Then
we can consider stackview's indexes to actually be offsets from our origin. 

Weird, but it works, without major changes to the stackview JS code itself.


#### Don't want to use the stackview_call_numbers table?

It is kind of hacky. Do you have another source for your call numbers? Do you want
to try to get them via Solr directly using the ndushay/stanford hack? 

The code extracts out the actual fetch logic into a [RailsStackview::DbWindowFetcher](./app/fetch_adapters/rails_stackview/db_window_fetcher.rb) adapter.
We intend to let you replace it with your own adapter, that takes the HTTP params sent by
stackview itself, and returns a list of hashes to be given back to it. 

This architecture isn't neccesarily fully fleshed out, some parts of RailsStackview
may be hard-coded in unpleasant ways, but the beginnings are there. 


### Front-end Support: The Browser Template

You can write your own Rails template with the stackview element on it. It turns
out it's a bit tricky to get right for common cases. 

`rails_stackview` provides a 'browser' template you can use, which is a two-column
display with stackview on the left, and an item detail panel on the right. It
takes care of a lot of odd edge cases and details, especially focused again on
an 'infinite' shelf browser use case. 

You can use this template in your own controller action method. It needs to be
initialized with an starting point sortkey, which the stack will center on. It's
recommended you use a query parameter to pass in the sort key -- the browser
javascript includes some code to update such a query param with JS replaceState(),
to keep back button working well. 

    render :template => 'rails_stackview/browser', :locals => {:origin_sort_key => params["origin_sort_key"]}

You may want to customize your Rails layout template to work best with the browser template. 
The browser template is designed best to work with _no_ padding or spacing
underneath it -- Javascript will set the stackview element to stretch to the bottom
of the browser. A small header is okay. No right or left margin or padding is best. 

The browser template does use the back-end StackviewDataController, you will need
to have that set up properly as above. 

If you want a click on a stack item to load information in the right panel, then you need
to define your own Rails route with a `stackview_browser_item`, which returns partial
HTML that should be loaded (via AJAX) in the item detail panel on a click. 

We have [an example of how I implemented the `stackview_browser_item` action in a 
Blacklight app](./docs/stackview_browser_item.example.md). 

After an item is loaded by the browser JS, a custom `stackview-item-load` JS event is
triggered, with the item panel div as the target. 

On very small screens, the browser is only a single column without the item detail panel,
and clicks on items will follow the href set on the items, see above under `Set the link URL`. 


### Custom format plain

`rails_stackview` adds it's own custom "plain" format, which we use for items
that are neither books, CDs, DVDs, etc. Or where we can't be sure what format they are. 

The design isn't too sophisticated, but is meant to look kind of like a plain
box with a printed label. It does implement stackview heatmap coloring. 

If you have included `rails_stackview` CSS and JS, the plain format is available.

Set format format property to `plain` to trigger. Or, you can set
additional format description after a colon: `plain:LP`, or `plain:Whatever we want`,
and the additional format description will be included on the label. 

## Development

### Vendored stackview assets

Stackview assets (JS, CSS, images) are included directly in source here, 
under [./vendor/assets](./vendor/assets).

The original stackview is not versioned, but the git SHA hash of
the currently vendored assets is included at 
[./vendor/assets/stackview.sha](./vendor/assets/stackview.sha)

There is a script for refreshing these assets in rails_stackview source,
see [./vendor/assets/README.md](./vendor/assets/README.md).

