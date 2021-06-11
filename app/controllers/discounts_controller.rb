class DiscountsController < ApplicationController
  before_action :find_merchant_and_discount, only: [:show, :edit, :update]
  before_action :find_merchant, except: [:show, :edit, :update]

  def index
    @discounts = @merchant.discounts
  end

  def find_merchant_and_discount
    @merchant = Merchant.find(params[:merchant_id])
    @discount = @merchant.discounts.find(params[:id])
  end

  def find_merchant
    @merchant = Merchant.find(params[:merchant_id])
  end
end
