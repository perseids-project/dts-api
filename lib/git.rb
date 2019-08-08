class Git
  def self.clone_or_update!(name, url)
    if File.exist?(path(name))
      update!(name)
    else
      clone!(name, url)
    end
  end

  def self.path(*dirs)
    Rails.root.join('texts', *dirs).to_s
  end

  def self.clone!(name, url)
    system('git', 'clone', '--branch', 'master', '--single-branch', '--depth', '1', url, path(name))
  end

  def self.update!(name)
    system('git', '-C', path(name), 'fetch', '--depth', '1', 'origin', 'master')
    system('git', '-C', path(name), 'reset', '--hard', 'origin/master')
  end
end
