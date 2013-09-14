require 'watir-webdriver'
require 'RMagick'
include Magick

#
# Create a collection of snapshots at commit time for 
#

browser = Watir::Browser.new
branch = `git branch | sed -n '/\* /s///p'`
shas = `git rev-list #{branch}`
shas = shas.split("\n").reverse.last(5)
temp = 'tmp' + Time.now.to_i.to_s
`mkdir #{temp}`

shas.each_with_index do |sha, index|
  `git checkout #{sha}`
  browser.goto ARGV[0]
  browser.screenshot.save(temp + '/' + index.to_s + '.png')
end

`git checkout #{branch}`
browser.close

Dir.chdir("#{temp}") do
  animation = ImageList.new(*Dir["*.png"])
  animation.delay = 1
  animation.write("animated.gif")
  `mv *.gif ..`
end

`rm -rf #{temp}`

