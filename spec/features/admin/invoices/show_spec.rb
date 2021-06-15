require 'rails_helper'

describe 'Admin Invoices Index Page' do
  before :each do
    @m1 = Merchant.create!(name: 'Merchant 1')
    @discount1 = @m1.discounts.create!(name: "discount1", discount_percentage: 10, quantity_threshold: 10)
    @c1 = Customer.create!(first_name: 'Yo', last_name: 'Yoz', address: '123 Heyyo', city: 'Whoville', state: 'CO', zip: 12345)
    @c2 = Customer.create!(first_name: 'Hey', last_name: 'Heyz')

    @i1 = Invoice.create!(customer_id: @c1.id, status: 2, created_at: '2012-03-25 09:54:09')
    @i2 = Invoice.create!(customer_id: @c2.id, status: 1, created_at: '2012-03-25 09:30:09')

    @item_1 = Item.create!(name: 'test', description: 'lalala', unit_price: 6, merchant_id: @m1.id)
    @item_2 = Item.create!(name: 'rest', description: 'dont test me', unit_price: 12, merchant_id: @m1.id)

    @ii_1 = InvoiceItem.create!(invoice_id: @i1.id, item_id: @item_1.id, quantity: 12, unit_price: 2, status: 0)
    @ii_2 = InvoiceItem.create!(invoice_id: @i1.id, item_id: @item_2.id, quantity: 6, unit_price: 1, status: 1)
    @ii_3 = InvoiceItem.create!(invoice_id: @i2.id, item_id: @item_2.id, quantity: 87, unit_price: 12, status: 2)

    visit admin_invoice_path(@i1)
  end

  it 'should display the id, status and created_at' do
    expect(page).to have_content("Invoice ##{@i1.id}")
    expect(page).to have_content("Created on: #{@i1.created_at.strftime("%A, %B %d, %Y")}")

    expect(page).to_not have_content("Invoice ##{@i2.id}")
  end

  it 'should display the customers name and shipping address' do
    expect(page).to have_content("#{@c1.first_name} #{@c1.last_name}")
    expect(page).to have_content(@c1.address)
    expect(page).to have_content("#{@c1.city}, #{@c1.state} #{@c1.zip}")

    expect(page).to_not have_content("#{@c2.first_name} #{@c2.last_name}")
  end

  it 'should display all the items on the invoice' do
    expect(page).to have_content(@item_1.name)
    expect(page).to have_content(@item_2.name)

    expect(page).to have_content(@ii_1.quantity)
    expect(page).to have_content(@ii_2.quantity)

    expect(page).to have_content("$#{@ii_1.unit_price}")
    expect(page).to have_content("$#{@ii_2.unit_price}")

    expect(page).to have_content(@ii_1.status)
    expect(page).to have_content(@ii_2.status)

    expect(page).to_not have_content(@ii_3.quantity)
    expect(page).to_not have_content("$#{@ii_3.unit_price}")
    expect(page).to_not have_content(@ii_3.status)
  end

  it 'should display the total revenue the invoice will generate' do
    expect(page).to have_content("Total Revenue: $#{@i1.total_revenue}")

    expect(page).to_not have_content(@i2.total_revenue)
  end

  it 'should have status as a select field that updates the invoices status' do
    within("#status-update-#{@i1.id}") do
      select('cancelled', :from => 'invoice[status]')
      expect(page).to have_button('Update Invoice')
      click_button 'Update Invoice'

      expect(current_path).to eq(admin_invoice_path(@i1))
      expect(@i1.status).to eq('complete')
    end
  end

  it 'I see the total revenue from this invoice (not including discounts)' do
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
    # total revenue = 405
    visit admin_invoice_path(invoice1)

    expect(invoice1.total_revenue).to eq(405)

    within "#admin-total-revenue" do
      expect(current_path).to eq(admin_invoice_path(invoice1))
      expect(page).to have_content(invoice1.total_revenue)
    end
  end

  it 'I see the total discounted revenue from this invoice' do
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
    visit admin_invoice_path(invoice1)

    expect(invoice1.total_revenue).to eq(815)
    expect(invoice1.total_discount).to eq(101)
    expect(invoice1.total_discounted_revenue).to eq(714)

    within "#admin-total-discounted-revenue" do
      expect(current_path).to eq(admin_invoice_path(invoice1))
      expect(page).to have_content(invoice1.total_discounted_revenue)
    end
  end
end
