class DemoController < ApplicationController
  def index
  end

  def browse
    render :template => 'rails_stackview/browser', :locals => {:origin_sort_key => params["origin_sort_key"] || "M"}
  end

  # Return partial HTML used for browser to display item on page
  # For this demo, we just echo back the params. 
  def browse_partial
    render :layout => false, :html => params.to_json
  end
end
