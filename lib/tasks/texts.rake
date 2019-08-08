require 'git'

namespace :texts do
  desc 'Clone or update all texts'
  task update: :environment do
    Rails.configuration.dts_repositories.each do |name, url|
      Git.clone_or_update!(name, url)
    end
  end
end
