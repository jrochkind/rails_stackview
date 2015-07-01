require 'test_helper'
#require 'rails_stackview/db_window_fetcher'

class DbWindowFetcherTest < ActiveSupport::TestCase
  setup do
    @center_sort_key = 'M  000100A110D300 000 NO3'
  end

  test "fetch around center" do
    results = RailsStackview::DbWindowFetcher.new.fetch(
      "origin_sort_key" => @center_sort_key, "query" => "[-5 TO 5]"
    )

    assert_length 11, results
    assert_good_list_of_hashes results

    assert_equal @center_sort_key, results[5]["sort_key"]

    assert_sorted_by_sort_key results

    assert results.all? {|h| h["sort_key_type"] == 'lc'}
  end

  test "fetch positive including" do
    results = RailsStackview::DbWindowFetcher.new.fetch(
      "origin_sort_key" => @center_sort_key, "query" => "[0 TO 10]"
    )

    assert_length 11, results
    assert_good_list_of_hashes results

    assert_equal @center_sort_key, results.first["sort_key"]

    assert_sorted_by_sort_key results
  end

  test "fetch positive ahead" do
    results = RailsStackview::DbWindowFetcher.new.fetch(
      "origin_sort_key" => @center_sort_key, "query" => "[2 TO 12]"
    )

    assert_length 11, results
    assert_good_list_of_hashes results

    assert_sorted_by_sort_key results

    assert results.none? {|h| h["sort_key"] <= @center_sort_key}, "Expected all sort_keys greater than #{@center_sort_key}"
  end

  test "fetch negative including" do
    results = RailsStackview::DbWindowFetcher.new.fetch(
      "origin_sort_key" => @center_sort_key, "query" => "[-10 TO 0]"
    )

    assert_length 11, results
    assert_good_list_of_hashes results

    assert_equal @center_sort_key, results.last["sort_key"]

    assert_sorted_by_sort_key results
  end

  test "fetch negative behind" do
    results = RailsStackview::DbWindowFetcher.new.fetch(
      "origin_sort_key" => @center_sort_key, "query" => "[-12 TO -2]"
    )

    assert_length 11, results
    assert_good_list_of_hashes results

    assert_sorted_by_sort_key results

    assert results.none? {|h| h["sort_key"] >= @center_sort_key}, "Expected all sort_keys less than #{@center_sort_key}"
  end

  test "fetch too far ahead" do
    results = RailsStackview::DbWindowFetcher.new.fetch(
      "origin_sort_key" => @center_sort_key, "query" => "[100 TO 110]"
    )

    assert_length 0, results
  end

  test "fetch too far behind" do
    results = RailsStackview::DbWindowFetcher.new.fetch(
      "origin_sort_key" => @center_sort_key, "query" => "[-110 TO -100]"
    )

    assert_length 0, results
  end


  def assert_sorted_by_sort_key(arr)
    assert_equal arr, arr.sort_by {|h| h["sort_key"]}, "Expected #{arr} to be sorted by sort_key"
  end

  def assert_good_list_of_hashes(results)
    assert_kind_of Array, results
    results.each do |r| 
      assert_kind_of Hash, r
      assert_present r["title"]
      assert_kind_of Array, r["creator"]
    end
  end

end