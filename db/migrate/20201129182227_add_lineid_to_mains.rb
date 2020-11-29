class AddLineidToMains < ActiveRecord::Migration[6.0]
  def change
    add_column :mains, :lineid, :text
  end
end
