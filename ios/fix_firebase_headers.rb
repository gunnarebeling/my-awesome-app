#!/usr/bin/env ruby

require 'fileutils'

def fix_header_imports(file_path)
  if File.exist?(file_path)
    puts "Fixing imports in #{file_path}"
    content = File.read(file_path)
    
    # Replace direct Firebase.h imports with @import Firebase;
    modified_content = content.gsub(/#import <Firebase\/Firebase.h>/, '@import Firebase;')
    modified_content = modified_content.gsub(/#import "Firebase\/Firebase.h"/, '@import Firebase;')
    
    # Write back the modified content
    File.write(file_path, modified_content)
    puts "Fixed #{file_path}"
  else
    puts "Warning: File not found: #{file_path}"
  end
end

# Define paths to the problematic header files
plugin_cache_dir = File.expand_path('~/.pub-cache/hosted/pub.dev')

# Fix firebase_crashlytics headers
crashlytics_dir = Dir.glob("#{plugin_cache_dir}/firebase_crashlytics-*/ios/Classes").first
if crashlytics_dir
  fix_header_imports("#{crashlytics_dir}/Crashlytics_Platform.h")
  fix_header_imports("#{crashlytics_dir}/ExceptionModel_Platform.h")
else
  puts "Crashlytics plugin directory not found"
end

# Fix firebase_messaging headers
messaging_dir = Dir.glob("#{plugin_cache_dir}/firebase_messaging-*/ios/Classes").first
if messaging_dir
  fix_header_imports("#{messaging_dir}/FLTFirebaseMessagingPlugin.h")
else
  puts "Messaging plugin directory not found"
end

puts "Header fixing completed."
