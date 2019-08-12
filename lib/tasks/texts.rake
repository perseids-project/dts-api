require 'git'

namespace :texts do
  desc 'Clone or update all texts'
  task update: :environment do
    Rails.configuration.dts_repositories.each do |bundle|
      Git.clone_or_update!(bundle[:name], bundle[:url], bundle[:commit] || 'origin/master')
    end
  end
end
