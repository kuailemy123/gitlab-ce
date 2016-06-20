class RenameCommitShaToCommitIdOnMergeRequestDiffs < ActiveRecord::Migration
  def change
    rename_column :merge_request_diffs, :base_commit_sha, :base_commit_id
    rename_column :merge_requests, :merge_commit_sha, :merge_commit_id
  end
end
