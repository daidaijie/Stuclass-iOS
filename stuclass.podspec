Pod::Spec.new do |s|
  s.name         = 'stuclass'
  s.version      = '<#Project Version#>'
  s.license      = '<#License#>'
  s.homepage     = '<#Homepage URL#>'
  s.authors      = '<#Author Name#>': '<#Author Email#>'
  s.summary      = '<#Summary (Up to 140 characters#>'

  s.platform     =  :ios, '<#iOS Platform#>'
  s.source       =  git: '<#Github Repo URL#>', :tag => s.version
  s.source_files = '<#Resources#>'
  s.frameworks   =  '<#Required Frameworks#>'
  s.requires_arc = true
  
# Pod Dependencies
  s.dependencies =	pod 'KVNProgress'
  s.dependencies =	pod 'AFNetworking', '~> 2.5'
  s.dependencies =	pod 'SDWebImage'
  s.dependencies =	pod 'MGSwipeTableCell'
  s.dependencies =	pod 'SIAlertView'
  s.dependencies =	pod 'UITableView+FDTemplateLayoutCell'
  s.dependencies =	pod 'IDMPhotoBrowser'
  s.dependencies =	pod 'UIImageView-PlayGIF', '~> 1.0.1'
  s.dependencies =	pod 'BmobSDK'
  s.dependencies =	pod 'SDVersion'

end