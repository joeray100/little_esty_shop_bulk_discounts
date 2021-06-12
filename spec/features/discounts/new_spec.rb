require 'rails_helper'

RSpec.describe '' do
  before :each do
    @merchant1 = Merchant.create!(name: 'Hair Care')
    @discount1 = @merchant1.discounts.create!(name: "10%", discount_percentage: 10, quantity_threshold: 10)

    visit new_merchant_discount_path(@merchant1)
  end

  it 'I can create a new merchant bulk discount by filling out a form' do
    expect(current_path).to eq(new_merchant_discount_path(@merchant1))

    fill_in 'Name', with: 'holiday sale'
    fill_in 'Discount percentage', with: 20
    fill_in 'Quantity threshold', with: 10
    click_button 'Create Discount'

    expect(current_path).to eq(merchant_discounts_path(@merchant1))
    expect(page).to have_content('holiday sale')
  end

  it "displays error message when new discount form not properly filled out" do
    fill_in 'Name', with: ''
    fill_in 'Discount percentage', with: ''
    fill_in 'Quantity threshold', with: 10
    click_button 'Create Discount'

    expect(current_path).to eq(new_merchant_discount_path(@merchant1))

    expect(page).to have_content("Error: Name can't be blank, Discount percentage can't be blank, and Discount percentage is not a number")
  end
end
