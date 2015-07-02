class StackviewDataController < ApplicationController
  # stackview doesn't like it if certain things are blank
  DefaultStackviewDocAttributes = {
    "measurement_height_numeric" => 23,
    "shelfrank" => 1,
    "measurement_page_numeric" => 100
  }

  # config for different call number types; we don't
  # fully support call number types yet, but are building for it. 
  # with the exception of the 'test' type
  class_attribute :_config_for_types
  self._config_for_types = {
    'default' => {
      :fetch_adapter => lambda { RailsStackview::DbWindowFetcher.new },
      # By default, automatic link to Blacklight catalog_path if present
      :link => lambda do |hash|
        if self.respond_to?(:catalog_path)
          catalog_path(hash["system_id"])
        else
          hash["link"]
        end
      end
    },
    'test' => {
      :fetch_adapter => lambda { RailsStackview::MockFetcher.new }
    },
    'lc' => {
      # defaults are good. 
    }
  }
  def self.set_config_for_type(type, attributes)
    type = type.to_s
    config = (self._config_for_types[type] ||= {})
    config.merge! attributes

    return config
  end
  def self.config_for_type(type)
    type = type.to_s

    config  = self._config_for_types[type]
    unless config
      raise ArgumentError, "No config found for #{type}"
    end
    default = _config_for_types['default']

    return config.reverse_merge(default)
  end
  def config_for_type(type)
    self.class.config_for_type(type)
  end
  # mostly for testing
  def self.remove_config_for_type(type)
    type = type.to_s
    _config_for_types.delete(type)
  end



  def fetch
    config = config_for_type( params[:call_number_type] )

    fetch_adapter = config[:fetch_adapter].call    

    # Make sure defaults are covered
    docs = fetch_adapter.fetch(params).collect do |d|      
      d = d.reverse_merge DefaultStackviewDocAttributes
      # stackview doens't like shelfrank's over 100
      d["shelfrank"] = [d["shelfrank"], 100].min
      # No need to pass on the 'pending' column
      d.delete("pending")

      d
    end

    # add in URLs
    url_proc = config[:link] || (lambda {|doc| doc["link"]})
    docs.each do |doc|
      doc["link"] = self.instance_exec(doc, &url_proc)
    end

    result = {'docs' => docs}
    result['start'] = "-1" if docs.empty?

    render :json => result
  end

end
