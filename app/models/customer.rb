class Customer < ApplicationRecord
  has_many :rentals
  has_many :movies, through: :rentals

  # returns number of movies checked out
  def movies_checked_out_count
    self.rentals.where(returned: false).length
  end
end
