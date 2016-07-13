CarrierWave.configure do |config|
  config.fog_credentials = {
    :provider               => 'AWS',                        # required
    :aws_access_key_id      => ENV['AWS_ACCESS_KEY_ID']|| 'AKIAJX3IUF2HYZWPK75Q',                        # required
    :aws_secret_access_key  => ENV['AWS_SECRET_ACCESS_KEY'] || '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'                       # required
  }
  config.fog_directory  = ENV['S3_BUCKET']  || 'zoku-stage'                        # required

end
