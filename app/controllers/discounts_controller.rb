class DiscountsController < ApplicationController
  before_action :find_merchant_and_discount, only: [:show, :edit, :update]
  before_action :find_merchant, except: [:show, :edit, :update]

  def index
    @upcoming_holidays = Holiday.new.upcoming_holidays
    @discounts = @merchant.discounts
  end

  def show
  end

  def edit
  end

  def update
    if @discount.update(discount_params)
      redirect_to merchant_discount_path(@merchant, @discount)
    else
      flash[:notice] = "Error: #{@discount.errors.full_messages.to_sentence}"
      redirect_to edit_merchant_discount_path(@merchant, @discount)
    end
  end

  def new
    @discount = @merchant.discounts.new
  end

  def create
    discount = @merchant.discounts.create(discount_params)

    if discount.save
      redirect_to merchant_discounts_path(@merchant)
    else
      flash[:notice] = "Error: #{discount.errors.full_messages.to_sentence}"
      redirect_to new_merchant_discount_path(@merchant)
    end
  end

  def destroy
    discount = Discount.find(params[:id])
    @merchant.discounts.delete(discount)

    redirect_to merchant_discounts_path(@merchant)
  end

  private
  def discount_params
    params.require(:discount).permit(:name, :discount_percentage, :quantity_threshold)
  end

  def find_merchant_and_discount
    @merchant = Merchant.find(params[:merchant_id])
    @discount = @merchant.discounts.find(params[:id])
  end

  def find_merchant
    @merchant = Merchant.find(params[:merchant_id])
  end
end
