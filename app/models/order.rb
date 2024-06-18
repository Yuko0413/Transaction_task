class Order < ApplicationRecord
  belongs_to :user
  has_many :ordered_lists
  has_many :items, through: :ordered_lists
  accepts_nested_attributes_for :ordered_lists

  def update_total_quantity
    ActiveRecord::Base.transaction do
      self.ordered_lists.each do |line_item|
        item = Item.lock.find(line_item.item_id) # 悲観的ロックを使用
        item.total_quantity += line_item.quantity
        item.save!
      end
    end
  end
end
