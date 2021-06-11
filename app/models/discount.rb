class Discount < ApplicationRecord
  belongs_to :merchant
  has_many :items, through: :merchant
  has_many :invoice_items, through: :items
  has_many :invoices, through: :invoice_items

  validates :name, :discount_percentage, :quantity_threshold, presence: true
  validates :discount_percentage, :quantity_threshold, numericality: true
end
