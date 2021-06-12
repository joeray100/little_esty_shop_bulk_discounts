require 'rails_helper'

RSpec.describe 'Discount Edit Page' do
  before :each do
    @merchant1 = Merchant.create!(name: 'Hair Care')
    @discount1 = @merchant1.discounts.create!(name: "10%", discount_percentage: 10, quantity_threshold: 10)
    @discount2 = @merchant1.discounts.create!(name: "15%", discount_percentage: 15, quantity_threshold: 15)
    @discount3 = @merchant1.discounts.create!(name: "20%", discount_percentage: 20, quantity_threshold: 20)

    visit edit_merchant_discount_path(@merchant1, @discount1)
  end

  it 'I can edit a bulk discount' do
    expect(current_path).to eq(edit_merchant_discount_path(@merchant1, @discount1))
    expect(page).to have_field('Name', with: "10%")
    expect(page).to have_field('Discount percentage', with: 10)
    expect(page).to have_field('Quantity threshold', with: 10)
    expect(page).to have_button('Update Discount')

    fill_in 'Name', with: '30%'
    fill_in 'Discount percentage', with: 30
    fill_in 'Quantity threshold', with: 20
    click_button 'Update Discount'

    expect(current_path).to eq(merchant_discount_path(@merchant1, @discount1))
    expect(page).to have_content("30%'s Page")
    expect(page).to have_content("Discount Percentage: 30")
    expect(page).to have_content("Quantity Threshold: 20")
  end

  it "I will recieve an error message if I don't properly update the form" do
    fill_in 'Name', with: ''
    fill_in 'Discount percentage', with: 10
    fill_in 'Quantity threshold', with: ''
    click_button 'Update Discount'

    expect(current_path).to eq(edit_merchant_discount_path(@merchant1, @discount1))

    expect(page).to have_content("Error: Name can't be blank, Quantity threshold can't be blank, and Quantity threshold is not a number")
  end
end
