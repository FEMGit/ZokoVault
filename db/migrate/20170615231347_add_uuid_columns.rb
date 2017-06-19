class AddUuidColumns < ActiveRecord::Migration
  def change
    enable_extension 'uuid-ossp'
    %i{ documents
        contacts
        users
    }.each do |table|
      add_column table, :uuid, :uuid, default: 'uuid_generate_v4()'
      change_column_null table, :uuid, false
      add_index table, :uuid, unique: true
    end
  end
end
