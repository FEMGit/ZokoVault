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
end
