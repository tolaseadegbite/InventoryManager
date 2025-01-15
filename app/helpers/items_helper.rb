module ItemsHelper
  def category_link(item)
    if item.category.present?
      link_to item.category.name, category_path(item.category), class: "text-orange-500", data: { turbo_frame: "_top" }
    else
      'Not set'
    end
  end
end
