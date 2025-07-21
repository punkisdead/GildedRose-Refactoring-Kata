# frozen_string_literal: true

# This is a Ruby implementation of the Gilded Rose kata, which simulates the behavior of an inventory system for items
# with varying qualities and sell-by dates.
class GildedRose
  def initialize(items)
    @items = items
  end

  def update_quality
    @items.each do |item|
      case item.name
      when 'Aged Brie'
        update_brie(item)
      when 'Sulfuras, Hand of Ragnaros'
        update_sulfuras(item)
      when 'Backstage passes to a TAFKAL80ETC concert'
        update_backstage_passes(item)
      when /Conjured/
        update_conjured_item(item)
      else
        update_normal_item(item)
      end
    end
  end

  private

  def update_normal_item(item)
    item.sell_in -= 1
    return if item.quality <= 0

    item.quality -= 1
    item.quality -= 1 if item.sell_in <= 0
  end

  def update_brie(item)
    item.sell_in -= 1
    return if item.quality >= 50

    item.quality += 1 if item.quality < 50
    item.quality += 1 if item.sell_in <= 0 && item.quality < 50
  end

  def update_sulfuras(item)
    # "Sulfuras, Hand of Ragnaros" is a legendary item and does not change
  end

  def update_backstage_passes(item)
    item.sell_in -= 1
    return if item.quality >= 50

    item.quality += 1 if item.quality < 50
    item.quality += 1 if (item.sell_in < 11) && (item.quality < 50)
    item.quality += 1 if (item.sell_in < 6) && (item.quality < 50)
    return unless item.sell_in.negative?

    item.quality = 0 # Backstage passes drop to 0 quality after the concert
  end

  def update_conjured_item(item)
    item.sell_in -= 1

    return if item.quality <= 0

    # Degrade by 2 before sell date, by 4 after sell date
    degradation = item.sell_in.negative? ? 4 : 2
    item.quality = [item.quality - degradation, 0].max
  end
end

# The item class which models items in the kata
class Item
  attr_accessor :name, :sell_in, :quality

  def initialize(name, sell_in, quality)
    @name = name
    @sell_in = sell_in
    @quality = quality
  end

  def to_s
    "#{@name}, #{@sell_in}, #{@quality}"
  end
end
