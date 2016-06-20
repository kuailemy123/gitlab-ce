# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddColumnIidToProtectedBranches < ActiveRecord::Migration
  include Gitlab::Database::MigrationHelpers

  # When using the methods "add_concurrent_index" or "add_column_with_default"
  # you must disable the use of transactions as these methods can not run in an
  # existing transaction. When using "add_concurrent_index" make sure that this
  # method is the _only_ method called in the migration, any other changes
  # should go in a separate migration. This ensures that upon failure _only_ the
  # index creation fails and can be retried or reverted easily.
  #
  # To disable transactions uncomment the following line and remove these
  # comments:
  # disable_ddl_transaction!

  def up
    add_column :protected_branches, :iid, :integer
    populate_iids_for_existing_protected_branches
  end

  def down
    remove_column :protected_branches, :iid, :integer
  end

  protected

  def populate_iids_for_existing_protected_branches
    max_iid_by_project_id = Hash.new(1)
    ProtectedBranch.all.each do |protected_branch|
      iid = max_iid_by_project_id[protected_branch.project_id]
      protected_branch.update(iid: iid)
      max_iid_by_project_id[protected_branch.project_id] = iid + 1
    end

    blank_iids = ProtectedBranch.find_by_sql("select iid from protected_branches WHERE iid IS NULL")
    if blank_iids.count > 0
      raise "Something went wrong with the 'add_column_iid_to_protected_branches' migration. We shouldn't have any blank iids."
    end

    duplicate_iids = ProtectedBranch.find_by_sql("select project_id, iid from protected_branches GROUP BY project_id, iid HAVING COUNT(*) > 1")
    if duplicate_iids.count > 0
      raise "Something went wrong with the 'add_column_iid_to_protected_branches' migration. We shouldn't have more than one unique [iid, project_id] combination."
    end
  end
end
