class CreateMains < ActiveRecord::Migration[6.0]
  def change
    create_table :mains do |t|
      t.text :content

      t.timestamps
    end
  end
end
