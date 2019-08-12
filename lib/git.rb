class Git
  def self.clone_or_update!(name, url, commit)
    clone!(name, url) unless File.exist?(path(name))

    update!(name, commit)
  end

  def self.path(*dirs)
    Rails.root.join('texts', *dirs).to_s
  end

  def self.clone!(name, url)
    system('git', 'clone', '--branch', 'master', '--single-branch', '--depth', '1', url, path(name))
  end

  def self.update!(name, commit)
    system('git', '-C', path(name), 'fetch', '--depth', '1')
    system('git', '-C', path(name), 'reset', '--hard', commit)
  end
end
