class Trip < ApplicationRecord
  validates_presence_of :destination, :lat, :lng
end