class CreateStackviewCallNumbers < ActiveRecord::Migration
  def change
    create_table :stackview_call_numbers do |t|
      # these are what we want to assemble items in a sequence,
      t.string :sort_key, :null => false, :length => 100
      t.string :sort_key_display
      t.string :sort_key_type, :null => false, :length => 100

      # and be able to link back to external systems
      t.string :system_id, :null => false, :length => 100

 
      # These are what stackview wants or can use

      t.string :title, :null => false
      t.string :creator
      t.string :format

      t.integer    :measurement_page_numeric
      t.integer    :measurement_height_numeric
      t.integer    :shelfrank

      t.string :pub_date

      # record created_at for bookkeeping

      t.column :created_at, :datetime

      # indexes
      t.index :system_id
      t.index :sort_key
    end
  end
end
