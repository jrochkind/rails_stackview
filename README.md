# RailsStackview

IN PROGRESS UNDER DEVELOPMENT NOT USABLE YET

**Tools** for integrating the Harvard Innovation Lab [stackview](https://github.com/harvard-lil/stackview) Javascript into a Rails app. 

This is not an out of the box solution, integrating it into your app will require some development.
The hardest part, for call-number browse, is typically arranging your call numbers somewhere
so they can be accessed in sorted order. 

RailsStackview also not fully mature -- solutions have been worked out for my own use case needs,
I've tried to architect in a way to support flexibility, and provide tools at different levels
for different needs. But not all possibile configuration or architecture to support flexiblity
have been fleshed out, and the architecture may not be ideal. 

We do provide the stackview assets in a way compatible with the asset pipeline, which
can be used directly. We also provide some higher level tools for certain use cases. 

Our focused use case is 'shelf browse', browse through a very long list of ordered
items, starting at a specified point in the middle. 

## Requirements

The Stackview code needs JQuery, so you should have JQuery loaded in your app. 

This code is meant for integration with a Rails app. It does not assume Blacklight,
although is usable with Blacklight. 

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

### RailsStackview Back-End Support

* By default assumes call numbers listed in database table
* migration
* Lcsort recommended, but any ordering you want
  * Adding bib number on the end of sort keys good idea
* routing
* Other FetchAdapters theoretically possible. Note our method of
  origin sort key with back/forward paging. 
* Start from specified sort key, can fetch from database. 
* Kind of on your own with indexing, messy example for traject. 
* Multiple call_types. 


### The Browser Template

* Needs NO footer to size stackview 'full viewport' properly. 
* Can accomodate header, but best to keep it small. 
* Best with no margin or padding provided by layout either. 
* Needs routing for back-end support, more routing for partials (stackview_browser_item_path)
* replaceState assumes origin_sort_key in query, and sort_key in stackview data dict. 

### Custom format plain

* Just include all RailsStackview assets instead of picking and choosing. 

## Development

### Vendored stackview assets

Stackview assets (JS, CSS, images) are included directly in source here, 
under [./vendor/assets](./vendor/assets).

The original stackview is not versioned, but the git SHA hash of
the currently vendored assets is included at 
[./vendor/assets/stackview.sha](./vendor/assets/stackview.sha)

There is a script for refreshing these assets in rails_stackview source,
see [./vendor/assets/README.md](./vendor/assets/README.md).

### Under-documented stackview loc_sort_order fetch mode

The original [stackview](https://github.com/harvard-lil/stackview) has a feature
that is currently undocumented over there, to send search params to a back-end
provider using a different method meant for taking a 'window' over very large
search results. 

Ordinarily, stackview assumes it's starting at the bottom of a list, and pages
through it by sending `start` and `limit` params to the back-end script. 

The alternate search mode is triggered by sending `'search_type': 'loc_sort_order'`
to the stackview init.  Contrary to the implications of the name, there's
really nothing specific to LC call numbers about the mode triggered, although
lc call numbers are the original use case.

When you set `'search_type': 'loc_sort_order'`, stackview assumes you will
be paging through a very large list of results; starting in the middle; but the
results can still be addressed by whole number indeces. 

When you set `'search_type': 'loc_sort_order'`, you should also send stackview
init an `id` key, with a whole number that is the 'starting point' for the view,
the initial view will be centered around that point in the list. 

stackview, instead of sending start and limit, will send a window of results desired
in the `query` param, looking like eg: `[100 TO 110]`.  (except URI encoded of course in
actual HTTP request). 

The back-end is expected to send back records 100 to 110 _inclusive of both ends_.
(Yes, this does mean that stackview is requesting 11 items at a time when your
configured limit is 10, perhaps that's a bug, but it's not really a problem) 

If the back-end sends back a "start: -1", then stackview assumes it's at the
end of the list -- -1 indicates 'end of list' on _either_ end, top or bottom. 

Endpoints of the window _can_ go negative.  If you start at id:0, stackview
might begin by requesting `[-5 TO 5]` for instance. This may have been accidental
on stackviews part, but we take advantage of it. 

The standard db-backed fetcher will always set the id to 0, but additionally
pass along an origin sortkey.  Future offsets are taken to be relative to
this sort key.  `[-10 to -1]` would mean the 10 items _before_ the origin sortkey. 
This allows us to avoid expensive 'deep paging' with offsets in the 6 digits or more --
although it's not perfect, if the user pages a _lot_, you can still get to large
expensive offsets. 