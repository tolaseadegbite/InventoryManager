module ItemsHelper
  include Pagy::Frontend
  
  def category_link(item)
    if item.category.present?
      link_to item.category.name, category_path(item.category), 
        class: "text-orange-500", 
        data: { turbo_frame: "_top" }
    else
      "Not set"
    end
  end

  def display_effective_threshold(inventory, item)
    if item.stock_threshold.zero?
      "#{inventory.global_stock_threshold} (Global)"
    else
      "#{item.stock_threshold} (Custom)"
    end
  end
end