def sh(command)
  puts command
  result = `#{command}`
  abort "#{command}\n#{result}" unless $?.success?
  result
end

ppi = 300
width = (2.48 * ppi).to_i
height = (3.48 * ppi).to_i
xoffset = 125
yoffset = 290

sh "rm -rf *.png"
sh "convert -density #{ppi} deck.pdf page-%d.png"

Dir["page-*.png"].each_with_index do |png, pi|
  3.times do |ri|
    3.times do |ci|
      ii = (pi * 9) + (ri * 3) + ci
      sh "convert #{png} -crop #{width}x#{height}+#{xoffset + ci * width}+#{yoffset + ri * height} image-#{ii}.png"
    end
  end
end

Dir["image-*.png"].sort_by { |n| Integer(n[/\d+/]) }.each_slice(2).each_with_index.each do |(a, b), i|
  out = "combined-#{i}.png"
  sh "convert #{a} #{b} +append -units PixelsPerInch -density 300 #{out}"
  sh "convert #{out} -gravity center -background white -extent #{6*ppi}x#{4*ppi} #{out}"
end
