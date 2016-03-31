task :icons do

  puts "Please provide me with an image"
  url = STDIN.gets.chomp
  
  sizes = %w(16x16 32x32 57x57 72x72 76x76 96x96 114x114 120x120 128x128 144x144 152x152 180x180 192x192)
  output_folder = File.dirname url

  
  sizes.each do |size|
    filename = "#{output_folder}/icon-#{size}.png"
    File.delete(filename) if File.exists? filename
    image = MiniMagick::Image.open(url)
    image.resize size
    image.format "png"
    image.quality 90
    image.write filename

    puts "Writing #{filename}"
  end

end