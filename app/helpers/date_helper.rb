module DateHelper
  def date_format(date)
    return nil unless date.present?
    date.strftime('%m/%d/%Y')
  end
end