class StackviewDataController < ApplicationController
  # config for different call number types; we don't
  # fully support call number types yet, but are building for it. 
  # with the exception of the 'test' type
  class_attribute :config_for_types
  self.config_for_types = {
    'test' => {
      :fetch_adapter => lambda { RailsStackview::MockFetcher.new }
    }
  }


  def fetch
    config = config_for_types[ params[:call_number_type] ]
    
    fetch_adapter = config[:fetch_adapter].call

    render :json => {'docs' => fetch_adapter.fetch(params)}
  end

end
