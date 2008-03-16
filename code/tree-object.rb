def write_tree(dir)
  Dir.chdir(dir) do
    tree_contents = ''
    
    files = Dir.glob("*")
    files.each do |file|
      if File.directory?(file)
        # recurse for a subdirectory
        sha = write_tree(File.join(dir, file)) 
        mode = '040000'
      else
        sha = put_raw_object(file) # from the previous sidebar 
        mode = sprintf("%o", File.stat(file).mode)
      end
      
      sha_hex = [sha].pack("H*") # hex of sha value
      str = "%s %s\0%s" % [mode, file, sha_hex]
            
      tree_contents += str
    end
  end

  tree_sha = put_raw_object(tree_contents, 'tree')    
  
  return tree_sha
end

