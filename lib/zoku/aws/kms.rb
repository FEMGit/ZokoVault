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

    end
  end
end
