#
# This service class uses a naive approach to stage all shared information for a
# user
#
# UserResourceGatherer.new(user).all_resources
# return Array[<shareable resource>]
#
class UserResourceGatherer < Struct.new(:user)
  attr_reader :user

  def initialize(user)
    @user = user
  end
  
  def categories
    CategoryLinks::LINKS
  end

  def my_resources
    return @my_resources if @my_resources

    @my_resources =
      categories |
      gather_wtl(user) |
      gather_insurance(user, Category.fetch('insurance')) |
      Contact.for_user(user) |
      gather_taxes(user, Category.fetch('taxes')) |
      gather_final_wishes(user, Category.fetch('final wishes')) |
      gather_financial_information(user, Category.fetch('financial information'))
    
    @my_resources.flatten!
    @my_resources
  end

  def shared_resources
    return @shared_resources if @shared_resources
    @shared_resources =
      Share.includes(:user, :shareable)
      .where(contact: Contact.where(emailaddress: user.email))
      .map do |share|
        if Category === share.shareable
          category_resources(share)
        else
          share.shareable
        end
      end
    @shared_resources.flatten!
    @shared_resources
  end
  
  def shares
    return @shares if @shares
    @shared_resources =
      Share.includes(:user, :shareable)
      .where(contact: Contact.where(emailaddress: user.email))
      .flatten
  end

  def all_resources
    my_resources | shared_resources
  end

  def category_resources(share)
    user, category = share.user, share.shareable

    case category
    when Category.fetch('wills - trusts - legal')
      gather_wtl(user)
    when Category.fetch('insurance');
      gather_insurance(user, category)
    # when Category.fetch('contact')
    #   Contact.for_user(user)
    when Category.fetch('taxes')
      gather_taxes(user, category)
    when Category.fetch('final wishes')
      gather_final_wishes(user, category)
    when Category.fetch('financial information')
      gather_financial_information(user, category)
    end
  end
  
  private

  def gather_wtl(user)
    Will.for_user(user) |
    Trust.for_user(user) |
    PowerOfAttorney.for_user(user) |
    Document.for_user(user).where(group: %w(Trust Will PowerOfAttorney))
  end

  def gather_insurance(user, category)
    Vendor.for_user(user).where(category: category) |
    Document.for_user(user).where(category: category.name)
  end

  def gather_taxes(user, category)
    TaxYearInfo.for_user(user) |
      Tax.for_user(user) |
      Document.for_user(user).where(category: category.name)
  end

  def gather_final_wishes(user, category)
    FinalWishInfo.for_user(user) |
      FinalWish.for_user(user) |
      Document.for_user(user).where(category: category.name)
  end

  def gather_financial_information(user, category)
    FinancialInvestment.for_user(user) |
      FinancialProperty.for_user(user) |
      FinancialProvider.for_user(user) |
      Document.for_user(user).where(category: category.name)
  end
end
