#encoding: utf-8
#author: shitake
#data: 16-4-20

require_relative  'game'

def console
  Win32API.new('kernel32', 'AllocConsole', 'v', 'v').call
  $stdout = File.open('CONOUT$', 'w')
  $stdin  = File.open('CONIN$')
end

console

$g = Game.new

$g.load_libs
$g.load_games
$g.load_views

$g.init(640, 480) do
  $g.exit = false
  $g.start_view = TestView
end


until $g.exit
  begin
    $g.update
    $g.debug if Input.up?(:KEY_F6)
  rescue Exception
    p $!
    $!.backtrace.each{|e| puts e }
  end
end


