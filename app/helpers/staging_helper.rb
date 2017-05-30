module StagingHelper
  def develop_staging?
    staging_type = ENV['STAGING_TYPE'] || nil
    ((ENV['HEROKU_APP_NAME'] || '').include? 'zoku-develop') ||
      staging_type.blank? || (staging_type.eql? 'develop')
  end
end