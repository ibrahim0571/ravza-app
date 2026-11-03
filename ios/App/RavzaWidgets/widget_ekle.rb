# Ravza iOS: RavzaWidgets (WidgetKit) eklenti hedefini Xcode projesine ekler. CI'da pod install'dan ÖNCE çalışır.
# Tekrar çalışırsa hiçbir şey yapmaz. İmza: WIDGET_PROFIL + TEAM_ID ortam değişkenleri varsa elle imza.
require 'xcodeproj'
proj = Xcodeproj::Project.open(File.join(__dir__, '..', 'App.xcodeproj'))
if proj.targets.any? { |t| t.name == 'RavzaWidgets' }
  puts 'RavzaWidgets zaten var'; exit 0
end
app = proj.targets.find { |t| t.name == 'App' }
ext = proj.new_target(:app_extension, 'RavzaWidgets', :ios, '16.0')
grup = proj.main_group.find_subpath('RavzaWidgets', true)
grup.set_source_tree('<group>'); grup.set_path('RavzaWidgets')
kaynak = grup.new_reference('RavzaWidgets.swift')
grup.new_reference('Info.plist')
ext.add_file_references([kaynak])
ext.add_system_framework(%w[WidgetKit SwiftUI])
a = app.build_configurations.first.build_settings
ext.build_configurations.each do |c|
  s = c.build_settings
  s['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.ibrahimaktas.ravza.widgets'
  s['PRODUCT_NAME'] = '$(TARGET_NAME)'
  s['INFOPLIST_FILE'] = 'RavzaWidgets/Info.plist'
  s['GENERATE_INFOPLIST_FILE'] = 'NO'
  s['SWIFT_VERSION'] = '5.0'
  s['IPHONEOS_DEPLOYMENT_TARGET'] = '16.0'
  s['TARGETED_DEVICE_FAMILY'] = '1,2'
  s['MARKETING_VERSION'] = a['MARKETING_VERSION']
  s['CURRENT_PROJECT_VERSION'] = a['CURRENT_PROJECT_VERSION']
  s['SKIP_INSTALL'] = 'YES'
  s['APPLICATION_EXTENSION_API_ONLY'] = 'YES'
  s['LD_RUNPATH_SEARCH_PATHS'] = ['$(inherited)', '@executable_path/Frameworks', '@executable_path/../../Frameworks']
  s['DEVELOPMENT_LANGUAGE'] = 'tr'
  if ENV['WIDGET_PROFIL'] && !ENV['WIDGET_PROFIL'].empty?
    s['CODE_SIGN_STYLE'] = 'Manual'
    s['DEVELOPMENT_TEAM'] = ENV['TEAM_ID']
    s['PROVISIONING_PROFILE_SPECIFIER'] = ENV['WIDGET_PROFIL']
    s['CODE_SIGN_IDENTITY'] = 'iPhone Distribution'
  end
end
gom = app.new_copy_files_build_phase('Embed Foundation Extensions')
gom.symbol_dst_subfolder_spec = :plug_ins
bf = gom.add_file_reference(ext.product_reference, true)
bf.settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }
app.add_dependency(ext)
proj.save
puts "RavzaWidgets eklendi (#{a['MARKETING_VERSION']} / #{a['CURRENT_PROJECT_VERSION']})"
