class StackviewDataController < ApplicationController
  # stackview doesn't like it if certain things are blank
  DefaultStackviewDocAttributes = {
    "measurement_height_numeric" => 1,
    "shelfrank" => 1,
    "measurement_page_numeric" => 1
  }

  # config for different call number types; we don't
  # fully support call number types yet, but are building for it. 
  # with the exception of the 'test' type
  class_attribute :config_for_types
  self.config_for_types = {
    'test' => {
      :fetch_adapter => lambda { RailsStackview::MockFetcher.new }
    },
    'lc' => {
      :fetch_adapter => lambda { RailsStackview::DbWindowFetcher.new }
    }
  }


  def fetch
    config = config_for_types[ params[:call_number_type] ]

    fetch_adapter = config[:fetch_adapter].call    

    docs = fetch_adapter.fetch(params).collect {|d| d.reverse_merge DefaultStackviewDocAttributes }

    render :json => {'docs' => docs}
  end

end
