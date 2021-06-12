require 'rails_helper'

RSpec.describe Invoice, type: :model do
  describe "validations" do
    it { should validate_presence_of :status }
    it { should validate_presence_of :customer_id }
  end

  describe "relationships" do
    it { should belong_to :customer }
    it { should have_many :transactions}
    it { should have_many(:items).through(:invoice_items) }
    it { should have_many(:merchants).through(:items) }
    it { should have_many(:discounts).through(:merchants) }
  end

  before :each do
    @merchant1 = Merchant.create!(name: 'Hair Care Merchant')
    @item1 = @merchant1.items.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, status: 1)
    @item8 = @merchant1.items.create!(name: "Butterfly Clip", description: "This holds up your hair but in a clip", unit_price: 5)
    @discount1 = @merchant1.discounts.create!(name: "10%", discount_percentage: 10, quantity_threshold: 10)
    @discount2 = @merchant1.discounts.create!(name: "20%", discount_percentage: 20, quantity_threshold: 20)

    @merchant2 = Merchant.create!(name: 'Random Product Merchant')
    @item3 = @merchant2.items.create!(name: "Brush", description: "This takes out tangles", unit_price: 5)
    @item4 = @merchant2.items.create!(name: "Hair tie", description: "This holds up your hair", unit_price: 1)

    @customer1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')
    @invoice1 = @customer1.invoices.create!(status: 2, created_at: "2012-03-27 14:54:09")
    @invoice2 = @customer1.invoices.create!(status: 2, created_at: "2012-04-27 14:54:09")
    @invoice3 = @customer1.invoices.create!(status: 2, created_at: "2012-04-27 14:54:09")
    # should get discount
    @ii_1 = InvoiceItem.create!(invoice_id: @invoice1.id, item_id: @item1.id, quantity: 10, unit_price: 10, status: 2) # 10%
    @ii_3 = InvoiceItem.create!(invoice_id: @invoice1.id, item_id: @item8.id, quantity: 20, unit_price: 10, status: 0) # 15%
    #  should not get discount
    @ii_2 = InvoiceItem.create!(invoice_id: @invoice1.id, item_id: @item1.id, quantity: 5, unit_price: 10, status: 0)
    #  should not get discount
    @ii_4 = InvoiceItem.create!(invoice_id: @invoice1.id, item_id: @item3.id, quantity: 15, unit_price: 10, status: 0)
    @ii_5 = InvoiceItem.create!(invoice_id: @invoice1.id, item_id: @item4.id, quantity: 10, unit_price: 8, status: 2)
  end

  describe "instance methods" do

    describe '#total_revenue' do
      it "returns the total revenue for an invoice" do
        expect(@invoice1.total_revenue).to eq(580)
      end

      it "Testing total_revenue in conditional. Total Discount should return zero." do
        merchant1 = Merchant.create!(name: 'Merchant 1')
        merchant2 = Merchant.create!(name: 'Merchant 2')
        merchant3 = Merchant.create!(name: 'Merchant 3')

        discount1 = merchant1.discounts.create!(name: "discount1", discount_percentage: 10, quantity_threshold: 10)
        discount2 = merchant1.discounts.create!(name: "discount2", discount_percentage: 20, quantity_threshold: 15)

        discount3 = merchant2.discounts.create!(name: "discount3", discount_percentage: 30, quantity_threshold: 20)
        discount4 = merchant3.discounts.create!(name: "discount4", discount_percentage: 20, quantity_threshold: 10)

        customer1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')
        invoice1 = customer1.invoices.create!(status: 2, created_at: "2012-03-27 14:54:09")

        item1 = merchant1.items.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, status: 1)
        item2 = merchant1.items.create!(name: "Butterfly Clip", description: "This holds up your hair but in a clip", unit_price: 5)
        item3 = merchant2.items.create!(name: "Brush", description: "This takes out tangles", unit_price: 5)
        item4 = merchant3.items.create!(name: "Hair tie", description: "This holds up your hair", unit_price: 1)

        ii_1 = InvoiceItem.create!(invoice_id: invoice1.id, item_id: item1.id, quantity: 5, unit_price: 20, status: 2)
        ii_3 = InvoiceItem.create!(invoice_id: invoice1.id, item_id: item2.id, quantity: 5, unit_price: 10, status: 0)
        ii_2 = InvoiceItem.create!(invoice_id: invoice1.id, item_id: item3.id, quantity: 18, unit_price: 10, status: 1)
        ii_4 = InvoiceItem.create!(invoice_id: invoice1.id, item_id: item4.id, quantity: 5, unit_price: 15, status: 1)

        expect(invoice1.total_revenue).to eq(405)
        expect(invoice1.total_discount).to eq(0)
        expect(invoice1.total_discounted_revenue).to eq(405)
      end
    end


    describe '#total_discounted_revenue' do
      it "returns the total discounted revenue for an invoice if a discount is applicable" do
        expect(@invoice1.total_discounted_revenue).to eq(530)
      end
    end

    describe '#total_discount' do
      it "return only the invoice items that should have a discount applied, ordered by biggest discount" do
        merchant1 = Merchant.create!(name: 'Merchant 1')
        merchant2 = Merchant.create!(name: 'Merchant 2')
        merchant3 = Merchant.create!(name: 'Merchant 3')

        discount1 = merchant1.discounts.create!(name: "discount1", discount_percentage: 10, quantity_threshold: 10)
        discount2 = merchant1.discounts.create!(name: "discount2", discount_percentage: 20, quantity_threshold: 15)

        discount3 = merchant2.discounts.create!(name: "discount3", discount_percentage: 30, quantity_threshold: 20)
        discount4 = merchant3.discounts.create!(name: "discount4", discount_percentage: 20, quantity_threshold: 10)

        customer1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')
        invoice1 = customer1.invoices.create!(status: 2, created_at: "2012-03-27 14:54:09")

        item1 = merchant1.items.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, status: 1)
        item2 = merchant1.items.create!(name: "Butterfly Clip", description: "This holds up your hair but in a clip", unit_price: 5)
        item3 = merchant2.items.create!(name: "Brush", description: "This takes out tangles", unit_price: 5)
        item4 = merchant3.items.create!(name: "Hair tie", description: "This holds up your hair", unit_price: 1)

        ii_1 = InvoiceItem.create!(invoice_id: invoice1.id, item_id: item1.id, quantity: 13, unit_price: 20, status: 2) # 10% discount / 260 / 26 / 234
        ii_3 = InvoiceItem.create!(invoice_id: invoice1.id, item_id: item2.id, quantity: 15, unit_price: 10, status: 0) # 20% discount / 150 / 30 / 120
        ii_2 = InvoiceItem.create!(invoice_id: invoice1.id, item_id: item3.id, quantity: 18, unit_price: 10, status: 1) # no discount
        ii_4 = InvoiceItem.create!(invoice_id: invoice1.id, item_id: item4.id, quantity: 15, unit_price: 15, status: 1) # 20% discount / 225 / 45 / 180
        # total = 101

        expect(invoice1.total_revenue).to eq(815)
        expect(invoice1.total_discount).to eq(101)
        expect(invoice1.total_discounted_revenue).to eq(714)
      end
    end
  end
end
