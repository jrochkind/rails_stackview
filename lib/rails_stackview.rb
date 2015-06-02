require "rails_stackview/engine"

module RailsStackview


  # Utility methods

  # Parses [XX TO YY] to ints. 
  #
  #     first, last = RailsStackview.parse_query_range("[-10 TO 50]")
  #     # first == -10 ; last == 50
  #
  # Raises an ArgumentError if input string isn't in expected format. 
  def self.parse_query_range(str)
    unless str =~ /\[(\-?\d+) TO (\-?\d+)\]/
      raise ArgumentError, "expect a query in the form `[\d+ TO \d+]`"
    end
    return [$1.to_i, $2.to_i]
  end
end
