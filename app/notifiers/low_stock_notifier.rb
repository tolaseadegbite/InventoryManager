class LowStockNotifier < Noticed::Event
  notification_methods do
    def message
      item = Item.find_by(id: params[:record_id])
      "Low stock alert: #{item&.name} has #{params[:quantity]} items remaining (Threshold: #{params[:threshold]})"
    end

    def url
      Rails.application.routes.url_helpers.item_path(params[:record_id])
    end
  end
end