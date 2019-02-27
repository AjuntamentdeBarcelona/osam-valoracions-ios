
Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.name         = "AppStoreRatings"
  s.version      = "1.0.0"
  s.summary      = "Automatically ask for App Store ratings"
  s.description  = <<-DESC
   Automatically manage the 'App Store ratings and reviews dialog' based on a minimum number of launches and minimum days since first launch
                   DESC
  s.homepage     = "https://gitlab.dtibcn.cat/osam_pm/modul_valoracions_ios.git"

  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.license      = { :type => "GNU", :file => "LICENSE" }

  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.author             = { "Antonio García" => "antonio@openroad.es" }

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.platform     = :ios 
  s.ios.deployment_target = "11.0"

  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source       = { :git => "https://gitlab.dtibcn.cat/osam_pm/modul_valoracions_ios.git", :tag => "1.0.0" }

  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source_files  = "AppStoreRatings/AppStoreRatings/**/*.{swift}"

  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.frameworks = "Foundation", "StoreKit"

end
