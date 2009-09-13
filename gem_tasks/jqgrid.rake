require 'fileutils'
require 'lib/handle_js_files'

# Compass generator for jqGrid 3.5+
JQGRID_SRC = File.join(GEM_ROOT, 'src', 'jqgrid')
JQGRID_SRC_TRANSLATIONS = File.join(JQGRID_SRC, 'js', 'i18n') + "/*.js"

JQGRID_DEST_TEMPLATES = File.join(GEM_ROOT, 'templates', 'jqgrid')
JQGRID_DEST_STYLESHEETS = File.join(JQGRID_DEST_TEMPLATES, 'jquery.ui')
JQGRID_DEST_TRANSLATIONS = File.join(JQGRID_DEST_TEMPLATES, 'i18n', 'jqgrid')

JQGRID_MESSAGE1 = "# Generated by compass-jquery-plugin/gem-tasks/jqgrid.rake\n# Install with: compass -f jquery -p jqgrid\n\n"
JQGRID_MESSAGE2 = "// Generated by compass-jquery-plugin/gem-tasks/jqgrid.rake\n\n"

all_scripts = [
  'js/grid.base.js',
  'js/grid.celledit.js',
  'js/grid.common.js',
  'js/grid.custom.js',
  'js/grid.formedit.js',
  'js/grid.import.js',  
  'js/grid.inlinedit.js',
  'js/grid.postext.js',
  'js/grid.setcolumns.js',
  'js/grid.subgrid.js',
  'js/grid.tbltogrid.js',
  'js/grid.treegrid.js',
  'js/jqDnR.js',
  'js/jqModal.js',
  'js/jquery.fmatter.js',
  'js/jquery.searchFilter.js',
  'js/JsonXml.js',
  'plugins/jquery.contextmenu.js',
  'plugins/jquery.tablednd.js'
].collect {|filename| File.read(File.join(JQGRID_SRC, filename))}.join "\n\n"

all_stylesheets = [
  'ui.jqgrid.css',
  'jquery.searchFilter.css'
].collect {|filename| File.read(File.join(JQGRID_SRC, 'css', filename))}.join "\n\n"

namespace :jqgrid do
  desc 'Build the stylesheets and templates for jqGrid.'
  task :build do
    
    FileUtils.remove_dir JQGRID_DEST_TEMPLATES if File.exists? JQGRID_DEST_TEMPLATES   
    FileUtils.mkdir_p(File.join(JQGRID_DEST_TEMPLATES, 'config', 'initializers'))
    
    open File.join(JQGRID_DEST_TEMPLATES, 'manifest.rb'), 'w' do |manifest|
      manifest.print JQGRID_MESSAGE1
    
      open File.join(JQGRID_DEST_TEMPLATES, 'config', 'initializers', 'jqgrid.rb'), 'w' do |f|
        f.print(File.read(File.join(JQGRID_SRC, 'config', 'initializers', 'jqgrid.rb')))
      end
      manifest.print "file 'config/initializers/jqgrid.rb'\n"  
    
      open File.join(JQGRID_DEST_TEMPLATES, 'jquery.jqGrid.js'), 'w' do |f|
        f.print concat_files(all_scripts)
      end
      manifest.print "javascript 'jquery.jqGrid.js'\n"
    
      open File.join(JQGRID_DEST_TEMPLATES, 'jquery.jqGrid.min.js'), 'w' do |f|
        f.print compress_js(all_scripts)
      end
      manifest.print "javascript 'jquery.jqGrid.min.js'\n"

      ['i18n'].each do |path|
        FileUtils.mkdir_p File.join(JQGRID_DEST_TRANSLATIONS)
        Dir.foreach File.join(JQGRID_SRC, 'js', path) do |file|
          next unless /\.js$/ =~ file
          js = File.read File.join(JQGRID_SRC, 'js', path, file)
          file.gsub!(/^grid\./,'')          
          manifest.print "javascript '#{File.join(path, 'jqgrid', file)}'\n"
          open File.join(JQGRID_DEST_TRANSLATIONS, file), 'w' do |f|
            f.write js
          end               
          file.gsub!(/\.js$/, '.min.js')
          manifest.print "javascript '#{File.join(path, 'jqgrid', file)}'\n"
          open File.join(JQGRID_DEST_TRANSLATIONS, file), 'w' do |f|
            f.write compress_js(js)
          end
        end
      end
    
      FileUtils.mkdir_p File.join(JQGRID_DEST_STYLESHEETS)
      open File.join(JQGRID_DEST_STYLESHEETS, 'jqGrid.sass'), 'w' do |f|
        sass = JQGRID_MESSAGE2 
        IO.popen("css2sass", 'r+') { |ff| ff.print(all_stylesheets); ff.close_write; sass += ff.read }
        f.print sass
      end
      manifest.print "stylesheet 'jquery.ui/jqGrid.sass'\n"
    end
  end
end