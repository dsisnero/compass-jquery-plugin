require 'fileutils'
require 'lib/handle_js_files'

# Compass generator for jqGrid 3.5+
SECRET_SAUCE_SRC         = File.join(GEM_ROOT, 'src', 'secret_sauce')
SECRET_SAUCE_SRC_SCRIPTS = SECRET_SAUCE_SRC + "/*.js"

SECRET_SAUCE_DEST_TEMPLATES   = File.join(GEM_ROOT, 'templates', 'secret_sauce')
SECRET_SAUCE_DEST_STYLESHEETS = File.join(SECRET_SAUCE_DEST_TEMPLATES, 'jquery.ui')
SECRET_SAUCE_DEST_CONFIG      = File.join(SECRET_SAUCE_DEST_TEMPLATES, 'config', 'initializers') 
SECRET_SAUCE_DEST_VIEWS       = File.join(SECRET_SAUCE_DEST_TEMPLATES, 'app', 'views', 'ui')

SECRET_SAUCE_MESSAGE1 = "# Generated by compass-jquery-plugin/gem-tasks/secret_sauce.rake\n# Install with: compass -f jquery -p secret_sauce\n\n"
SECRET_SAUCE_MESSAGE2 = "// Generated by compass-jquery-pluginy/gem-tasks/secret_sauce.rake\n\n"

namespace :build do
  desc 'Build the stylesheets and templates for jqGrid.'
  task :secret_sauce do
    
    FileUtils.remove_dir SECRET_SAUCE_DEST_TEMPLATES if File.exists? SECRET_SAUCE_DEST_TEMPLATES 
    FileUtils.mkdir_p SECRET_SAUCE_DEST_CONFIG
    FileUtils.mkdir_p SECRET_SAUCE_DEST_VIEWS
    
    open File.join(SECRET_SAUCE_DEST_TEMPLATES, 'manifest.rb'), 'w' do |manifest|
      manifest.print SECRET_SAUCE_MESSAGE1
    
      Dir.foreach File.join(SECRET_SAUCE_SRC, 'app', 'views', 'ui') do |file|
        next unless /\.haml$/ =~ file
        html = File.read File.join(SECRET_SAUCE_SRC, 'app', 'views', 'ui', file)
        open File.join(SECRET_SAUCE_DEST_VIEWS, file), 'w' do |f|
          f.print(html)
        end
        manifest.print "file 'app/views/ui/#{file}'\n"
      end      
    
      open File.join(SECRET_SAUCE_DEST_TEMPLATES, 'config', 'initializers', 'secret_sauce.rb'), 'w' do |f|
        f.print(File.read(File.join(SECRET_SAUCE_SRC, 'config', 'initializers', 'secret_sauce.rb')))
      end
      manifest.print "file 'config/initializers/secret_sauce.rb'\n"  
    
      open File.join(SECRET_SAUCE_DEST_TEMPLATES, 'secret_sauce.js'), 'w' do |f|
        f.print concat_files(all_files(SECRET_SAUCE_SRC_SCRIPTS))
      end
      manifest.print "javascript 'secret_sauce.js'\n"
    
      open File.join(SECRET_SAUCE_DEST_TEMPLATES, 'secret_sauce.min.js'), 'w' do |f|
        f.print compress_js(all_files(SECRET_SAUCE_SRC_SCRIPTS))
      end
      manifest.print "javascript 'secret_sauce.min.js'\n"
    
      FileUtils.mkdir_p SECRET_SAUCE_DEST_STYLESHEETS
      Dir.foreach File.join(SECRET_SAUCE_SRC, 'css') do |file|
        next unless /\.css$/ =~ file
        css = File.read File.join(SECRET_SAUCE_SRC, 'css', file)
        sass = ''
        IO.popen("css2sass", 'r+') { |f| f.print(css); f.close_write; sass = f.read }
        open(File.join(SECRET_SAUCE_DEST_STYLESHEETS, file.gsub(/\.css$/,'.sass')), 'w') do |f|
          f.write SECRET_SAUCE_MESSAGE2 + sass
        end
        manifest.print "stylesheet 'jquery.ui/#{file.gsub(/\.css$/,'.sass')}'\n"
      end      
    end
  end
end