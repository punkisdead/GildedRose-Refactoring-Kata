# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'gilded_rose'

# Gilded Rose test suite
class TestGildedRose < Minitest::Test
  def test_foo
    items = [Item.new('foo', 0, 0)]
    GildedRose.new(items).update_quality
    assert_equal 'fixme', items[0].name
  end
end
