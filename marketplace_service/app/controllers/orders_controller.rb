class OrdersController < ApplicationController
    def buy
      tenant = params[:tenant]
      product_id = params[:product_id]
  
      result = RabbitPublisher.buy_product_from_tenant(tenant, product_id)
  
      if result == "payment processed"
        render json: { status: "success", message: "Product purchased successfully" }
      else
        render json: { status: "error", message: "Purchase failed" }, status: :unprocessable_entity
      end
    end
  end
  