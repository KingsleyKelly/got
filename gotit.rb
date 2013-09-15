require 'watir-webdriver'
require 'RMagick'
include Magick

def human_sort (items)
  items.sort_by { |item| item.to_s.split(/(\d+)/).map { |e| [e.to_i, e] } }
end
#
# Create a collection of snapshots at commit time for
#

output_file = ARGV[1].nil? ?  "animation" : ARGV[1]
browser = Watir::Browser.new
branch = `git branch | sed -n '/\* /s///p'`
shas = `git rev-list #{branch}`
shas = shas.split("\n").reverse
temp = 'tmp' + Time.now.to_i.to_s
`mkdir #{temp}`
`git stash`

shas.each_with_index do |sha, index|
  `git checkout #{sha}`
  browser.goto ARGV[0]
  sleep(1)
  browser.screenshot.save(temp + '/' + index.to_s + '.png')
end

`git checkout #{branch}`
browser.close

Dir.chdir("#{temp}") do
  animation = ImageList.new(*human_sort(Dir["*.png"]))
  animation.delay = 100
  animation.write("#{output_file}.gif")
  `mv *.gif ..`
end

`rm -rf #{temp}`
`git stash apply`
