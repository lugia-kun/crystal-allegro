# Example imitates Allegro Vivace example
#
# https://github.com/liballeg/allegro_wiki/wiki/Allegro-Vivace%3A-Basic-game-structure

require "../src/allegro"

Allegro::Keyboard.initialize

timer = Allegro::Timer.for(1.seconds)
display = Allegro::Display.new(320, 240)

queue = Allegro::EventQueue.new
queue.register(timer)
queue.register_keyboard_events
queue.register(display)

timer.start
loop do
  event = queue.wait_for_event
  pp! event
end
