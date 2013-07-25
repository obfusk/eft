desc 'Run specs'
task :spec do
  puts 'No automated tests yet - please manually test the example'
  # sh 'rspec -c'
end

desc 'Run specs verbosely'
task 'spec:verbose' do
  puts 'No automated tests yet - please manually test the example'
  # sh 'rspec -cfd'
end

desc 'Run specs verbosely, view w/ less'
task 'spec:less' do
  puts 'No automated tests yet - please manually test the example'
  # sh 'rspec -cfd --tty | less -R'
end

desc 'Check for warnings'
task :warn do
  sh 'ruby -w -I lib -I ../rb-obfusk-util/lib -r eft -e ""'
end

desc 'Run example'
task :example do
  sh 'ruby -w -I lib -I ../rb-obfusk-util/lib example.rb'
end

desc 'Generate docs'
task :docs do
  sh 'yardoc | cat'
end

desc 'List undocumented objects'
task 'docs:undoc' do
  sh 'yard stats --list-undoc'
end

desc 'Cleanup'
task :clean do
  sh 'rm -rf .yardoc/ doc/ *.gem'
end

desc 'Build SNAPSHOT gem'
task :snapshot do
  v = Time.new.strftime '%Y%m%d%H%M%S'
  f = 'lib/eft/version.rb'
  sh "sed -ri~ 's!(SNAPSHOT)!\\1.#{v}!' #{f}"
  sh 'gem build eft.gemspec'
end

desc 'Undo SNAPSHOT gem'
task 'snapshot:undo' do
  sh 'git checkout -- lib/eft/version.rb'
end
