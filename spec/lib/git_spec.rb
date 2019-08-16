require 'rails_helper'
require 'git'

RSpec.describe Git do
  describe '.clone_or_update!' do
    before do
      FakeFS.activate!

      FakeFS::FileSystem.clone(
        Rails.root.join('spec', 'fixtures', 'texts').to_s,
        Rails.root.join('texts').to_s,
      )

      allow_any_instance_of(Git).to receive(:system)
    end

    after do
      FakeFS.deactivate!
    end

    it 'clones a new repository' do
      expect_any_instance_of(Git).to receive(:system).with(
        'git',
        'clone',
        '--branch',
        'master',
        '--single-branch',
        '--depth',
        '1',
        'https://example.com/example/test',
        Rails.root.join('texts', 'test').to_s,
      )
      expect_any_instance_of(Git).to receive(:system).with(
        'git', '-C', Rails.root.join('texts', 'test').to_s, 'fetch', '--depth', '1'
      )
      expect_any_instance_of(Git).to receive(:system).with(
        'git', '-C', Rails.root.join('texts', 'test').to_s, 'reset', '--hard', 'origin/master'
      )

      Git.clone_or_update!('test', 'https://example.com/example/test', 'origin/master')
    end

    it 'updates an existing repository' do
      expect_any_instance_of(Git).to_not receive(:system).with(
        'git',
        'clone',
        '--branch',
        'master',
        '--single-branch',
        '--depth',
        '1',
        'https://example.com/example/test',
        Rails.root.join('texts', 'canonical-latinLit').to_s,
      )
      expect_any_instance_of(Git).to receive(:system).with(
        'git', '-C', Rails.root.join('texts', 'canonical-latinLit').to_s, 'fetch', '--depth', '1'
      )
      expect_any_instance_of(Git).to receive(:system).with(
        'git', '-C', Rails.root.join('texts', 'canonical-latinLit').to_s, 'reset', '--hard', 'origin/dev'
      )

      Git.clone_or_update!('canonical-latinLit', 'https://example.com/example/test', 'origin/dev')
    end
  end
end
