require 'rake_docker'
require 'rake_terraform'
require 'yaml'

namespace :image do
  RakeDocker.define_image_tasks do |t|
    t.image_name = 'alpine-aws'
    t.work_directory = 'build/images'

    t.copy_spec = [
        "src/alpine-aws/Dockerfile",
    ]

    t.repository_name = 'alpine-aws'
    t.repository_url = 'infrablocks/alpine-aws'

    t.credentials = YAML.load_file(
        "config/secrets/dockerhub/credentials.yaml")

    t.tags = ['latest']
  end
end
