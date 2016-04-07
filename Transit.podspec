Pod::Spec.new do |s|
  s.name         = "Transit"
  s.version      = "0.0.1"
  s.summary      = "easy custom ios transition"
  s.description  = <<-DESC
  Transit is the library provide you an easiest way to customize the animation when you change from one ViewController to another.
  You can think of this library as transit system, travel from one station to other station with trains in various lines.
                   DESC
  s.homepage     = "https://github.com/zoonooz/Transit"
  s.screenshots  = "https://raw.githubusercontent.com/zoonooz/Transit/master/line_animation.gif"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Amornchai Kanokpullwad" => "amornchai.zoon@gmail.com" }
  s.social_media_url   = "http://twitter.com/zoonref"
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/zoonooz/Transit.git", :tag => "0.0.1" }
  s.source_files  = "Source"
end
