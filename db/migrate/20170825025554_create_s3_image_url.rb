class CreateS3ImageUrl < ActiveRecord::Migration
  def change
    create_table :s3_image_urls do |t|
      t.references :user
      t.string :key
      t.string :presigned_url
      t.string :expires_at
    end
    
    add_index :s3_image_urls, :key
  end
end
