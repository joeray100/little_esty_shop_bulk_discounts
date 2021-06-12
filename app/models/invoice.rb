class Invoice < ApplicationRecord
  validates_presence_of :status,
                        :customer_id

  belongs_to :customer
  has_many :transactions
  has_many :invoice_items
  has_many :items, through: :invoice_items
  has_many :merchants, through: :items
  has_many :discounts, through: :merchants

  enum status: [:cancelled, :in_progress, :complete]

  def total_revenue
    invoice_items.sum("unit_price * quantity")
  end

  def total_discounted_revenue
    if total_discount == 0
      total_revenue
    else
      total_revenue - total_discount
    end
  end

  def total_discount
    merchants
    .joins(:discounts)
    .where('invoice_items.quantity >= quantity_threshold')
    .select('invoice_items.item_id')
    .group(:item_id)
    .maximum('invoice_items.quantity * invoice_items.unit_price * discounts.discount_percentage / 100')
    .pluck(1)
    .sum
  end

end
