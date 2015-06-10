module RailsStackview
  # A mock fetcher that just returns fake data, useful for testing, both manual and
  # automated testing. 
  #
  # Assumes 'loc_sort_order' style fetching, with query=[X TO Y] in params. 
  # 
  # Returns the designated number of records, with titles and other attributes
  # including the 'i' index
  class MockFetcher
    def fetch(params)
      first, last = RailsStackview.parse_query_range(params["query"])

      return first.upto(last).collect do |i|
        {
          'title' => "item #{i}",
          'system_id' => "doc_#{i}",
          'creator' => ["author #{i}"],
          'pub_date' => "2000",
          'measurement_page_numeric' => rand(1..500),
          'measurement_height_numeric' => ((25 + i*2) % 50),
          'shelfrank' => ((i*10) % 100),
          'link' => "http://example.org"
        }
      end
    end
  end
end