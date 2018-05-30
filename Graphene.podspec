Pod::Spec.new do |s|
  s.name               = 'Graphene'
  s.version            = '0.0.1'
  s.summary            = 'Graphene is an implementation of Graphene Blockchain protocol in Objective-C.'
    s.description  = <<-DESC
                   Graphene is a toolkit to work with Graphene blockchain.
                   DESC
  s.homepage           = 'https://github.com/gxchain/Graphene'
  s.license            = 'BSD'
  s.authors            = { 'lanhaoxiang' => 'lanhaoxiang@qq.com'}
  s.source             = { :git => 'https://github.com/gxchain/Graphene.git', :tag => s.version.to_s }
  s.ios.deployment_target = '7.0'
  s.osx.deployment_target = '10.9'
  s.source_files = 'Graphene/**/*.{h,m}'
  s.public_header_files = 'Graphene/**/*.h'
  s.exclude_files = ['GrapheneTests/**/*.{h,m}']
  s.requires_arc  = true
  s.framework    = 'Foundation'
  s.ios.framework = 'UIKit'
  s.osx.framework = 'AppKit'
  s.dependency 'OpenSSL-Universal'
  s.dependency 'SocketRocket'
end