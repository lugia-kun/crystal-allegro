module Allegro
  # Mixin that stores event
  module Event
    @event : LibCore::Event

    def initialize(@event)
    end

    def type
      @event.any.header.type
    end

    def source
      @event.any.header.source
    end

    def timestamp
      @event.any.header.timestamp
    end

    def to_unsafe
      @event
    end

    def self.for(event : LibCore::Event)
      type = event.any.header.type
      case type
      when EventType::KEY_UP
        KeyUpEvent.new(event)
      when EventType::KEY_DOWN
        KeyDownEvent.new(event)
      when EventType::KEY_CHAR
        KeyCharEvent.new(event)
      when EventType::TIMER
        TimerEvent.new(event)
      else
        raise Error.new("Unknown event type #{type} used")
      end
    end

    macro def_inspect(interested_struct, *member)
      def inspect(io : IO)
        io << self.class << "("
        io << "source=" << @event.any.header.source
        io << ", timestamp=" << @event.any.header.timestamp
        {% for mem in member %}
          io << {{", " + mem.stringify + "="}} << @event.{{interested_struct}}.{{mem}}
        {% end %}
        io << ")"
      end
    end
  end

  struct TimerEvent
    include Event

    def count
      @event.timer.count
    end

    def error
      @event.timer.error
    end

    def_inspect(timer, count, error)
  end

  abstract struct KeyEvent
    include Event

    def keycode
      @event.keyboard.keycode
    end

    def display
      Display.new(@event.keyboard.display)
    end

    def_inspect(keyboard, keycode, display)
  end

  struct KeyDownEvent < KeyEvent
  end

  struct KeyUpEvent < KeyEvent
  end

  struct KeyCharEvent < KeyEvent
    def unichar
      @event.keyboard.unichar
    end

    def modifiers
      @event.keyboard.modifiers
    end

    def repeat
      @event.keyboard.repeat
    end

    def_inspect(keyboard, keycode, display, unichar, modifiers, repeat)
  end

  struct EventSource
    @ptr : LibCore::EventSource

    def initialize(@ptr)
    end

    def to_unsafe
      @ptr
    end
  end

  class EventQueue
    @ptr : LibCore::EventQueue

    def initialize
      ptr = LibCore.al_create_event_queue
      if ptr.null?
        raise Error.new("Failed to create event source")
      end
      @ptr = ptr
    end

    def finalize
      LibCore.al_destroy_event_queue(@ptr)
    end

    private def register(source : LibCore::EventSource)
      LibCore.al_register_event_source(@ptr, source)
    end

    private def unregister(source : LibCore::EventSource)
      LibCore.al_unregister_event_source(@ptr, source)
    end

    def register(timer : Timer)
      register(LibCore.al_get_timer_event_source(timer))
    end

    def register(keyboard : Keyboard.class)
      register(LibCore.al_get_keyboard_event_source)
    end

    def unregister(timer : Timer)
      unregister(LibCore.al_get_timer_event_source(timer))
    end

    def unregister(keyboard : Keyboard.class)
      unregister(LibCore.al_get_keyboard_event_source)
    end

    def register_keyboard_events
      register(Keyboard)
    end

    def unregister_keyboard_events
      unregister(Keyboard)
    end

    def wait_for_event
      LibCore.al_wait_for_event(@ptr, out event)
      Event.for(event)
    end

    def to_unsafe
      @ptr
    end
  end
end
