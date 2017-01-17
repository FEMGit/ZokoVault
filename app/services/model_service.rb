class ModelService
  def self.model_by_name(name)
    ModelNames::MODELS.select { |k, _v| k == name }.values.first
  end
end
