# app/controllers/products_controller.rb
class ProductsController < ApplicationController
    skip_before_action :verify_authenticity_token
    def index
      products = Product.all
      render json: products
    end

    def create
      product = Product.create!(product_params)
      render json: product
    end

    private

    def product_params
      params.permit(:name, :price)
    end
  end
