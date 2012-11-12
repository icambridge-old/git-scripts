#!/usr/bin/env ruby1.9.1

##########################
# Scirpt  : Jenkins Build Trigger
# Author  : Iain Cambridge (http://github.com/icambridge)
# License : MIT
##########################



require 'net/http'
require 'json'
require 'git'

if ARGV[0].nil? then
  puts "A project name is required"
  exit
end

g = Git.open(Dir.pwd)

config =  g.config

uri = URI.parse(config['jenkins.url']+"api/json")


http = Net::HTTP.new(uri.host, uri.port)
request = Net::HTTP::Get.new(uri.request_uri)

if config['jenkins.username'].nil? then
  request.basic_auth(config['jenkins.username'], config['jenkins.password'])
end

response = http.request(request)
json = JSON.parse(response.body)
project_url = nil
project_name  = ARGV[0]

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
request.basic_auth(config['jenkins.username'], config['jenkins.password'])
response = http.request(request)
puts "Building " + project_name