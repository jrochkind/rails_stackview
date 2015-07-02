module RailsStackview

  # Fetches from the stackview_call_numbers table with ActiveRecord
  #
  # * Assumes a windowing `search_type:loc_sort_order` in stackview, which
  #   sends query=[X TO Y] in params. 
  #
  # * Additionally assumes we get an `origin_sort_key` in params,
  #   which will used as the "zero point" for stackview's query ranges. 
  #   It must be an actual normalized sort_key -- if it does not exist in the DB,
  #   we'll just browse from that point in sort order though. 
  #
  #   We use this origin_sortkey to try and avoid very deep offsets in our
  #   SQL, which get expensive, although if the user pages a LOT they can
  #   still get there. If this is not good enough, we'll have to contribute
  #   features to stackview to provide alternate windowing based on sortkeys
  #   alone. 
  #
  #  Create a path to the StackviewDataController using 'lc' call_number_type,
  #  which uses this fetcher, specifying the origin_sort_key as a query param:
  #
  #     stackview_data_path("lc", :origin_sort_key => some_sort_key)
  class DbWindowFetcher

    def fetch(params)
      @origin_sort_key = params["origin_sort_key"]
      @sort_key_type   = params["sort_key_type"] || "lc"

      unless @origin_sort_key.present?
        raise ArgumentError, "`origin_sort_key` param required, specifying where to start the browse"
      end

      (first, last)  = RailsStackview.parse_query_range(params["query"])
      unless first < last
        raise ArgumentError, "beginning of range must be less than end: #{params["query"]}"
      end


      # Fetch the AR models, then turn em into hashes, which include all
      # columns in the db, excluding some we don't want. 
      #
      # Plus we need to turn our single creator into an array, cause
      # that's what stackview wants.
      results = fetch_records(first, last).collect do |record|
        record.attributes.except('id').reject {|k, v| v.blank? }.
          merge("creator" => (record["creator"].present? ? [record['creator']] : record['creator']))
      end

      # Mark the thing at 0 index as origin:true, so it can be auto-selected
      # by browser. 
      if (first..last).cover?(0)
        results[first.abs]["is_origin_item"] = true
      end

      return results
    end


    # Returns ActiveRecord StackviewCallNumber objects. 
    def fetch_records(first, last)
      if first >= 0 && last >= 0 # all positive
        positive_fetch(first, last)
      elsif first < 0 && last >= 0# cross zero-boundary
        # have to do half first and half last
        negative_fetch(first, -1) + positive_fetch(0, last)
      else # all negative
        negative_fetch(first, last)
      end
    end

    def positive_fetch(first, last)
      StackviewCallNumber.where("sort_key >= ?", @origin_sort_key).
        where(:sort_key_type => @sort_key_type).
        where(:pending => false).
        order("sort_key ASC").
        offset(first).limit(last - first + 1)
    end

    def negative_fetch(first, last)
      StackviewCallNumber.where("sort_key < ?", @origin_sort_key).
        where(:sort_key_type => @sort_key_type).
        where(:pending => false).
        order("sort_key DESC").
        offset(last.abs - 1).limit(last - first + 1).
        reverse
    end

  end
end