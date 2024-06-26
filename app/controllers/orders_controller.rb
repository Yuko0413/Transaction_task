class OrdersController < ApplicationController
  def index
    @orders = Order.where(user_id: current_user.id).order(created_at: :desc)
  end

  def new
    @order = Order.new
    @order.ordered_lists.build
    @items = Item.all.order(:created_at)
  end

  def create
    ActiveRecord::Base.transaction do
      @order = current_user.orders.build(order_params)

      if @order.save
        @order.ordered_lists.each do |ordered_list|
          item = Item.lock.find(ordered_list.item_id) # 悲観的ロックを使用
          item.total_quantity += ordered_list.quantity
          item.save!
        end
        redirect_to orders_path, notice: '注文が正常に作成されました。'
      else
        raise ActiveRecord::Rollback
      end
    end
  rescue ActiveRecord::RecordInvalid, ActiveRecord::Rollback
    flash[:error] = "注文の処理に失敗しました。"
    redirect_to new_order_path
  end

 
