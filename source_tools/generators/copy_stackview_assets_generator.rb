require 'rails/generators'

class CopyStackviewAssets < Rails::Generators::Base
  argument :stackview_source_path, :type => :string, :required => true

  def initialize *args
    super 
    source_paths << File.expand_path( @stackview_source_path )
  end

  desc "copy all images from stackview"
  def copy_images
    directory "lib/images", "vendor/assets/images/stackview"
  end

  desc "copy stackview CSS with asset-url substitution"
  def copy_css
    # Copied to a sass file so we can use the asset-url helper to get proper
    # urls. 
    copy_file "lib/jquery.stackview.css", "vendor/assets/stylesheets/stackview/jquery.stackview.scss" do |content|
      content.gsub(/url\(["']?([^\)\"]*)["']?\)/, 'asset-url("stackview/\1")')
    end
  end

  desc "copy stackview JS"
  def copy_js
    copy_file "lib/jquery.stackview.min.js", "vendor/assets/javascripts/stackview/jquery.stackview.min.js"
  end

  desc "record stackview git SHA"
  def make_git_sha
    sha = `cd #{@stackview_source_path} && git rev-parse HEAD`
    if sha.empty?
      say_status("warning", "No stackview sha status can be recorded", :red)
      sha = "UNKNOWN at #{Time.now}\n"
    end


    create_file "vendor/assets/stackview.sha", sha
  end
  

end
