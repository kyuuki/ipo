class RemoveUserFromApplications < ActiveRecord::Migration[5.1]
  def change
    remove_reference :applications, :user, foreign_key: true
  end
end
