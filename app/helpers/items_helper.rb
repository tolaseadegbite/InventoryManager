module ItemsHelper
  def category_link(item)
    if item.category.present?
      link_to item.category.name, category_path(item.category), class: "text-orange-500", data: { turbo_frame: "_top" }
    else
      "Not set"
    end
  end

  def low_stock?(item)
    # Return false if item or its quantity is not present
    return false unless item&.quantity.present?

    # Determine the effective threshold dynamically
    effective_threshold = [
      item.stock_threshold.presence || 0,
      item.account.global_stock_threshold.presence || 0
    ].max

    # Return false if effective threshold is zero (no thresholds defined)
    return false if effective_threshold.zero?

    # Compare quantity with the effective threshold
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
