class AddRepositoryStorageToApplicationSettings < ActiveRecord::Migration
  def change
    add_column :application_settings, :repository_storage, :string
  end
end
