# frozen_string_literal: true

require 'spec_helper'

describe 'commands' do
  image = 'cadvisor-aws:latest'
  extra = {
    'Entrypoint' => '/bin/sh'
  }

  before(:all) do
    set :backend, :docker
    set :docker_image, image
    set :docker_container_create_options, extra
  end

  after(:all, &:reset_docker_backend)

  it 'includes the cadvisor command' do
    expect(command('/opt/cadvisor/bin/cadvisor --version').stdout)
      .to(match(/0.47.2/))
  end

  def reset_docker_backend
    Specinfra::Backend::Docker.instance.send :cleanup_container
    Specinfra::Backend::Docker.clear
  end
end
