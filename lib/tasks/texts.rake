require 'git'
require 'parser'

namespace :texts do
  desc 'Clone or update all texts'
  task download: :environment do
    Rails.configuration.dts_repositories.each do |repository|
      Git.clone_or_update!(repository[:name], repository[:url], repository[:commit] || 'origin/master')
    end
  end

  desc 'Create or update collections in database'
  task import: :environment do
    Rails.configuration.dts_repositories.each do |repository|
      Parser.parse!(repository[:name], Rails.configuration.dts_collections)
    end
  end
end
