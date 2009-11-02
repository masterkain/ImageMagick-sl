require 'RMagick'

if !ARGV[0]
    puts "Usage: test.rb path-to-image"
    exit
end

image = Magick::Image.read(ARGV[0]).first
image.border!(18, 18, "#f0f0ff")
out = ARGV[0].sub(/\./, "-print.")
puts "Writing #{out}"
image.write(out)