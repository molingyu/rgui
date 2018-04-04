#encoding: utf-8
#author: shitake
#data: 16-4-20
#
require_relative  'game'

$g = Game.new

$g.load_libs
$g.load_games
$g.load_views

$g.init('test', 640, 480) do
  $g.exit = false
  $g.start_view = TitleView
end

begin
until $g.exit
  $g.update
  $g.debug if Input.press?(Input::F6)
end
rescue
  p $!
end

