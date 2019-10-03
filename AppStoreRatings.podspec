Pod::Spec.new do |s|
    s.name         = "AppStoreRatings"
    s.version      = "1.0.1"
    s.license      = { :type => "GNU", :file => "LICENSE" }
    s.homepage     = "https://gitlab.dtibcn.cat/osam_pm/modul_valoracions_ios.git"
    s.summary      = "Automatically ask for App Store ratings"
    s.description  = <<-DESC
    Automatically manage the 'App Store ratings and reviews dialog' based on a minimum number of launches and minimum days since first launch
                    DESC
    s.author             = { "Antonio García" => "antonio@openroad.es" }
    s.source       = { :git => "https://gitlab.dtibcn.cat/osam_pm/modul_valoracions_ios.git", :tag => "1.0.1" }
    s.source_files  = "AppStoreRatings/AppStoreRatings/**/*.{swift}"
    s.requires_arc = true

    s.platform     = :ios
    s.ios.deployment_target = "11.0"

    s.frameworks = "Foundation", "StoreKit"
    s.swift_version = "5.0"

end
