module InvoiceHelper
  def amount_off(invoice)
    return unless invoice.discount.present?
    coupon = invoice.discount.coupon
    return coupon.amount_off / 100.0 if coupon.amount_off.present?
    return ((invoice.subtotal / 100.0) * (coupon.percent_off / 100.0)).round(2) if coupon.present?
  end
  
  def off_message(invoice)
    return '' unless invoice.discount.present?
    coupon = invoice.discount.coupon
    return "$#{coupon.amount_off / 100.0} off" if coupon.amount_off.present?
    return "#{coupon.percent_off}% off" if coupon.percent_off.present?
  end
  
  def invoice_date(invoice)
    date_format(DateTime.strptime(invoice.date.to_s, '%s'))
  end
end