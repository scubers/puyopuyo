#
# Be sure to run `pod lib lint Puyopuyo.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Puyopuyo'
  s.version="1.0.0"
  s.summary          = 'A reactive layout library for swift.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
                        A reactive layout library for swift.
                       DESC

  s.homepage         = 'https://github.com/Jrwong/Puyopuyo'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Jrwong' => 'jr-wong@qq.com' }
  s.source           = { :git => 'https://github.com/scubers/puyopuyo.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'
  s.swift_version = '5.1'
  
  s.public_header_files = 'Puyopuyo/Classes/**/*.h'
  s.source_files = [
    'Puyopuyo/Classes/Core/**/*.{h,m,swift}',
    'Puyopuyo/Classes/Util/**/*.{h,m,swift}',
    'Puyopuyo/Classes/View/**/*.{h,m,swift}'
  ]
  # s.subspec 'Util' do |c|
  #   c.public_header_files = 'Puyopuyo/Classes/Util/**/*.h'
  #   c.source_files = 'Puyopuyo/Classes/Util/**/*.{h,m,swift}'
  # end
  
  # s.subspec 'Core' do |c|
  #   c.source_files = 'Puyopuyo/Classes/Core/**/*.{h,m,swift}'
  #   c.dependency 'Puyopuyo/Util'
  # end
  
  # s.subspec 'View' do |c|
  #   c.source_files = 'Puyopuyo/Classes/View/**/*.{h,m,swift}'
  #   c.dependency 'Puyopuyo/Core'
  # end
  
  # s.default_subspec = 'View'
  
  # s.subspec 'TangramKit' do |c|
  #     c.source_files = 'Puyopuyo/Classes/TangramKit/**/*.{h,m,swift}'
  #     c.dependency 'Puyopuyo/View'
  #     c.dependency 'TangramKit'
  # end
  
  
  # s.resource_bundles = {
  #   'Puyopuyo' => ['Puyopuyo/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
#  s.dependency 'YogaKit', '~> 1.14.0'

end
