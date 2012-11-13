#!/usr/bin/env ruby1.9.1

##########################
# Scirpt  : Jenkins Build Trigger
# Author  : Iain Cambridge (http://github.com/icambridge)
# License : MIT
##########################

require 'net/http'
require 'json'
require 'git'

#
# @param [String] config_name
#   The name of the configuration file that isn't found but is required.
#
def config_not_found(config_name)
  puts "Error \"" + config_name+ "\" isn't configured properly"
  exit
end


if ARGV[0].nil? == false and ARGV[0].downcase == '-h' then
  puts "Usage : git build [project_name]"
  puts "\n"
  puts "Config:"
  puts "\tjenkins.url      : The URL Jenkins is available on"
  puts "\tjenkins.token    : The token for the remote build trigger"
  puts "Optional options:"
  puts "\tjenkins.username : Your jenkins username"
  puts "\tjenkins.password : Your jenkins password"
  puts "\tjenkins.job      : The jenkins job that is to be build by default"
  exit
end


begin
  g = Git.open(Dir.pwd)
rescue
  puts "Fatal error git directory not found"
  exit
end

config = g.config

if config['jenkins.url'].nil? then
  config_not_found("jenkins.url")
end

if config['jenkins.token'].nil? then
  config_not_found("jenkins.url")
end

if config['jenkins.job'].nil? and ARGV[0].nil? then
  config_not_found("jenkins.url")
end

if config['jenkins.job'].nil? then
  project_name = ARGV[0]
else
  project_name = config['jenkins.job']
end


uri = URI.parse(config['jenkins.url']+"api/json")


http = Net::HTTP.new(uri.host, uri.port)
request = Net::HTTP::Get.new(uri.request_uri)

if config['jenkins.username'].nil? then
  request.basic_auth(config['jenkins.username'], config['jenkins.password'])
end

response = http.request(request)
json = JSON.parse(response.body)
project_url = nil

json['jobs'].each do |job|
  if job['name'].downcase == project_name.downcase then
    project_url = job['url']
  end
end

if project_url.nil? then
  puts "Invalid project"
  exit
end


buildUri = URI.parse(project_url + 'build/?token=' + config['jenkins.token'])
http = Net::HTTP.new(buildUri.host, buildUri.port)
request = Net::HTTP::Get.new(buildUri.request_uri)

if config['jenkins.username'].nil? then
  request.basic_auth(config['jenkins.username'], config['jenkins.password'])
end

response = http.request(request)
puts "Building " + project_name