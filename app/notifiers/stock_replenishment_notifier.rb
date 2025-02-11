class StockReplenishmentNotifier < Noticed::Event
  notification_methods do
    def message
      item = Item.find_by(id: params[:record_id])
      "<b>Stock Replenished</b> for <b>Inventory ##{params[:inventory_name]}</b>: #{item&.name} now has <b>#{params[:quantity]} items</b> (Threshold: <b>#{params[:threshold]}</b>)".html_safe
    end

    def url
      Rails.application.routes.url_helpers.inventory_item_path(params[:inventory_id], params[:record_id])
    end
  end
end