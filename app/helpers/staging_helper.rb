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
  
  def heroku_app_name
    ENV.fetch('HEROKU_APP_NAME', '')
  end
  
  def heroku_review_app?
    !!(heroku_app_name =~ /\Azoku-develop/)
  end
  
  def develop_staging?
    heroku_review_app? ||
    staging_type == TYPES[:local] ||
    staging_type == TYPES[:development]
  end
end
