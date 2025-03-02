module ApplicationHelper
  include InventoriesHelper
  # include ActivityLogsHelper

  # returns full title if present, else returns base title
  def full_title(page_title="")
    base_title = "Inventorify"
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

  def delete_modal(resource, path)
    render partial: 'shared/delete_modal', locals: {
      resource: resource,
      path: path
    }
  end

  def action_type_badge_class(action_type)
    case action_type.to_s
    when 'add'
      'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-300'
    when 'remove'
      'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-300'
    when 'adjust'
      'bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-300'
    else
      'bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300'
    end
  end

  def formatted_date(date = Date.today)
    date.strftime("#{date.day.ordinalize} %B, %Y")
  end
end
