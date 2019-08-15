require 'utils'

class Git
  include Utils

  def self.clone_or_update!(name, url, commit)
    new(name, url, commit).clone_or_update!
  end

  def initialize(name, url, commit)
    @name = name
    @url = url
    @commit = commit
  end

  def clone_or_update!
    clone! unless File.exist?(path(name))

    update!
  end

  private

  attr_reader :name, :url, :commit

  def clone!
    system('git', 'clone', '--branch', 'master', '--single-branch', '--depth', '1', url, path(name))
  end

  def update!
    system('git', '-C', path(name), 'fetch', '--depth', '1')
    system('git', '-C', path(name), 'reset', '--hard', commit)
  end
end
