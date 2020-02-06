require 'rails_helper'

RSpec.describe Trip, type: :model do
  describe 'Database table' do
    it { is_expected.to have_db_column :destination }
    it { is_expected.to have_db_column :lat }
    it { is_expected.to have_db_column :lng }
    it { is_expected.to have_db_column :days }
  end

  describe 'Factory' do
    it 'should have valid Factory' do
      expect(create(:trip)).to be_valid
    end
  end
end


