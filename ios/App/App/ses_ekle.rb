# 26 Kas (İbrahim: "Ravza zili Klasik, üye değişebilsin"): App/Sesler/*.caf bildirim seslerini ana uygulama paketine
# (Copy Bundle Resources) ekler. UNNotificationSound(named:) yalnız uygulama paketindeki (ya da Library/Sounds) dosyayı çalar.
# Tekrar çalışırsa var olanı eklemez. CI'da widget_ekle.rb'den sonra, pod install'dan önce çalışır.
require 'xcodeproj'
proj = Xcodeproj::Project.open(File.join(__dir__, '..', 'App.xcodeproj'))
app = proj.targets.find { |t| t.name == 'App' }
ag = proj.main_group.find_subpath('App', false)
sg = ag.children.find { |c| c.respond_to?(:path) && c.path == 'Sesler' } || ag.new_group('Sesler', 'Sesler')
eklenen = 0
Dir[File.join(__dir__, '..', 'App', 'Sesler', '*.caf')].sort.each do |f|
  ad = File.basename(f)
  next if sg.files.any? { |x| x.path == ad }
  ref = sg.new_reference(ad)
  app.resources_build_phase.add_file_reference(ref, true)
  eklenen += 1
end
proj.save
puts "zil sesi eklendi: #{eklenen}"
