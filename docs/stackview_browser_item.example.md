An example of an implementation of the stackview_browser_item path, to return
an item description via an AJAX request, for the browser template. This is in
a Blacklight application, although different versions of Blacklight may vary in
some details, and this is not the only or neccesarily the best way to do it.

This code is not supported, provided as an example only.  

In `config/routes.rb`, route to a new action method we'll create in CatalogController.
The `:as => "stackview_browser_item"` is neccesary for integration with the browser
template JS, it looks for a route with that alias. 

~~~ruby
  # in config/routes.rb

  # Back-end returning html partial for clicks on items. 
  get "shelfbrowse_item", :to => "catalog#shelfbrowse_item", :as => "stackview_browser_item"
~~~

In our `app/controllers/catalog_controller.rb`, our new action method returns
a partial we'll create with the item details, with no layout, partial HTML only:

~~~ruby
  # in app/controllers/catalog_controller.rb

  # Returns partial HTML loaded by the rails_stackview AJAX on browse clicks. 
  def shelfbrowse_item
    # We use a blacklight method to look up the Blacklight document
    _, doc = get_solr_response_for_doc_id(params[:id])

    # And we pass that document to a partial we will create, along
    # with the specific call number browser location which will be passed
    # in a query param by the browser AJAX making the call. 
    render :partial => "shelfbrowse_item", :locals => {:document => doc, :call_number => params[:sort_key_display]}
  end
~~~

And our new partial template, the `shelfbrowse_item` template. We try
to re-use existing blacklight methods to show the same thing that would
be shown in search results for the item, but modified appropriately and
including the specific call number location in the browse. 

~~~ruby
# app/views/catalog/_shelfbrowse_item.html.erb

<% if local_assigns[:call_number] %>
    <p class="shelfbrowse-call-number text-muted">
      <%= call_number %>
    </p>
<% end %>

<%# I _think_ these are standard blacklight methods, not positive if
they are customized locally in our BL app. %>
<h5 class="index_title">
    <%= link_to_document document, document_heading(document) %>
</h5>

<%= render_document_partial(document, :index) %>
~~~