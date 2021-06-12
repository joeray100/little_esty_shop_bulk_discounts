require 'rails_helper'

RSpec.describe 'Discounts Index Page' do
  before :each do
    @merchant1 = Merchant.create!(name: 'Hair Care')
    @discount1 = @merchant1.discounts.create!(name: "10%", discount_percentage: 10, quantity_threshold: 10)
    @discount2 = @merchant1.discounts.create!(name: "15%", discount_percentage: 15, quantity_threshold: 15)
    @discount3 = @merchant1.discounts.create!(name: "20%", discount_percentage: 20, quantity_threshold: 20)

    visit merchant_discounts_path(@merchant1)
  end

  it 'I see all of my bulk discounts including their attributes' do
    expect(current_path).to eq(merchant_discounts_path(@merchant1))

    within("#discount-#{@discount1.id}") do
      expect(page).to have_content(@discount1.name)
      expect(page).to have_content(@discount1.discount_percentage)
      expect(page).to have_content(@discount1.quantity_threshold)

      expect(page).to_not have_content(@discount2.name)
    end

    within("#discount-#{@discount2.id}") do
      expect(page).to have_content(@discount2.name)
      expect(page).to have_content(@discount2.discount_percentage)
      expect(page).to have_content(@discount2.quantity_threshold)

      expect(page).to_not have_content(@discount3.name)
    end

    within("#discount-#{@discount3.id}") do
      expect(page).to have_content(@discount3.name)
      expect(page).to have_content(@discount3.discount_percentage)
      expect(page).to have_content(@discount3.quantity_threshold)

      expect(page).to_not have_content(@discount2.name)
    end
  end

  it "each bulk discount listed includes a link to its show page" do
    within("#discount-#{@discount1.id}") do
      expect(page).to have_link("#{@discount1.name}'s Show Page")
    end

    within("#discount-#{@discount2.id}") do
      expect(page).to have_link("#{@discount2.name}'s Show Page")
    end

    within("#discount-#{@discount3.id}") do
      expect(page).to have_link("#{@discount3.name}'s Show Page")
    end
  end

  it "I see a section called Upcoming Holidays that shows the name and date of the next 3 upcoming US holidays" do
    expect(page).to have_content('Upcoming Holidays')

    within(".holiday") do
      expect(page).to have_content("Independence Day, 2021-07-05")
      expect(page).to have_content("Labour Day, 2021-09-06")
      expect(page).to have_content("Columbus Day, 2021-10-11")
    end
  end

  it "the next 3 upcoming US holidays are listed in order" do
    expect('Independence Day').to appear_before('Columbus Day')
    expect('2021-07-05').to appear_before('2021-10-11')
  end

  it "I see a link to create a new discount" do
    expect(page).to have_link('Create Discount', href: new_merchant_discount_path(@merchant1) )
  end

  it "I can click a link to 'Delete Discount' and when I'm returned to the index page I no longer see that discount" do
    expect(current_path).to eq(merchant_discounts_path(@merchant1))

    within("#discount-#{@discount1.id}") do
      expect(page).to have_link('Delete Discount', href: merchant_discount_path(@merchant1, @discount1) )
      expect(page).to have_content(@discount1.name)
      click_link 'Delete Discount'
      expect(current_path).to eq(merchant_discounts_path(@merchant1))
    end

    expect(current_path).to eq(merchant_discounts_path(@merchant1))
    expect(page).to_not have_content(@discount1.name)
  end
end
