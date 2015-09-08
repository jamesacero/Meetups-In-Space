class CreateMeetups < ActiveRecord::Migration
  def change
    create_table :meetups do |table|
      table.string :name, null: false
      table.string :description, null: false
      table.string :location, null: false

      table.timestamps
    end

    add_index(:meetups, :name)
  end
end
