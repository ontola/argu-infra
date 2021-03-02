#!/usr/bin/env ruby

require 'terraform-enterprise-client'

$stdout.sync = true

namespace = ENV['CI_PROJECT_NAMESPACE']
environment = ENV['ENVIRONMENT_SLUG'] || ENV['CI_ENVIRONMENT_SLUG']
workspace = "#{namespace}-#{environment}"
next_version = ENV['COMMIT_TAG'] || ENV['CI_COMMIT_TAG']

STDERR.puts "Updating #{namespace}/#{workspace} to version '#{next_version}'"

token = ENV['TFE_TOKEN']
client = TerraformEnterprise::API::Client.new(token: token)

workspace_req = client.workspaces.get(organization: namespace, workspace: workspace)
abort "Could not find workspace: #{workspace_req.errors}" unless workspace_req.success?

variables = client
    .variables
    .list(organization: namespace, workspace: workspace)

unless variables.success?
  abort "Getting list of variables failed: #{variables.errors}"
end

variables = variables.resources.map(&:data)

image_tag_id = variables.find { |d| d.dig('attributes', 'key') == 'image_tag' }['id']

service_image_tag = variables.find { |v| v.dig('attributes', 'key') == 'service_image_tag' }
if service_image_tag
    STDERR.puts "Overrides present in workspace: '#{service_image_tag.dig('attributes', 'value')}'"
end

if client.variables.update(id: image_tag_id, value: next_version).success?
    STDERR.puts "Updated 'image_tag' to #{next_version}"
else
    abort "Updating 'image_tag' value failed"
end

create_run = {
  attributes: {
    message: "Deploying '#{next_version}' from CI.\n\nPipeline: #{ENV['CI_PIPELINE_URL']}\nTriggered by #{ENV['GITLAB_USER_NAME']}"
  },
  relationships: {
    workspace: {
      data: {
        type: 'workspaces',
        id: workspace_req.data['id']
      }
    }
  },
  type: 'runs'
}
run = client.runs.instance_variable_get(:@request).post(:runs, data: create_run)
abort "Creating run failed: #{run.errors}" unless run.success?

run_id = run.data.dig('links', 'self').delete_prefix("/api/v2/")

puts "https://app.terraform.io/app/#{namespace}/workspaces/#{workspace}/#{run_id}"
