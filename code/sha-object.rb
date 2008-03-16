def put_raw_object(content, type, git_obj_dir = nil)
  git_obj_dir = (ENV['GIT_DIR'], 'objects') if !git_obj_dir
  
  size = content.length.to_s
  
  if !%w(blob tree commit tag).include?(type) || size !~ /^\d+$/
    raise LooseObjectError, "invalid object header"
  end
  
  header = "#{type} #{size}\0"
  store = header + content
            
  sha1 = Digest::SHA1.hexdigest(store)
  path = git_obj_dir+'/'+sha1[0...2]+'/'+sha1[2..40]
  
  content = Zlib::Deflate.deflate(store)

  FileUtils.mkdir_p(git_obj_dir+'/'+sha1[0...2])
  File.open(path, 'w') do |f|
    f.write content
  end

  return sha1
end