Pod::Spec.new do |s|
  s.name         = "DateSelector"
  s.version      = "0.0.7"
  s.summary      = "A swift date selector."
  s.description  = <<-DESC
	一個簡易的日期選擇套件，並帶有 UICollectionView 左右滑動頁面之功能。
                   DESC
  s.homepage     = "https://github.com/jexwang/DateSelector"
  s.license      = "MIT"
  s.author       = { "Jay" => "jexwang@icloud.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/jexwang/DateSelector.git", :tag => "#{s.version}" }
  s.source_files = "DateSelector/DateSelector.swift", "DateSelector/AppDelegate.swift"
  s.framework    = "UIKit"
end
