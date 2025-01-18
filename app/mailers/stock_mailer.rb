class StockMailer < ApplicationMailer
  def low_stock_alert(notification)
    @notification = notification
    @item = Item.find_by(id: notification.params[:record_id])
    @recipient = notification.recipient

    if @item
      mail(
        to: @recipient.email,
        subject: "Critical Low Stock Alert: #{@item.name}"
      )
    else
      Rails.logger.warn "Low stock alert skipped: Item not found for notification #{notification.id}"
    end
  end
end
