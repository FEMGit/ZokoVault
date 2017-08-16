class CleanCorporateEmployeesEmptyUsers < ActiveRecord::Migration
  def change
    ids_to_delete = CorporateEmployeeAccountUser.select { |x| User.find_by(id: x.user_account_id).blank? }.map(&:id)
    CorporateEmployeeAccountUser.where(id: ids_to_delete).delete_all
  end
end
