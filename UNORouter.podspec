
Pod::Spec.new do |s|

  s.name         = "UNORouter"
  s.version      = "0.0.1"
  s.summary      = "UNORouter is a iplementation of routing technology"

  s.homepage     = "http://sass.lianyuplus.com.cn"
  s.license      = "MIT"
  s.authors      = { "unovo" => "dev.lianyu@unovo.com.cn" }

  s.platform     = :ios, "5.0"
  s.source       = { :path  => 'UNORoute' }
  s.source_files  = "**/*.{h,m}"

  s.public_header_files = "*.h"

  s.requires_arc = true
  s.xcconfig = { "HEADER_SEARCH_PATHS" => "${SRCROOT}/../../UNOCommonUtl/UNORoute/UNORoute/UNO_Router.h " }

end
