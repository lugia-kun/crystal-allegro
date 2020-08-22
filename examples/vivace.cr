# Example imitates Allegro Vivace example
#
# https://github.com/liballeg/allegro_wiki/wiki/Allegro-Vivace%3A-Basic-game-structure

require "../src/allegro"

Allegro.initialize
Allegro::Keyboard.initialize

timer = Allegro::Timer.for(1.0 / 30.0)
display = Allegro::Display.new(320, 240)
font = Allegro::Font.builtin_font

queue = Allegro::EventQueue.new
queue.register_keyboard_events
queue.register(display)
queue.register(timer)

timer.start
redraw = false
loop do
  event = queue.wait_for_event
  case event
  when Allegro::KeyDownEvent, Allegro::DisplayCloseEvent
    break
  when Allegro::TimerEvent
    redraw = true
  end
  if redraw && queue.is_empty?
    Allegro::Display.clear_to_color(Allegro::Color.new(0, 0, 0))
    font.draw("Hello, World!", Allegro::Color.new(255, 255, 255), 0, 0, 0)
    Allegro::Display.flip
    redraw = false
  end
end
