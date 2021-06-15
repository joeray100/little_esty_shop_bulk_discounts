class InvoiceItem < ApplicationRecord
  validates_presence_of :invoice_id,
                        :item_id,
                        :quantity,
                        :unit_price,
                        :status

  belongs_to :invoice
  belongs_to :item
  has_one :merchant, through: :item
  has_many :discounts, through: :merchant

  enum status: [:pending, :packaged, :shipped]

  # Best place to create 'greatest_discount' instance method due to relationship with item and merchant being of a singular nature.
  # Based on the rules given on project page.
  def greatest_discount
    discounts
    .where('? >= quantity_threshold', quantity)
    .order(discount_percentage: :desc)
    .pluck(:id)
    .first
  end

  def self.incomplete_invoices
    invoice_ids = InvoiceItem.where("status = 0 OR status = 1").pluck(:invoice_id)
    Invoice.order(created_at: :asc).find(invoice_ids)
  end
end
