class Datapass::JtcPosition < ApplicationRecord
  self.table_name = "datapass_jtc_positions"
  validates :jtc, uniqueness: true

end
