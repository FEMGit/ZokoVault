require 'zoku/aws/profile'

module Zoku
  module AWS
    module IAM

      def self.region
        Zoku::AWS::Profile.active.region
      end

      def self.s3_user
        ::Aws::Credentials.new(
          Zoku::AWS::Profile.active.s3.access_key_id,
          Zoku::AWS::Profile.active.s3.access_key_secret
        )
      end

      def self.s3_role
        assume_role(
          user:       s3_user,
          role_arn:   Zoku::AWS::Profile.active.s3.role_arn,
          role_alias: 'S3Access',
          region:     region
        )
      end

      def self.kms_user
        ::Aws::Credentials.new(
        Zoku::AWS::Profile.active.kms.access_key_id,
        Zoku::AWS::Profile.active.kms.access_key_secret
        )
      end

      def self.kms_role
        assume_role(
          user:       kms_user,
          role_arn:   Zoku::AWS::Profile.active.kms.role_arn,
          role_alias: 'PerUserCryptoKeys',
          region:     region
        )
      end

      def self.assume_role(user:, role_arn:, role_alias:, region:)
        client = ::Aws::STS::Client.new(region: region, credentials: user)
        ::Aws::AssumeRoleCredentials.new(
          client: client, role_arn: role_arn, role_session_name: role_alias)
      end

    end
  end
end
