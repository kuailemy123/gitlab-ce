require 'base64'
require 'json'

module Gitlab
  class Workhorse
    SEND_DATA_HEADER = 'Gitlab-Workhorse-Send-Data'

    class << self
      def git_http_ok(repository, user)
        {
          'GL_ID' => Gitlab::ShellEnv.gl_id(user),
          'RepoPath' => repository.path_to_repo,
        }
      end

      def send_git_blob(repository, blob)
        params = {
          'RepoPath' => repository.path_to_repo,
          'BlobId' => blob.id,
        }

        [
          SEND_DATA_HEADER,
          "git-blob:#{encode(params)}",
        ]
      end

      def send_git_archive(project, ref, format)
        format ||= 'tar.gz'
        format.downcase!
        params = project.repository.archive_metadata(ref, Gitlab.config.gitlab.repository_downloads_path, format)
        raise "Repository or ref not found" if params.empty?

        [
          SEND_DATA_HEADER,
          "git-archive:#{encode(params)}",
        ]
      end

      def send_git_diff(repository, from, to)
        params = {
            'RepoPath'  => repository.path_to_repo,
            'ShaFrom'   => from,
            'ShaTo'     => to
        }

        [
          SEND_DATA_HEADER,
          "git-diff:#{encode(params)}"
        ]
      end

      def send_git_patch(repository, from, to)
        params = {
            'RepoPath'  => repository.path_to_repo,
            'ShaFrom'   => from,
            'ShaTo'     => to
        }

        [
          SEND_DATA_HEADER, 
          "git-format-patch:#{encode(params)}"
        ]
      end

      protected

      def encode(hash)
        Base64.urlsafe_encode64(JSON.dump(hash))
      end
    end
  end
end
