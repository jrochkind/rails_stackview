class DemoController < ApplicationController
  def index
  end

  def browse
    render :template => 'rails_stackview/browser', :locals => {:origin_sort_key => params["origin_sort_key"] || "M"}
  end
end
