module StagingHelper
  extend self
  
  TYPES = {
    local:        'local'.freeze,
    development:  'develop'.freeze,
    staging:      'beta'.freeze,
    production:   'production'.freeze
  }.freeze
  
  def staging_type
    ENV.fetch('STAGING_TYPE', TYPES[:local])
  end
  
  def known_environment?
    TYPES.values.include?(staging_type)
  end
  
  TYPES.each do |k,v|
    define_method("#{k}_deploy?"){ staging_type == v }
  end
  
  def heroku_app_name
    ENV.fetch('HEROKU_APP_NAME', '')
  end
  
  def heroku_review_app?
    !!(heroku_app_name =~ /\Azoku-develop/)
  end
  
  def develop_staging?
    heroku_review_app? || local_deploy? || development_deploy?
  end
end
