# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../../test/dummy/config/environment.rb",  __FILE__)
ActiveRecord::Migrator.migrations_paths = [File.expand_path("../../test/dummy/db/migrate", __FILE__)]
require "rails/test_help"

# Filter out Minitest backtrace while allowing backtrace from other libraries
# to be shown.
Minitest.backtrace_filter = Minitest::BacktraceFilter.new

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__)
  ActiveSupport::TestCase.fixtures :all
end

# Add some useful assertions that minitest annoyingly leaves out
module Minitest::Assertions
  def assert_length(length, obj, msg = nil)
    unless obj.respond_to? :length
      raise ArgumentError, "object with assert_length must respond_to? :length", obj
    end

    msg ||= "Expected length of #{obj} to be #{length}, but was #{obj.length}"

    assert_equal(length, obj.length, msg.to_s )
  end

  def assert_present(obj)
    unless obj.respond_to? :present?
      raise ArgumentError, "object with assert_present must respond_to? :present?", obj
    end

    msg ||= "Expected #{obj}.present?"

    assert obj.present?, msg
  end
end