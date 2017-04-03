module SanitizeModule
  def self.included(base)
    base.before_filter :sanitize_params, only: [:create, :update, :send_email]
  end
  
  def sanitize_params
    params.each do |param|
      if param.last.is_a? Hash
        param_key = param.first
        sanitize_recursive(params[param_key])
      elsif (param.is_a? Array) && (param.count.eql? 2)
        params[param.first] = ActionController::Base.helpers.sanitize(param.last)
      end
    end
  end
  
  def sanitize_recursive(hash_params)
    hash_params.map do |key, value|
      next if value.blank?
      if value.is_a? Array
        hash_params[key].map! { |x| ActionController::Base.helpers.sanitize(x).gsub("&amp;", "&") }
      elsif value.is_a? Hash
        sanitize_recursive(hash_params[key])
      elsif value.is_a? String
        hash_params[key] = ActionController::Base.helpers.sanitize(value).gsub("&amp;", "&")
      end
    end
  end
end