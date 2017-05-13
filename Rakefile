# frozen_string_literal: true

require 'rake'
require 'erb'
require 'rake/clean'
require 'pathname'
require 'yaml'
require 'rubocop/rake_task'

task default: ['rubocop:auto_correct', :deployment]

RuboCop::RakeTask.new

DEPLOYMENT_DIR = 'deployment'
directory DEPLOYMENT_DIR
CLOBBER.include(DEPLOYMENT_DIR)

TEMPLATE_DIR = Pathname('templates')
TEMPLATES = FileList.new(TEMPLATE_DIR / '**/*') do |list|
  list.exclude do |candidate|
    Pathname(candidate).directory?
  end
end

TARGET_FILES = TEMPLATES.pathmap("%{^#{TEMPLATE_DIR},#{DEPLOYMENT_DIR}}p")
CLEAN.include(TARGET_FILES)

TARGET_FILES.each do |target|
  target_dir = Pathname(target).dirname
  template = Pathname(target.pathmap("%{^#{DEPLOYMENT_DIR},#{TEMPLATE_DIR}}p"))

  directory target_dir

  desc "Build #{target} from #{template}"
  file target => [template, target_dir] do
    warn "Rendering #{template} into #{target}"
    Pathname(target).write(ERB.new(template.read).result(binding))
  end
end

desc 'Render files to deploy'
task 'deployment' => TARGET_FILES + [:shellcheck]

desc 'Run shellcheck for generated shell scripts'
task 'shellcheck': TARGET_FILES do |file|
  sh %(shellcheck deployment/bin/*) do |ok, process_status|
    if !ok
      fail 'The shellcheck findings listed above need to be fixed.'
    end
  end
end

def config
  @config ||= YAML.load_file('config.yml')
end
