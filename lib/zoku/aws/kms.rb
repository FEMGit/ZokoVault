require 'zoku/aws/iam'

module Zoku
  module AWS
    module KMS

      def self.client
        ::Aws::KMS::Client.new(
          region: Zoku::AWS::IAM.region,
          credentials: Zoku::AWS::IAM.kms_role
        )
      end
      
      def self.key_alias
        Rails.application.secrets.aws_per_user_key_alias
      end

    end
  end
end
