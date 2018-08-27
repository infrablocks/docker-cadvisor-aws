require 'rake_docker'
require 'rake_terraform'
require 'yaml'

namespace "repository" do
  RakeTerraform.define_command_tasks do |t|
    t.argument_names = [:deployment_identifier]

    t.configuration_name = "image repository"
    t.source_directory = "infra/image_repository"
    t.work_directory = 'build'

    t.backend_config = lambda do |args|
      configuration
          .for_overrides(args)
          .for_scope(role: "repository")
          .backend_config
    end

    t.vars = lambda do |args|
      configuration
          .for_overrides(args)
          .for_scope(role: "repository")
          .vars
    end
  end
end

namespace "image" do
  RakeDocker.define_image_tasks do |t|
    t.image_name = "alpine-aws"
    t.work_directory = 'build/images'

    t.copy_spec = [
        "Dockerfile",
    ]

    t.repository_name = "alpine-aws"
    t.repository_url = "infrablocks/alpine-aws"

    t.credentials = YAML.load_file(
        "config/secrets/dockerhub/credentials.yaml")


    t.tags = ["latest"]
  end

  desc 'Build and push custom concourse image'
  task :publish, [:deployment_identifier] do |_, args|
    Rake::Task["image:clean"].invoke(args.deployment_identifier)
    Rake::Task["image:build"].invoke(args.deployment_identifier)
    Rake::Task["image:tag"].invoke(args.deployment_identifier)
    Rake::Task["image:push"].invoke(args.deployment_identifier)
  end
end
