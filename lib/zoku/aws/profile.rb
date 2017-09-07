module Zoku
  module AWS
    class Profile
      attr_reader :region, :s3, :kms
      
      S3  = Struct.new(:role_arn, :bucket_name, :access_key_id, :access_key_secret)
      KMS = Struct.new(:role_arn, :key_alias, :access_key_id, :access_key_secret)
            
      class << self
        def all
          @all ||= load_yaml.reduce({}){ |h,(k,v)| h[k.to_sym] = new(v); h }.freeze
        end
        
        def active
          all[StagingHelper.production_deploy? ? :production : :development]
        end
        
        private
        
        def load_yaml
          YAML.load(File.read(File.expand_path(
            '../../../config/aws_profiles.yml', __dir__)))
        end
      end
      
      def initialize(data)
        @region = data['region'].freeze
        @s3 = S3.new(
          data['s3']['role_arn'].freeze,
          data['s3']['bucket_name'].freeze,
          from_env(data['s3'], 'ACCESS_KEY_ID'),
          from_env(data['s3'], 'ACCESS_KEY_SECRET')
        )
        @kms = KMS.new(
          data['kms']['role_arn'].freeze,
          data['kms']['key_alias'].freeze,
          from_env(data['kms'], 'ACCESS_KEY_ID'),
          from_env(data['kms'], 'ACCESS_KEY_SECRET')
        )
      end
      
      private
      
      def from_env(hash, suffix)
        ENV["#{hash['user_env']}_#{suffix}"].try(:freeze)
      end
      
    end
  end
end
