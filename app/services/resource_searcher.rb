#
# This service class uses a naive approach to search
# resources
#
# Users a refine to duck-type activerecord, struct, etc.
#
# UserResourceGatherer.new(user).all_resources
# return Array[<shareable resource>]
#
module Hashable
  refine ActiveRecord::Base do
    def to_h
      attributes
    end
  end
end

using Hashable

class ResourceSearcher

  attr_reader :resources

  def initialize(resources)
    @resources = resources
  end

  def search(term)
    resources.select do |resource|
      resource_search_params = resource.is_a?(PowerOfAttorneyContact) ? resource.search_attributes : resource.to_h
      resource_search_params.values.map(&:to_s).any? { |x| x.downcase.include? (term.downcase) }
    end
  end
end
