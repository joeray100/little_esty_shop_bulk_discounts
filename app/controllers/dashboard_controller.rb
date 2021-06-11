class DashboardController < ApplicationController
  def index
    @merchant = Merchant.find(params[:merchant_id])
    @top_5_customers = Customer.top_customers
  end
end
