module Zoku
  module AWS
    module IAM

      def self.region
        Rails.application.secrets.aws_region
      end

      def self.s3_user
        ::Aws::Credentials.new(
          Rails.application.secrets.aws_user_key_id,
          Rails.application.secrets.aws_user_secret_key
        )
      end

      def self.s3_role
        assume_role(
          user:       s3_user,
          role_arn:   'arn:aws:iam::751141858228:role/s3access',
          role_alias: 'S3Access',
          region:     region
        )
      end

      def self.kms_user
        ::Aws::Credentials.new(
          Rails.application.secrets.aws_crypto_user_key_id,
          Rails.application.secrets.aws_crypto_user_secret_key
        )
      end

      def self.kms_role
        assume_role(
          user:       kms_user,
          role_arn:   Rails.application.secrets.aws_per_user_key_role,
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
