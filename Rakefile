require 'rake_docker'
require 'rake_terraform'
require 'yaml'
require 'git'
require 'semantic'

require_relative 'lib/version'

Docker.options = {
    read_timeout: 300
}

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
    t.image_name = 'cadvisor-aws'
    t.work_directory = 'build/images'

    t.copy_spec = [
        "src/cadvisor-aws/Dockerfile",
        "src/cadvisor-aws/docker-entrypoint.sh",
    ]

    t.repository_name = 'cadvisor-aws'
    t.repository_url = 'infrablocks/cadvisor-aws'

    t.credentials = YAML.load_file(
        "config/secrets/dockerhub/credentials.yaml")

    t.tags = [latest_tag.to_s, 'latest']
  end

  desc 'Build and push image'
  task :publish do
    Rake::Task['base_image:clean'].invoke
    Rake::Task['base_image:build'].invoke
    Rake::Task['base_image:tag'].invoke
    Rake::Task['base_image:push'].invoke
  end
end

namespace :version do
  task :bump, [:type] do |_, args|
    next_tag = latest_tag.send("#{args.type}!")
    repo.add_tag(next_tag.to_s)
    repo.push('origin', 'master', tags: true)
  end

  task :release do
    next_tag = latest_tag.release!
    repo.add_tag(next_tag.to_s)
    repo.push('origin', 'master', tags: true)
  end
end
