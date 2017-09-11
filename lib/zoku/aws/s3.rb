require 'zoku/aws/iam'

module Zoku
  module AWS
    module S3

      def self.client
        @s3client ||= ::Aws::S3::Client.new(
          region: Zoku::AWS::IAM.region,
          credentials: Zoku::AWS::IAM.s3_role
        )
      end

      def self.bucket_name
        Zoku::AWS::Profile.active.s3.bucket_name
      end

    end
  end
end
