class DocumentService
  
  attr_accessor :document
  
  def initialize(params)
    @category = params[:category]
  end
  
  def get_all_groups
    @all_groups = Rails.configuration.x.categories.collect{|category| {:label => category[1]["label"], :groups => category[1]["groups"]}}
  end
  
  def category_exist?
    @all_groups.detect{|x| x[:label] == @category}
  end
  
  def get_empty_card_values
    ["Select..."]
  end
  
  def get_card_values
    get_all_groups
    if category_exist?
      @all_groups.detect{|x| x[:label] == @category}[:groups].collect{|x| x["label"]}
        .prepend("Select...")
    else
      get_empty_card_values
    end
  end

end
