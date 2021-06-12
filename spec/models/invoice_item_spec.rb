require 'rails_helper'

RSpec.describe InvoiceItem, type: :model do
  describe "validations" do
    it { should validate_presence_of :invoice_id }
    it { should validate_presence_of :item_id }
    it { should validate_presence_of :quantity }
    it { should validate_presence_of :unit_price }
    it { should validate_presence_of :status }
  end

  describe "relationships" do
    it { should belong_to :invoice }
    it { should belong_to :item }
    it { should have_one(:merchant) }
    it { should have_many(:discounts).through(:merchant) }
  end

  describe 'instance methods' do
    describe 'testing bulk discount examples' do

      it "No bulk discounts should be applied." do
        merchantA = Merchant.create!(name: 'Merchant A')
        itemA = merchantA.items.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10)
        itemB = merchantA.items.create!(name: "Conditioner", description: "This makes your hair shiny", unit_price: 8)

        discountA = merchantA.discounts.create!(name: "20%", discount_percentage: 20, quantity_threshold: 10)

        customerA = Customer.create!(first_name: 'Joey', last_name: 'Smith')
        invoiceA = customerA.invoices.create!(status: 1)

        ii_A = InvoiceItem.create!(quantity: 5, unit_price: 10, status: 1, item: itemA, invoice: invoiceA)
        ii_B = InvoiceItem.create!(quantity: 5, unit_price: 10, status: 1, item: itemB, invoice: invoiceA)

        expect(ii_A.greatest_discount).to eq(nil)
        expect(ii_B.greatest_discount).to eq(nil)
      end

      it "Item A should be discounted at 20% off. Item B should not be discounted." do
        merchantA = Merchant.create!(name: 'Merchant A')
        itemA = merchantA.items.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10)
        itemB = merchantA.items.create!(name: "Conditioner", description: "This makes your hair shiny", unit_price: 8)

        discountA = merchantA.discounts.create!(name: "20%", discount_percentage: 20, quantity_threshold: 10)

        customerA = Customer.create!(first_name: 'Joey', last_name: 'Smith')
        invoiceA = customerA.invoices.create!(status: 1)

        ii_A = InvoiceItem.create!(quantity: 10, unit_price: 10, status: 1, item: itemA, invoice: invoiceA)
        ii_B = InvoiceItem.create!(quantity: 5, unit_price: 10, status: 1, item: itemB, invoice: invoiceA)

        expect(ii_A.greatest_discount).to eq(discountA.id)
        expect(ii_B.greatest_discount).to eq(nil)
      end

      it "Item A should discounted at 20% off, and Item B should discounted at 30% off." do
        merchantA = Merchant.create!(name: 'Merchant A')
        itemA = merchantA.items.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10)
        itemB = merchantA.items.create!(name: "Conditioner", description: "This makes your hair shiny", unit_price: 8)

        discountA = merchantA.discounts.create!(name: "20%", discount_percentage: 20, quantity_threshold: 10)
        discountB = merchantA.discounts.create!(name: "30%", discount_percentage: 30, quantity_threshold: 15)

        customerA = Customer.create!(first_name: 'Joey', last_name: 'Smith')
        invoiceA = customerA.invoices.create!(status: 1)

        ii_A = InvoiceItem.create!(quantity: 12, unit_price: 10, status: 1, item: itemA, invoice: invoiceA)
        ii_B = InvoiceItem.create!(quantity: 15, unit_price: 10, status: 1, item: itemB, invoice: invoiceA)

        expect(ii_A.greatest_discount).to eq(discountA.id)
        expect(ii_B.greatest_discount).to eq(discountB.id)
      end

      it "Both Item A and Item B should discounted at 20% off. Additionally, there is no scenario where Bulk Discount B can ever be applied." do
        merchantA = Merchant.create!(name: 'Merchant A')
        itemA = merchantA.items.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10)
        itemB = merchantA.items.create!(name: "Conditioner", description: "This makes your hair shiny", unit_price: 8)

        discountA = merchantA.discounts.create!(name: "20%", discount_percentage: 20, quantity_threshold: 10)
        discountB = merchantA.discounts.create!(name: "15%", discount_percentage: 15, quantity_threshold: 15)

        customerA = Customer.create!(first_name: 'Joey', last_name: 'Smith')
        invoiceA = customerA.invoices.create!(status: 1)

        ii_A = InvoiceItem.create!(quantity: 12, unit_price: 10, status: 1, item: itemA, invoice: invoiceA)
        ii_B = InvoiceItem.create!(quantity: 15, unit_price: 10, status: 1, item: itemB, invoice: invoiceA)

        expect(ii_A.greatest_discount).to eq(discountA.id)
        expect(ii_B.greatest_discount).to eq(discountA.id)
      end

      it "Item A1 should discounted at 20% off, and Item A2 should discounted at 30% off. Item B should not be discounted." do
        merchantA = Merchant.create!(name: 'Merchant A')
        itemA1 = merchantA.items.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10)
        itemA2 = merchantA.items.create!(name: "Conditioner", description: "This makes your hair shiny", unit_price: 8)

        discountA = merchantA.discounts.create!(name: "20%", discount_percentage: 20, quantity_threshold: 10)
        discountB = merchantA.discounts.create!(name: "30%", discount_percentage: 30, quantity_threshold: 15)

        merchantB = Merchant.create!(name: 'Merchant A')
        itemB = merchantB.items.create!(name: "Brush", description: "This takes out tangles", unit_price: 5)
        # has no discounts

        customerA = Customer.create!(first_name: 'Joey', last_name: 'Smith')
        invoiceA = customerA.invoices.create!(status: 1)

        ii_A1 = InvoiceItem.create!(quantity: 12, unit_price: 10, status: 1, item: itemA1, invoice: invoiceA)
        ii_A2 = InvoiceItem.create!(quantity: 15, unit_price: 10, status: 1, item: itemA2, invoice: invoiceA)
        ii_B = InvoiceItem.create!(quantity: 15, unit_price: 15, status: 1, item: itemB, invoice: invoiceA)

        expect(ii_A1.greatest_discount).to eq(discountA.id)
        expect(ii_A2.greatest_discount).to eq(discountB.id)
        expect(ii_B.greatest_discount).to eq(nil)
      end

      describe 'class methods' do
        describe '.incomplete_invoices' do
          it "returns invoices that have not yet shipped" do
            merchant1 = Merchant.create!(name: 'Hair Care')
            item_1 = merchant1.items.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10)
            item_2 = merchant1.items.create!(name: "Conditioner", description: "This makes your hair shiny", unit_price: 8)
            item_3 = merchant1.items.create!(name: "Brush", description: "This takes out tangles", unit_price: 5)

            customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')
            invoice_1 = customer_1.invoices.create!(status: 2, created_at: "2012-02-27 14:54:09")
            invoice_2 = customer_1.invoices.create!(status: 2, created_at: "2012-03-28 14:54:09")
            invoice_3 = customer_1.invoices.create!(status: 2, created_at: "2012-04-27 14:54:09")

            ii_1 = InvoiceItem.create!(invoice_id: invoice_1.id, item_id: item_1.id, quantity: 10, unit_price: 10, status: 0)
            ii_2 = InvoiceItem.create!(invoice_id: invoice_2.id, item_id: item_1.id, quantity: 1, unit_price: 10, status: 2)
            ii_3 = InvoiceItem.create!(invoice_id: invoice_3.id, item_id: item_2.id, quantity: 2, unit_price: 8, status: 2)

            expect(InvoiceItem.incomplete_invoices).to eq([invoice_1])
          end
        end
      end
    end
  end
end
