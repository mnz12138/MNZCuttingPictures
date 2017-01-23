Pod::Spec.new do |s|
  s.name         = "MNZCuttingPictures"
  s.version      = "0.0.1"
  s.summary      = "传入一张图片，裁切成正方形的图片。"
  s.homepage     = "https://github.com/mnz12138/MNZCuttingPictures"
  s.license      = "MIT"
  s.author             = { "Apollo" => "email@address.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/mnz12138/MNZCuttingPictures.git", :tag => s.version }
  s.source_files  = "MNZCuttingPictures", "裁切图片/裁切图片/MNZCuttingPictures/*.{h,m}"
  s.requires_arc = true
end
