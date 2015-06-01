module RailsStackview
  class Engine < ::Rails::Engine
    # We need to precompile our stackview pngs, not sure what Rails
    # is up to. 
    config.assets.precompile += %w[stackview/*.png stackview/*.gif stackview/*.jpg] 
  end
end
