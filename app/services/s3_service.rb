require 'zoku/aws/s3'

class S3Service
  def self.get_object_by_key(document_key)
    ::Aws::S3::Object.new(
      bucket_name: Zoku::AWS::S3.bucket_name,
      key: document_key,
      client: Zoku::AWS::S3.client
    )
  end

  def self.delete_from_storage(document_key, **options)
    Zoku::AWS::S3.client.delete_object(
      options.merge(key: document_key, bucket: Zoku::AWS::S3.bucket_name))
  end
  
  # TODO simplify after https://github.com/aws/aws-sdk-ruby/issues/1598 is resolved
  def self.stable_presigned_url_for_today(s3obj)
    url = "https://#{s3obj.bucket_name}.s3.amazonaws.com/#{URI.escape(s3obj.key)}"
    presigner = Aws::S3::Presigner.new(client: s3obj.client)
    signer = presigner.send(:build_signer, s3obj.client.config)
    signer.presign_url(
      url: url,
      http_method: 'GET',
      body_digest: 'UNSIGNED-PAYLOAD',
      expires_in: 86401,
      time: Zoku::TZ.chicago.now.beginning_of_day.utc
    ).to_s
  end
end
