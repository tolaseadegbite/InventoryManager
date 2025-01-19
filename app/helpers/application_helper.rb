module ApplicationHelper
    # returns full title if present, else returns base title
  def full_title(page_title="")
    base_title = "AFSO Inventory"
    if page_title.blank?
        base_title
    else
        "#{page_title} | #{base_title}"
    end
  end

  def classes_for_flash(flash_type)
    case flash_type.to_sym
    when :error
      "bg-red-100 text-red-700"
    else
      "bg-blue-100 text-blue-700"
    end
  end

  def render_turbo_stream_flash_messages
    turbo_stream.prepend "flash", partial: "shared/flash"
  end
end
