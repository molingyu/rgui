#encoding: utf-8
#author: shitake
#data: 16-4-20

require_relative  'game'

$g = Game.new

$g.load_libs
$g.load_games
$g.load_views

$g.init(1280, 720) do
  $g.exit = false
  $g.start_view = TestView
end

until $g.exit
  $g.update
end


