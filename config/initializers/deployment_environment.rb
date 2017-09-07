class UnknownDeploymentEnvironmentError < StandardError
  def initialize(type)
    super "The STAGING_TYPE #{type.inspect} is not recognized!"
  end
end
  
raise UnknownDeploymentEnvironmentError,
  StagingHelper.staging_type if !StagingHelper.known_environment?
