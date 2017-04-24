Pod::Spec.new do |s|

  s.name         = "TCDownloader"
  s.version      = "0.0.2"
  s.summary      = "音频下载器"
  s.homepage     = "https://github.com/TardisCXX/TCDownloader"
  s.license      = "MIT"
  s.author             = { "TardisCXX" => "email@address.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/TardisCXX/TCDownloader.git", :tag => s.version }
  s.source_files  = "TCDownloader", "TCDownloaderProject/TCDownloader/*.{h,m}"
  s.requires_arc = true

end
