module StagingHelper
  def develop_staging?
    ENV['HEROKU_APP_NAME'].include? 'zoku-develop'
  end
end