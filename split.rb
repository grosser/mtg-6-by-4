def sh(command)
  puts command
  result = `#{command}`
  abort "#{command}\n#{result}" unless $?.success?
  result
end

ppi = 300
width = (2.475 * ppi).round # should be 2.5 but images are too small
height = (3.46 * ppi).round # should be 3.5 but images are too small
xoffset = 160
yoffset = 91
out_ppi = ppi * 1.03 # when printed cards are slightly too big even though our math looks good

sh "rm -rf {pages,cards,print}/*.png"
sh "mkdir -p pages cards print"
sh "magick -density #{ppi} deck.pdf pages/%d.png"

Dir["pages/*.png"].each_with_index do |png, pi|
  3.times do |ri|
    3.times do |ci|
      ii = (pi * 9) + (ri * 3) + ci
      sh "magick #{png} -crop #{width}x#{height}+#{xoffset + ci * width}+#{yoffset + ri * height} cards/#{ii}.png"
    end
  end
end

Dir["cards/*.png"].sort_by { |n| Integer(n[/\d+/]) }.each_slice(2).each_with_index.each do |(a, b), i|
  out = "print/#{i}.png"
  sh "magick #{a} #{b} +append -units PixelsPerInch -density #{out_ppi} #{out}"
  sh "magick #{out} -gravity center -background white -extent #{6*out_ppi}x#{4*out_ppi} #{out}"
end
