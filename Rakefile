
$: << 'vendor/isolate-3.2.2/lib/'

require 'rubygems'
require 'isolate/now'
require 'RedCloth'
require 'erb'

##
# Override RedCloth directly to parse blocks and call internal methods
# when needed.

class RedCloth

  def blocks( text, deep_code = false )
    text.replace( text.split( BLOCKS_GROUP_RE ).collect do |blk|
      plain = blk !~ /\A[#*> ]/

      # skip blocks that are complex HTML
      if blk =~ /^<\/?(\w+).*>/ and not SIMPLE_HTML_TAGS.include? $1
        blk
      else
        # search for indentation levels
        blk.strip!
        if blk.empty?
          blk
        else
          code_blk = nil
          blk.gsub!( /((?:\n(?:\n^ +[^\n]*)+)+)/m ) do |iblk|
            flush_left iblk
            blocks iblk, plain
            iblk.gsub( /^(\S)/, "\t\\1" )
            if plain
              code_blk = iblk; ""
            else
              iblk
            end
          end

          block_applied = 0
          @rules.each do |rule_name|
            block_applied += 1 if ( rule_name.to_s.match /^block_/ and method( rule_name ).call( blk ) )
          end
          if block_applied.zero?
            if deep_code
              blk = textile_code('code', '', '', blk)
            else
              blk = textile_p('p', '', '', blk)
            end
          end
          # hard_break blk
          blk + "\n#{ code_blk }"
        end
      end

    end.join( "\n\n" ) )
  end

end


##
# Produces HTML with some extra Textile tags.

class WhiteCloth < RedCloth

  module VERSION
    MAJOR = 0
    MINOR = 0
    TINY  = 1

    STRING = [MAJOR, MINOR, TINY].join('.')
  end

  # Matches "es" in "code_review-es"
  PROJECT_LANGUAGE_RE = /-(.{2})$/

  ##
  # +text+          The text to be transformed into tagged text.
  # +project_path+  The path to the root of the project.
  #                 Should contain a +code+ directory that will
  #                 be used to insert code files from language-specific
  #                 includes.

  def initialize(text, project_path)

    @chapter_count = 1
    @project_path  = project_path.strip
    @code_path     = @project_path + "/code"
    @language      = "en"
    if @project_path =~ PROJECT_LANGUAGE_RE
      @language = $1
    end

    # Pre-cleanup of smart quotes back to regular quotes.
    text.gsub!('”','"')
    text.gsub!('“','"')
    text.gsub!('’',"'")
    text.gsub!('‘',"'")

    super(text)
  end

  def to_html(*rules)
    content = super
    content = post_cleanup_hacks(content)
    # template = File.read(File.dirname(__FILE__) + "/../layout/application.html.erb")
    # result   = ERB.new(template).result(binding)
    result = content
    # HACK
    result.gsub!(/&amp;nbsp;/, "&nbsp;")
    return result
  end

  def post_cleanup_hacks(text)
    text.gsub!('&amp;lt;', '&lt;')
    text.gsub!('&amp;gt;', '&gt;')
    text
  end

  #####################################
  # Custom tags
  ##

  def textile_note(tag, atts, cite, content)
    %Q{<div class="note">#{content}</div>}
  end

  def textile_todo(tag, atts, cite, content)
    %Q{<strong class="todo">TODO #{content} TODO</strong>}
  end

  def textile_code( tag, atts, cite, content )
    content = render_code(content)
    tt_code_block('', apply_code_syntax(content))
  end

  def textile_ruby( tag, atts, cite, content )
    content = render_code(content)
    tt_code_block('ruby', apply_syntax(content, 'ruby'))
  end

  def textile_html( tag, atts, cite, content )
    content = render_code(content)
    tt_code_block('html', apply_syntax(content, 'html'))
  end
  
  def textile_javascript( tag, atts, cite, content )
    content = render_code(content)
    tt_code_block('javascript', apply_syntax(content, 'javascript'))
  end

  def textile_erb( tag, atts, cite, content )
    content = render_code(content)
    tt_code_block('erb', apply_syntax(content, 'erb'))
  end

  def textile_yaml( tag, atts, cite, content )
    content = render_code(content)
    tt_code_block('yaml', apply_syntax(content, 'yaml'))
  end

  def textile_shell( tag, atts, cite, content )
    content = render_code(content)
    tt_code_block('shell', apply_syntax(content, 'shell'))
  end

  ##
  # Tagged text helper for code paragraphs.

  def tt_code_block(language, content)
    language = " #{language}" if language.length > 0
    "<pre><code class='#{language}'>#{ content }</code></pre>"
  end

  # TODO
  def apply_code_syntax(text)
    text.gsub('<', '&lt;').gsub('>', '&gt;')
  end

  ##
  # Run the Syntax gem on code.
  #
  #   apply_syntax('bunch_of_code', 'ruby')

  def apply_syntax(text, *languages)
    # TODO
    return apply_code_syntax(text)
  end

  # A string with up to 5 characters as an extension
  # and optional hashmark.
  #
  #  my_app/spec/models/user_spec.rb#first_section

  FILE_EXTENSION_RE = /(.+\.\w{1,5})(#(\S+))?\s*$/

  ##
  # If +text+ represents a file, read that file from the code directory
  # and return its contents for further syntax highlighting.
  #
  # Otherwise return the text itself.

  def render_code(text)
    if text =~ FILE_EXTENSION_RE
      filename = $1.strip
      section_name = $3
      lines = get_localized_or_original_file_contents(filename)

      if lines.length > 0
        if section_name
          section_name.strip!
          # Eat equal amounts of leading whitespace
          leading_whitespace = ''

          in_section = false
          text = ''
          lines.each do |line|
            case line
            when %r{^\s*# BEGIN #{section_name}\s*$}
              in_section = true
              if line =~ /^(\s+)/
                leading_whitespace = $1
              end

              next
            when %r{\s*# END #{section_name}}
              in_section = false
            end
            text << line.gsub(%r{^#{leading_whitespace}}, '') if in_section
          end
        else
          text = lines.join("")
        end
      end
    end

    # escape_angle_brackets(text) # Should be handled by syntax highlighter
    text
  end

  ##
  # A project can store code in the "code" directory or override it in
  # a localized directory matching the project's language name,
  # such as "code-es" or "code-fr."

  def get_localized_or_original_file_contents(relative_filename)
    filename_in_localized_code_dir = "#{@code_path}-#{@language}/#{relative_filename}"
    if File.exist?(filename_in_localized_code_dir)
      return File.readlines(filename_in_localized_code_dir)
    else
      filename_in_code_dir = "#{@code_path}/#{relative_filename}"
      if File.exist?(filename_in_code_dir)
        return File.readlines(filename_in_code_dir)
      end
    end
    # Return blank array on failure to find file
    []
  end

end

OUTPUT = File.dirname(__FILE__) + "/build"
INPUT  = File.dirname(__FILE__) + "/text"

desc "Generate document as HTML"
task :build do
  FileUtils.mkdir(OUTPUT) unless File.exists?(OUTPUT)
  Dir["#{INPUT}/*.textile"].each do |f|
    basename = File.basename(f).gsub!(/.textile$/, ".html")
    File.open(File.join(OUTPUT, basename), "w") do |tempfile|
      tempfile.puts WhiteCloth.new(File.read(f), File.dirname(__FILE__)).to_html
    end
  end
  $stdout.puts "Rendered HTML to ./build"
end

desc "Cleanup 'output' directory"
task :clean do
  FileUtils.rm_rf(OUTPUT)
end

task :default => :build
