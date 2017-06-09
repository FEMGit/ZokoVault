module FriendlyId
  module FinderMethods
    def find_or_return_nil(*args)
      begin
        find(*args)
      rescue ActiveRecord::RecordNotFound
        return nil
      end
    end
  end
end
