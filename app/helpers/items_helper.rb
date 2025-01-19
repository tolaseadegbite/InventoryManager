module ItemsHelper
  def category_link(item)
    if item.category.present?
      link_to item.category.name, category_path(item.category), class: "text-orange-500", data: { turbo_frame: "_top" }
    else
      'Not set'
    end
  end

  def low_stock?(item)
    return false unless item.quantity.present?

    # Determine the effective threshold dynamically
    effective_threshold = [item.stock_threshold, item.account.global_stock_threshold].max

    item.quantity <= effective_threshold
  end

  def display_effective_threshold(item)
    if item.stock_threshold&.positive?
      "#{item.stock_threshold} (Item Threshold)"
    else
      "#{item.account.global_stock_threshold} (Global Threshold)"
    end
  end
end
