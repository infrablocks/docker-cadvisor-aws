# frozen_string_literal: true

require 'spec_helper'

describe 'entrypoint' do
  metadata_service_url = 'http://metadata:1338'
  s3_endpoint_url = 'http://s3:4566'
  s3_bucket_region = 'us-east-1'
  s3_bucket_path = 's3://bucket'
  s3_env_file_object_path = 's3://bucket/env-file.env'

  environment = {
    'AWS_METADATA_SERVICE_URL' => metadata_service_url,
    'AWS_ACCESS_KEY_ID' => '...',
    'AWS_SECRET_ACCESS_KEY' => '...',
    'AWS_S3_ENDPOINT_URL' => s3_endpoint_url,
    'AWS_S3_BUCKET_REGION' => s3_bucket_region,
    'AWS_S3_ENV_FILE_OBJECT_PATH' => s3_env_file_object_path
  }
  image = 'cadvisor-aws:latest'
  extra = {
    'Entrypoint' => '/bin/sh',
    'HostConfig' => {
      'NetworkMode' => 'docker_cadvisor_aws_test_default'
    }
  }

  before(:all) do
    set :backend, :docker
    set :env, environment
    set :docker_image, image
    set :docker_container_create_options, extra
  end

  describe 'by default' do
    before(:all) do
      create_env_file(
        endpoint_url: s3_endpoint_url,
        region: s3_bucket_region,
        bucket_path: s3_bucket_path,
        object_path: s3_env_file_object_path
      )

      execute_docker_entrypoint(
        started_indicator: 'Running'
      )
    end

    after(:all, &:reset_docker_backend)

    it 'runs cadvisor' do
      expect(process('/opt/cadvisor/bin/cadvisor')).to(be_running)
    end

    it 'logs to stderr' do
      expect(process('/opt/cadvisor/bin/cadvisor').args)
        .to(match(/--logtostderr=true/))
    end

    it 'has no port' do
      expect(process('/opt/cadvisor/bin/cadvisor').args)
        .not_to(match(/--port/))
    end

    it 'has no housekeeping interval' do
      expect(process('/opt/cadvisor/bin/cadvisor').args)
        .not_to(match(/--housekeeping_interval/))
    end

    it 'has no disabled metrics' do
      expect(process('/opt/cadvisor/bin/cadvisor').args)
        .not_to(match(/--disable_metrics/))
    end

    it 'does not specify the docker only flag' do
      expect(process('/opt/cadvisor/bin/cadvisor').args)
        .not_to(match(/--docker_only/))
    end
  end

  describe 'with port configuration' do
    before(:all) do
      create_env_file(
        endpoint_url: s3_endpoint_url,
        region: s3_bucket_region,
        bucket_path: s3_bucket_path,
        object_path: s3_env_file_object_path,
        env: {
          'CADVISOR_PORT' => '1566'
        }
      )

      execute_docker_entrypoint(
        started_indicator: 'Running'
      )
    end

    after(:all, &:reset_docker_backend)

    it 'uses the provided port' do
      expect(process('/opt/cadvisor/bin/cadvisor').args)
        .to(match(/--port=1566/))
    end
  end

  describe 'with housekeeping configuration' do
    before(:all) do
      create_env_file(
        endpoint_url: s3_endpoint_url,
        region: s3_bucket_region,
        bucket_path: s3_bucket_path,
        object_path: s3_env_file_object_path,
        env: {
          'CADVISOR_HOUSEKEEPING_INTERVAL' => '30s'
        }
      )

      execute_docker_entrypoint(
        started_indicator: 'Running'
      )
    end

    after(:all, &:reset_docker_backend)

    it 'uses the provided housekeeping interval' do
      expect(process('/opt/cadvisor/bin/cadvisor').args)
        .to(match(/--housekeeping_interval=30s/))
    end
  end

  describe 'with metrics configuration' do
    before(:all) do
      create_env_file(
        endpoint_url: s3_endpoint_url,
        region: s3_bucket_region,
        bucket_path: s3_bucket_path,
        object_path: s3_env_file_object_path,
        env: {
          'CADVISOR_DISABLE_METRICS' => 'disk'
        }
      )

      execute_docker_entrypoint(
        started_indicator: 'Running'
      )
    end

    after(:all, &:reset_docker_backend)

    it 'disables the provided metrics' do
      expect(process('/opt/cadvisor/bin/cadvisor').args)
        .to(match(/--disable_metrics=disk/))
    end
  end

  describe 'with docker configuration' do
    describe 'when enabled' do
      before(:all) do
        create_env_file(
          endpoint_url: s3_endpoint_url,
          region: s3_bucket_region,
          bucket_path: s3_bucket_path,
          object_path: s3_env_file_object_path,
          env: {
            'CADVISOR_DOCKER_ONLY_ENABLED' => 'yes'
          }
        )

        execute_docker_entrypoint(
          started_indicator: 'Running'
        )
      end

      after(:all, &:reset_docker_backend)

      it 'includes the docker only option as true' do
        expect(process('/opt/cadvisor/bin/cadvisor').args)
          .to(match(/--docker_only=true/))
      end
    end

    describe 'when disabled' do
      before(:all) do
        create_env_file(
          endpoint_url: s3_endpoint_url,
          region: s3_bucket_region,
          bucket_path: s3_bucket_path,
          object_path: s3_env_file_object_path,
          env: {
            'CADVISOR_DOCKER_ONLY_ENABLED' => 'no'
          }
        )

        execute_docker_entrypoint(
          started_indicator: 'Running'
        )
      end

      after(:all, &:reset_docker_backend)

      it 'includes the docker only option as false' do
        expect(process('/opt/cadvisor/bin/cadvisor').args)
          .to(match(/--docker_only=false/))
      end
    end
  end

  def reset_docker_backend
    Specinfra::Backend::Docker.instance.send :cleanup_container
    Specinfra::Backend::Docker.clear
  end

  def create_env_file(opts)
    create_object(opts
                    .merge(content: (opts[:env] || {})
                      .to_a
                      .collect { |item| " #{item[0]}=\"#{item[1]}\"" }
                      .join("\n")))
  end

  def execute_command(command_string)
    command = command(command_string)
    exit_status = command.exit_status
    unless exit_status == 0
      raise "\"#{command_string}\" failed with exit code: #{exit_status}"
    end

    command
  end

  def create_object(opts)
    make_bucket(opts)
    copy_content(opts)
  end

  def make_bucket(opts)
    execute_command('aws ' \
                    "--endpoint-url #{opts[:endpoint_url]} " \
                    's3 ' \
                    'mb ' \
                    "#{opts[:bucket_path]} " \
                    "--region \"#{opts[:region]}\"")
  end

  def copy_content(opts)
    execute_command("echo -n #{Shellwords.escape(opts[:content])} | " \
                    'aws ' \
                    "--endpoint-url #{opts[:endpoint_url]} " \
                    's3 ' \
                    'cp ' \
                    '- ' \
                    "#{opts[:object_path]} " \
                    "--region \"#{opts[:region]}\" " \
                    '--sse AES256')
  end

  def execute_docker_entrypoint(opts)
    logfile_path = '/tmp/docker-entrypoint.log'
    started_indicator = opts[:started_indicator]

    trigger_docker_entrypoint_in_background(logfile_path)
    wait_for_started_indicator_to_be_present(logfile_path, started_indicator)
  end

  def trigger_docker_entrypoint_in_background(logfile_path)
    execute_command(
      "docker-entrypoint.sh > #{logfile_path} 2>&1 &"
    )
  end

  def wait_for_started_indicator_to_be_present(logfile_path, started_indicator)
    Octopoller.poll(timeout: 5) do
      should_re_poll?(logfile_path, started_indicator)
    end
  rescue Octopoller::TimeoutError => e
    puts read_path(logfile_path)
    raise e
  end

  def should_re_poll?(logfile_path, started_indicator)
    logfile_contents = read_path(logfile_path)
    if logfile_contents =~ /#{started_indicator}/
      logfile_contents
    else
      :re_poll
    end
  end

  def read_path(logfile_path)
    command("cat #{logfile_path}").stdout
  end
end
