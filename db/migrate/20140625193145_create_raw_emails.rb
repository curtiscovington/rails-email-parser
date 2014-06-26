class CreateRawEmails < ActiveRecord::Migration
  def self.up
    create_table :raw_emails do |t|
      t.text :raw_email
      t.timestamps
    end
  end

  def self.down
    drop_table :raw_emails
  end
end
