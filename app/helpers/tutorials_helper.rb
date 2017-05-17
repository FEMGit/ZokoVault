module TutorialsHelper
  def tutorial_icon(tutorial)
    case tutorial_id(tutorial)
      when 'home'
        '#icon-house-large'
      when 'add-primary-contact', 'add-tax-accountant'
        '#icon-woman'
      when 'insurance'
        '#icon-document-shield'
      when 'vehicle'
        '#icon-car-large'
      when 'add-financial-advisor'
        '#icon-business-man-2'
      else
        '#icon-activity-monitor-1'
    end
  end
  
  def tutorial_id(tutorial)
    tutorial[:name].downcase.split(' ').join('-')
  end
end
