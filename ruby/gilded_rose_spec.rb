# frozen_string_literal: true

require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
  add_filter '/test/'
end

require 'rspec'

require File.join(File.dirname(__FILE__), 'gilded_rose')

# rubocop:disable Metrics/BlockLength
describe GildedRose do
  # Item factories
  let(:normal_item) { Item.new('Normal Item', sell_in, quality) }
  let(:aged_brie) { Item.new('Aged Brie', sell_in, quality) }
  let(:sulfuras) { Item.new('Sulfuras, Hand of Ragnaros', sell_in, 80) }
  let(:backstage_pass) { Item.new('Backstage passes to a TAFKAL80ETC concert', sell_in, quality) }
  let(:conjured_item) { Item.new('Conjured Mana Cake', sell_in, quality) }

  # Default values
  let(:sell_in) { 10 }
  let(:quality) { 20 }
  let(:item) { normal_item }

  # Helper method
  let(:update_quality) do
    gilded_rose = GildedRose.new([item])
    gilded_rose.update_quality
  end

  describe '#update_quality' do
    it 'never changes item names' do
      items = [Item.new('foo', 0, 0)]
      GildedRose.new(items).update_quality
      expect(items[0].name).to eq 'foo'
    end

    describe 'Normal Items' do
      let(:item) { normal_item }

      context 'before sell date' do
        let(:sell_in) { 5 }
        let(:quality) { 20 }

        it 'decreases quality by 1 each day' do
          update_quality
          expect(item.quality).to eq(19)
        end

        it 'decreases sell_in by 1 each day' do
          update_quality
          expect(item.sell_in).to eq(4)
        end

        context 'with zero quality' do
          let(:quality) { 0 }

          it 'never has negative quality' do
            update_quality
            expect(item.quality).to eq(0)
          end
        end
      end

      context 'after sell date' do
        let(:sell_in) { -1 }
        let(:quality) { 20 }

        it 'decreases quality by 2 each day' do
          update_quality
          expect(item.quality).to eq(18)
        end
      end
    end

    describe 'Aged Brie' do
      let(:item) { aged_brie }

      context 'before sell date' do
        let(:sell_in) { 5 }
        let(:quality) { 10 }

        it 'increases in quality as it ages' do
          update_quality
          expect(item.quality).to eq(11)
        end

        it 'decreases sell_in by 1 each day' do
          update_quality
          expect(item.sell_in).to eq(4)
        end

        context 'with maximum quality' do
          let(:quality) { 50 }

          it 'never exceeds quality of 50' do
            update_quality
            expect(item.quality).to eq(50)
          end
        end
      end

      context 'after sell date' do
        let(:sell_in) { -1 }
        let(:quality) { 10 }

        it 'increases in quality twice as fast' do
          update_quality
          expect(item.quality).to eq(12)
        end

        context 'with quality near maximum' do
          let(:quality) { 49 }

          it 'never exceeds quality of 50' do
            update_quality
            expect(item.quality).to eq(50)
          end
        end
      end
    end

    describe 'Sulfuras (Legendary Item)' do
      let(:item) { sulfuras }

      context 'before sell date' do
        let(:sell_in) { 5 }

        it 'never changes in quality' do
          original_quality = item.quality
          update_quality
          expect(item.quality).to eq(original_quality)
        end

        it 'never changes in sell_in' do
          original_sell_in = item.sell_in
          update_quality
          expect(item.sell_in).to eq(original_sell_in)
        end

        it 'maintains quality of 80' do
          update_quality
          expect(item.quality).to eq(80)
        end
      end

      context 'after sell date' do
        let(:sell_in) { -1 }

        it 'never changes in quality' do
          original_quality = item.quality
          update_quality
          expect(item.quality).to eq(original_quality)
        end

        it 'never changes in sell_in' do
          original_sell_in = item.sell_in
          update_quality
          expect(item.sell_in).to eq(original_sell_in)
        end

        it 'maintains quality of 80' do
          update_quality
          expect(item.quality).to eq(80)
        end
      end
    end

    describe 'Backstage Passes' do
      let(:item) { backstage_pass }

      context 'when concert is far away (>10 days)' do
        let(:sell_in) { 15 }
        let(:quality) { 20 }

        it 'increases in value slowly' do
          update_quality
          expect(item.quality).to eq(21)
        end

        it 'decreases sell_in by 1 each day' do
          update_quality
          expect(item.sell_in).to eq(14)
        end
      end

      context 'when concert approaches (6-10 days)' do
        let(:sell_in) { 10 }
        let(:quality) { 20 }

        it 'increases in value moderately' do
          update_quality
          expect(item.quality).to eq(22)
        end

        context 'when nearing maximum value' do
          let(:quality) { 49 }

          it 'respects quality ceiling' do
            update_quality
            expect(item.quality).to eq(50)
          end
        end
      end

      context 'when concert is imminent (≤5 days)' do
        let(:sell_in) { 5 }
        let(:quality) { 20 }

        it 'increases in value rapidly' do
          update_quality
          expect(item.quality).to eq(23)
        end

        context 'when nearing maximum value' do
          let(:quality) { 48 }

          it 'respects quality ceiling' do
            update_quality
            expect(item.quality).to eq(50)
          end
        end
      end

      context 'when concert has passed' do
        let(:sell_in) { -1 }
        let(:quality) { 20 }

        it 'becomes completely worthless' do
          update_quality
          expect(item.quality).to eq(0)
        end
      end
    end

    describe 'Quality System Rules' do
      context 'quality boundaries' do
        context 'minimum quality (0)' do
          it 'prevents normal items from going below 0' do
            item = Item.new('Normal Item', -1, 0)
            gilded_rose = GildedRose.new([item])
            gilded_rose.update_quality
            expect(item.quality).to eq(0)
          end

          it 'allows aged brie to increase from 0' do
            item = Item.new('Aged Brie', 5, 0)
            gilded_rose = GildedRose.new([item])
            gilded_rose.update_quality
            expect(item.quality).to eq(1)
          end
        end

        context 'maximum quality (50)' do
          it 'prevents normal items from exceeding 50' do
            item = Item.new('Normal Item', 5, 50)
            gilded_rose = GildedRose.new([item])
            gilded_rose.update_quality
            expect(item.quality).to eq(49)
          end

          it 'prevents aged brie from exceeding 50' do
            item = Item.new('Aged Brie', 5, 50)
            gilded_rose = GildedRose.new([item])
            gilded_rose.update_quality
            expect(item.quality).to eq(50)
          end

          it 'allows Sulfuras to exceed 50 (legendary exception)' do
            item = Item.new('Sulfuras, Hand of Ragnaros', 5, 80)
            gilded_rose = GildedRose.new([item])
            gilded_rose.update_quality
            expect(item.quality).to eq(80)
          end
        end
      end

      context 'sell_in progression' do
        it 'decreases sell_in for all non-legendary items' do
          items = [
            Item.new('Normal Item', 5, 20),
            Item.new('Aged Brie', 5, 20),
            Item.new('Backstage passes to a TAFKAL80ETC concert', 5, 20)
          ]
          gilded_rose = GildedRose.new(items)
          gilded_rose.update_quality

          items.each do |item|
            expect(item.sell_in).to eq(4)
          end
        end

        it 'never changes sell_in for Sulfuras' do
          item = Item.new('Sulfuras, Hand of Ragnaros', 5, 80)
          gilded_rose = GildedRose.new([item])
          gilded_rose.update_quality
          expect(item.sell_in).to eq(5)
        end
      end

      context 'critical transition points' do
        it 'handles sell_in = 0 transition correctly' do
          normal_item = Item.new('Normal Item', 0, 20)
          backstage_pass = Item.new('Backstage passes to a TAFKAL80ETC concert', 0, 20)
          gilded_rose = GildedRose.new([normal_item, backstage_pass])

          gilded_rose.update_quality

          expect(normal_item.quality).to eq(18) # degrades by 2 after sell date
          expect(normal_item.sell_in).to eq(-1)
          expect(backstage_pass.quality).to eq(0) # drops to 0 after concert
          expect(backstage_pass.sell_in).to eq(-1)
        end
      end
    end

    describe 'Conjured Items (Future Implementation)' do
      let(:item) { conjured_item }

      it 'degrades conjured items twice as fast before sell date'
      it 'degrades conjured items four times as fast after sell date'
    end
  end
end
# rubocop:enable Metrics/BlockLength
