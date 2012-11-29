#!/usr/bin/env ruby1.9.1

require 'git'

begin
  git = Git.open(Dir.pwd)
rescue
  puts "Fatal error git directory not found"
  exit
end

if ARGV[0].nil?
  puts "Need remote"
  exit
end

remote = ARGV[0]

remotes = []
git.remotes.map do |repo|
  remotes.push repo.name
end

if !remotes.include?(remote)
  puts "Invalid remote repository"
  exit
end

current_branch = git.current_branch

puts git.push(remote, current_branch)