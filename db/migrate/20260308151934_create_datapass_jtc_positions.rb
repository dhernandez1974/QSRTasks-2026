class CreateDatapassJtcPositions < ActiveRecord::Migration[8.1]
  def change
    create_table :datapass_jtc_positions, id: :uuid do |t|
      t.string :jtc
      t.string :job_title
      t.string :matching_position

      t.timestamps
    end
  end
end
