module DateHelper
  def date_format(date)
    return nil unless date.present?
    date.strftime('%m/%d/%Y')
  end
  
  def cst(date)
    date.in_time_zone('Central Time (US & Canada)').strftime('%m/%d/%Y %H:%M CST')
  end
end