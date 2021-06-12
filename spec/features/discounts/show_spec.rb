require 'rails_helper'

RSpec.describe 'Discount Show Page' do
  before :each do
    @merchant1 = Merchant.create!(name: 'Hair Care')
    @discount1 = @merchant1.discounts.create!(name: "10%", discount_percentage: 10, quantity_threshold: 10)
    @discount2 = @merchant1.discounts.create!(name: "15%", discount_percentage: 15, quantity_threshold: 15)
    @discount3 = @merchant1.discounts.create!(name: "20%", discount_percentage: 20, quantity_threshold: 20)

    visit merchant_discount_path(@merchant1, @discount1)
  end

  it "I see the bulk discount's attributes" do
    expect(current_path).to eq(merchant_discount_path(@merchant1, @discount1))

    expect(page).to have_content(@discount1.name)
    expect(page).to have_content(@discount1.discount_percentage)
    expect(page).to have_content(@discount1.quantity_threshold)
  end

  it "I can edit my bulk discount via the link" do
    expect(current_path).to eq(merchant_discount_path(@merchant1, @discount1))
    expect(page).to have_link('Edit Discount', href: edit_merchant_discount_path(@merchant1, @discount1))
  end
end
