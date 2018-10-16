require 'rake_docker'
require 'rake_terraform'
require 'yaml'
require 'git'
require 'semantic'

require_relative 'lib/version'

def repo
  Git.open('.')
end

def latest_tag
  repo.tags.map do |tag|
    Semantic::Version.new(tag.name)
  end.max
end

namespace :image do
  RakeDocker.define_image_tasks do |t|
    t.image_name = 'consul-aws'
    t.work_directory = 'build/images'

    t.copy_spec = [
        "src/consul-aws/Dockerfile",
    ]

    t.repository_name = 'consul-aws'
    t.repository_url = 'infrablocks/consul-aws'

    t.credentials = YAML.load_file(
        "config/secrets/dockerhub/credentials.yaml")

    t.tags = [latest_tag.to_s, 'latest']
  end

  desc 'Build and push image'
  task :publish do
    Rake::Task['image:clean'].invoke
    Rake::Task['image:build'].invoke
    Rake::Task['image:tag'].invoke
    Rake::Task['image:push'].invoke
  end
end

namespace :version do
  task :bump, [:type] do |_, args|
    next_tag = latest_tag.send("#{args.type}!")
    repo.add_tag(next_tag.to_s)
    repo.push('origin', 'master', tags: true)
  end
end
