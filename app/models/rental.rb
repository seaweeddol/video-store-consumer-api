class Rental < ApplicationRecord
  belongs_to :movie
  belongs_to :customer

  # validates :movie, uniqueness: { scope: :customer }
  validates :due_date, presence: true
  validate :due_date_in_future, on: :create

  after_initialize :set_checkout_date
  after_initialize :set_returned


  def self.first_outstanding(movie, customer)
    self.where(movie: movie, customer: customer, returned: false).order(:due_date).first
  end

  def self.overdue
    self.where(returned: false).where("due_date < ?", Date.today)
  end

private
  # due_date must be after today's date
  def due_date_in_future
    return unless self.due_date
    unless due_date > Date.today
      errors.add(:due_date, "Must be in the future")
    end
  end

  def set_checkout_date
    self.checkout_date ||= Date.today
  end

  def set_returned
    self.returned ||= false
  end
end
