class LowStockNotifier < Noticed::Event
  # deliver_by :email do |config|
  #   config.mailer = "StockMailer"
  #   config.method = :low_stock_alert
  #   config.if = -> {
  #     item = Item.find_by(id: params[:record_id]) # Load the record here
  #     return false unless item.present?

  #     threshold = [ item.stock_threshold, item.user.global_stock_threshold ].max
  #     item.quantity <= (threshold * 0.5)
  #   }
  # end

  # required_params :record_id, :record, :quantity, :threshold

  notification_methods do
    def message
      item = Item.find_by(id: params[:record_id]) # Load the record here
      "Low stock alert: #{item&.name} has #{params[:quantity]} items remaining (Threshold: #{params[:threshold]})"
    end

    def url
      Rails.application.routes.url_helpers.item_path(params[:record_id])
    end
  end
end
