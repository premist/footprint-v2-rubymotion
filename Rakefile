# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require "motion/project/template/ios"

begin
  require "bundler"
  Bundler.require
rescue LoadError
end

env_vars = Dotenv.load

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = "next-one"
  app.frameworks += %w(CoreLocation Photos SafariServices)

  app.identifier = ENV["APP_IDENTIFIER"]

  app.info_plist["NSLocationAlwaysUsageDescription"] = "We would like to use your location data."
  app.info_plist["NSLocationWhenInUseUsageDescription"] = "We would like to use your location data."
  app.info_plist["NSMotionUsageDescription"] = "We would like to use your motion data."

  app.pods do
    pod "Firebase"
    pod "Raven"
    pod "SVProgressHUD"
    pod "UIImage-ResizeMagick"
  end

  app.provisioning_profile = ENV["PROVISIONING_PROFILE"]
  app.codesign_certificate = ENV["CODESIGN_CERTIFICATE"]

  # Load environment variables
  env_vars.each { |key, value| app.info_plist["ENV_#{key}"] = value }
end
