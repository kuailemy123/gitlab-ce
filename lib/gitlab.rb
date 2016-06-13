require_dependency 'gitlab/git'

module Gitlab
  def self.com?
    Gitlab.config.gitlab.url == 'https://gitlab.com' ||
      Gitlab.config.gitlab.url == 'https://staging.gitlab.com'
  end
end
