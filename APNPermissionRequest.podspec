Pod::Spec.new do |s|
  s.name             = "APNPermissionRequest"
  s.version          = "0.1.3"
  s.summary          = "APNPermissionRequest informs users about the purpose of your app's push notifications and enables users to choose their preferred type."
  s.description      = <<-DESC
                       Requests for enabling push notifications are quite meaningless. People are often wondering for what purpose your app wants to send push notifications. If the reason is not obvious, they will likely deny the request. This is bad.
                       
                       APNPermissionRequest features:

                       * ability to explain the purpose of your app's push notifications
                       * users may select the type of notifications they want to receive
                       DESC
  s.homepage         = "https://github.com/tilowestermann/APNPermissionRequest"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Tilo Westermann" => "tilo.westermann@tu-berlin.de" }
  s.source           = { :git => "https://github.com/tilowestermann/APNPermissionRequest.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/tilowestermann'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  #s.resources = "Pod/Assets/APNPermissionRequestImages.xcassets"
  s.ios.resource_bundle = { 'APNPermissionRequest' => 'Pod/Assets/**/*.png' }

  s.frameworks = 'UIKit'
  s.dependency 'SDCAlertView', '~> 2.4'
end
