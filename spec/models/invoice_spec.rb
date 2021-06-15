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

  describe "instance methods" do

    describe 'I will be testing all three of the invoice model methods using the 5 discount example stories' do

      it "No bulk discounts should be applied." do
        merchant1 = Merchant.create!(name: 'Merchant 1')
        discount1 = merchant1.discounts.create!(name: "discount 1", discount_percentage: 10, quantity_threshold: 10)
        discount2 = merchant1.discounts.create!(name: "discount 2", discount_percentage: 20, quantity_threshold: 10)
        discount3 = merchant1.discounts.create!(name: "discount 3", discount_percentage: 30, quantity_threshold: 20)
        discount4 = merchant1.discounts.create!(name: "discount 4", discount_percentage: 50, quantity_threshold: 30)
        item1 = merchant1.items.create!(name: "Shampoo", description: "This washes your hair", unit_price: 20)
        item2 = merchant1.items.create!(name: "Butterfly Clip", description: "This holds up your hair but in a clip", unit_price: 10)
        item3 = merchant1.items.create!(name: "Brush", description: "This takes out tangles", unit_price: 15)
        #  merchant 2 has an item but no discounts
        merchant2 = Merchant.create!(name: 'Merchant 2')
        item4 = merchant2.items.create!(name: "Hair tie", description: "This holds up your hair", unit_price: 5)

        customer1 = Customer.create!(first_name: 'Joey', last_name: "'Smells like spicy pickles' McMuffinPants")
        customer2 = Customer.create!(first_name: 'Sarah', last_name: "'Ankle Breaker' Jones")
        invoice1 = customer1.invoices.create!(status: 2, created_at: "2012-03-27 14:54:09") # TR = 150
        invoice2 = customer1.invoices.create!(status: 2, created_at: "2012-04-27 14:54:09") # TR = 375 / TDR = 315
        invoice3 = customer1.invoices.create!(status: 2, created_at: "2012-05-27 14:54:09") # TR = 350 / TDR = 260
        invoice4 = customer2.invoices.create!(status: 2, created_at: "2012-06-27 14:54:09") # TR = 300 / TDR = 240
        invoice5 = customer2.invoices.create!(status: 2, created_at: "2012-07-27 14:54:09") # TR = 300 / TDR = 210
        # ---------------------------------------EXAMPLE 1---------------------------------------------------------------------
        ii_1 = InvoiceItem.create!(invoice_id: invoice1.id, item_id: item1.id, quantity: 5, unit_price: 20, status: 2) # no discount
        ii_2 = InvoiceItem.create!(invoice_id: invoice1.id, item_id: item2.id, quantity: 5, unit_price: 10, status: 2) # no discount

        expect(invoice1.total_revenue).to eq(150)
        expect(invoice1.total_discount).to eq(0)
        expect(invoice1.total_discounted_revenue).to eq(150)
      end

      it " Item 1 should be discounted at 20% off. Item 3 should not be discounted." do
        merchant1 = Merchant.create!(name: 'Merchant 1')
        discount1 = merchant1.discounts.create!(name: "discount 1", discount_percentage: 10, quantity_threshold: 10)
        discount2 = merchant1.discounts.create!(name: "discount 2", discount_percentage: 20, quantity_threshold: 10)
        discount3 = merchant1.discounts.create!(name: "discount 3", discount_percentage: 30, quantity_threshold: 20)
        discount4 = merchant1.discounts.create!(name: "discount 4", discount_percentage: 50, quantity_threshold: 30)
        item1 = merchant1.items.create!(name: "Shampoo", description: "This washes your hair", unit_price: 20)
        item2 = merchant1.items.create!(name: "Butterfly Clip", description: "This holds up your hair but in a clip", unit_price: 10)
        item3 = merchant1.items.create!(name: "Brush", description: "This takes out tangles", unit_price: 15)
        #  merchant 2 has an item but no discounts
        merchant2 = Merchant.create!(name: 'Merchant 2')
        item4 = merchant2.items.create!(name: "Hair tie", description: "This holds up your hair", unit_price: 5)

        customer1 = Customer.create!(first_name: 'Joey', last_name: "'Smells like spicy pickles' McMuffinPants")
        customer2 = Customer.create!(first_name: 'Sarah', last_name: "'Ankle Breaker' Jones")
        invoice1 = customer1.invoices.create!(status: 2, created_at: "2012-03-27 14:54:09") # TR = 150
        invoice2 = customer1.invoices.create!(status: 2, created_at: "2012-04-27 14:54:09") # TR = 375 / TDR = 315
        invoice3 = customer1.invoices.create!(status: 2, created_at: "2012-05-27 14:54:09") # TR = 350 / TDR = 260
        invoice4 = customer2.invoices.create!(status: 2, created_at: "2012-06-27 14:54:09") # TR = 300 / TDR = 240
        invoice5 = customer2.invoices.create!(status: 2, created_at: "2012-07-27 14:54:09") # TR = 300 / TDR = 210
        # ----------------------------------------EXAMPLE 2--------------------------------------------------------------------
        ii_3 = InvoiceItem.create!(invoice_id: invoice2.id, item_id: item3.id, quantity: 5, unit_price: 15, status: 2) # no discount
        ii_4 = InvoiceItem.create!(invoice_id: invoice2.id, item_id: item1.id, quantity: 15, unit_price: 20, status: 2) # 20% discount

        expect(invoice2.total_revenue).to eq(375)
        expect(invoice2.total_discount).to eq(60)
        expect(invoice2.total_discounted_revenue).to eq(315)
      end

      it "Item 3 should discounted at 20% off, and Item 2 should discounted at 30% off." do
        merchant1 = Merchant.create!(name: 'Merchant 1')
        discount1 = merchant1.discounts.create!(name: "discount 1", discount_percentage: 10, quantity_threshold: 10)
        discount2 = merchant1.discounts.create!(name: "discount 2", discount_percentage: 20, quantity_threshold: 10)
        discount3 = merchant1.discounts.create!(name: "discount 3", discount_percentage: 30, quantity_threshold: 20)
        discount4 = merchant1.discounts.create!(name: "discount 4", discount_percentage: 50, quantity_threshold: 30)
        item1 = merchant1.items.create!(name: "Shampoo", description: "This washes your hair", unit_price: 20)
        item2 = merchant1.items.create!(name: "Butterfly Clip", description: "This holds up your hair but in a clip", unit_price: 10)
        item3 = merchant1.items.create!(name: "Brush", description: "This takes out tangles", unit_price: 15)
        #  merchant 2 has an item but no discounts
        merchant2 = Merchant.create!(name: 'Merchant 2')
        item4 = merchant2.items.create!(name: "Hair tie", description: "This holds up your hair", unit_price: 5)

        customer1 = Customer.create!(first_name: 'Joey', last_name: "'Smells like spicy pickles' McMuffinPants")
        customer2 = Customer.create!(first_name: 'Sarah', last_name: "'Ankle Breaker' Jones")
        invoice1 = customer1.invoices.create!(status: 2, created_at: "2012-03-27 14:54:09") # TR = 150
        invoice2 = customer1.invoices.create!(status: 2, created_at: "2012-04-27 14:54:09") # TR = 375 / TDR = 315
        invoice3 = customer1.invoices.create!(status: 2, created_at: "2012-05-27 14:54:09") # TR = 350 / TDR = 260
        invoice4 = customer2.invoices.create!(status: 2, created_at: "2012-06-27 14:54:09") # TR = 300 / TDR = 240
        invoice5 = customer2.invoices.create!(status: 2, created_at: "2012-07-27 14:54:09") # TR = 300 / TDR = 210
        # --------------------------------------EXAMPLE 3----------------------------------------------------------------------
        ii_5 = InvoiceItem.create!(invoice_id: invoice3.id, item_id: item3.id, quantity: 10, unit_price: 15, status: 2) # 20% discount
        ii_6 = InvoiceItem.create!(invoice_id: invoice3.id, item_id: item2.id, quantity: 20, unit_price: 10, status: 2) # 30% discount

        expect(invoice3.total_revenue).to eq(350)
        expect(invoice3.total_discount).to eq(90)
        expect(invoice3.total_discounted_revenue).to eq(260)
      end

      it "Both Item 1 and Item 2 should discounted at 20% off. Additionally, there is no scenario where Bulk Discount 1 can ever be applied." do
        merchant1 = Merchant.create!(name: 'Merchant 1')
        discount1 = merchant1.discounts.create!(name: "discount 1", discount_percentage: 10, quantity_threshold: 10)
        discount2 = merchant1.discounts.create!(name: "discount 2", discount_percentage: 20, quantity_threshold: 10)
        discount3 = merchant1.discounts.create!(name: "discount 3", discount_percentage: 30, quantity_threshold: 20)
        discount4 = merchant1.discounts.create!(name: "discount 4", discount_percentage: 50, quantity_threshold: 30)
        item1 = merchant1.items.create!(name: "Shampoo", description: "This washes your hair", unit_price: 20)
        item2 = merchant1.items.create!(name: "Butterfly Clip", description: "This holds up your hair but in a clip", unit_price: 10)
        item3 = merchant1.items.create!(name: "Brush", description: "This takes out tangles", unit_price: 15)
        #  merchant 2 has an item but no discounts
        merchant2 = Merchant.create!(name: 'Merchant 2')
        item4 = merchant2.items.create!(name: "Hair tie", description: "This holds up your hair", unit_price: 5)

        customer1 = Customer.create!(first_name: 'Joey', last_name: "'Smells like spicy pickles' McMuffinPants")
        customer2 = Customer.create!(first_name: 'Sarah', last_name: "'Ankle Breaker' Jones")
        invoice1 = customer1.invoices.create!(status: 2, created_at: "2012-03-27 14:54:09") # TR = 150
        invoice2 = customer1.invoices.create!(status: 2, created_at: "2012-04-27 14:54:09") # TR = 375 / TDR = 315
        invoice3 = customer1.invoices.create!(status: 2, created_at: "2012-05-27 14:54:09") # TR = 350 / TDR = 260
        invoice4 = customer2.invoices.create!(status: 2, created_at: "2012-06-27 14:54:09") # TR = 300 / TDR = 240
        invoice5 = customer2.invoices.create!(status: 2, created_at: "2012-07-27 14:54:09") # TR = 300 / TDR = 210
        # ---------------------------------------EXAMPLE 4---------------------------------------------------------------------
        ii_7 = InvoiceItem.create!(invoice_id: invoice4.id, item_id: item2.id, quantity: 10, unit_price: 10, status: 2) # 20% discount
        ii_8 = InvoiceItem.create!(invoice_id: invoice4.id, item_id: item1.id, quantity: 10, unit_price: 20, status: 2) # 20% discount

        expect(invoice4.total_revenue).to eq(300)
        expect(invoice4.total_discount).to eq(60)
        expect(invoice4.total_discounted_revenue).to eq(240)
      end

      it "Item 3 should discounted at 30% off, and Item 4 should not be discounted as the merchant it belongs to has not discounts." do
        merchant1 = Merchant.create!(name: 'Merchant 1')
        discount1 = merchant1.discounts.create!(name: "discount 1", discount_percentage: 10, quantity_threshold: 10)
        discount2 = merchant1.discounts.create!(name: "discount 2", discount_percentage: 20, quantity_threshold: 10)
        discount3 = merchant1.discounts.create!(name: "discount 3", discount_percentage: 30, quantity_threshold: 20)
        discount4 = merchant1.discounts.create!(name: "discount 4", discount_percentage: 50, quantity_threshold: 30)
        item1 = merchant1.items.create!(name: "Shampoo", description: "This washes your hair", unit_price: 20)
        item2 = merchant1.items.create!(name: "Butterfly Clip", description: "This holds up your hair but in a clip", unit_price: 10)
        item3 = merchant1.items.create!(name: "Brush", description: "This takes out tangles", unit_price: 15)
        #  merchant 2 has an item but no discounts
        merchant2 = Merchant.create!(name: 'Merchant 2')
        item4 = merchant2.items.create!(name: "Hair tie", description: "This holds up your hair", unit_price: 5)

        customer1 = Customer.create!(first_name: 'Joey', last_name: "'Smells like spicy pickles' McMuffinPants")
        customer2 = Customer.create!(first_name: 'Sarah', last_name: "'Ankle Breaker' Jones")
        invoice1 = customer1.invoices.create!(status: 2, created_at: "2012-03-27 14:54:09") # TR = 150
        invoice2 = customer1.invoices.create!(status: 2, created_at: "2012-04-27 14:54:09") # TR = 375 / TDR = 315
        invoice3 = customer1.invoices.create!(status: 2, created_at: "2012-05-27 14:54:09") # TR = 350 / TDR = 260
        invoice4 = customer2.invoices.create!(status: 2, created_at: "2012-06-27 14:54:09") # TR = 300 / TDR = 240
        invoice5 = customer2.invoices.create!(status: 2, created_at: "2012-07-27 14:54:09") # TR = 300 / TDR = 210
        # ---------------------------------------EXAMPLE 5---------------------------------------------------------------------
        ii_9 = InvoiceItem.create!(invoice_id: invoice5.id, item_id: item3.id, quantity: 20, unit_price: 15, status: 2) # 30% discount
        # ii 10 should not be on invoice 5 for merchant 1 and same for merchant 2
        ii_10 = InvoiceItem.create!(invoice_id: invoice5.id, item_id: item4.id, quantity: 15, unit_price: 5, status: 2) # no discount, merchant2 has none

        expect(invoice5.total_revenue).to eq(300)
        expect(invoice5.total_discount).to eq(90)
        expect(invoice5.total_discounted_revenue).to eq(210)
      end
    end
  end
end
