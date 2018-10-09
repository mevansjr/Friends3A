Pod::Spec.new do |s|
 s.name = 'Friends3A'
 s.version = '0.0.1'
 s.license = { :type => "MIT", :file => "LICENSE" }
 s.summary = 'Friends Module'
 s.homepage = 'https://3advance.com'
 s.social_media_url = 'https://twitter.com/3Advance'
 s.authors = { "Mark Evans" => "mark@3advance.com" }
 s.source = { :git => "https://github.com/3Advance/Friends3A.git", :tag => "v"+s.version.to_s }
 s.platforms = { :ios => "9.0", :osx => "10.10", :tvos => "9.0", :watchos => "2.0" }
 s.requires_arc = true

 s.default_subspec = "Core"
 s.subspec "Core" do |ss|
     ss.source_files  = "Sources/**/*.swift"
     ss.framework  = "Foundation"
     ss.framework  = "UIKit"
     ss.framework  = "MessageUI"
     ss.framework  = "Contacts"
     ss.framework  = "ContactsUI"
 end
end
