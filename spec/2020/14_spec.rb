# frozen_string_literal: true

require_relative '../../lib/2020/14'

module AOC2020
  module Task14
    RSpec.describe Task14 do
      describe ValueBitmask do
        let(:bitmask) { ValueBitmask.new 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X' }

        it 'applies correctly' do
          expect(bitmask.apply_to_value(11)).to eq 73
        end
      end

      describe AddressBitmask do
        it 'calculates addresses correctly' do
          bitmask = AddressBitmask.new '00000000000000000000000000000000X0XX'
          expect(bitmask.addresses_for(26)).to contain_exactly(16, 17, 18, 19, 24, 25, 26, 27)

          bitmask = AddressBitmask.new '000000000000000000000000000000X1001X'
          expect(bitmask.addresses_for(42)).to contain_exactly(26, 27, 58, 59)
        end
      end
    end
  end
end
