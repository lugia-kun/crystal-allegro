module Allegro
  # Mixin that stores event
  abstract struct Event
    abstract def header : LibCore::EventHeader

    def type
      header.type
    end

    def source
      Display.new(header.source)
    end

    def timestamp
      header.timestamp
    end

    def self.for(event : LibCore::Event)
      type = event.any.header.type
      case type
      when EventType::DISPLAY_EXPOSE
        DisplayExposeEvent.new(event.display)
      when EventType::DISPLAY_RESIZE
        DisplayResizeEvent.new(event.display)
      when EventType::DISPLAY_CLOSE
        DisplayCloseEvent.new(event.display)
      when EventType::DISPLAY_LOST
        DisplayLostEvent.new(event.display)
      when EventType::DISPLAY_FOUND
        DisplayFoundEvent.new(event.display)
      when EventType::DISPLAY_SWITCH_OUT
        DisplaySwitchedOutEvent.new(event.display)
      when EventType::DISPLAY_SWITCH_IN
        DisplaySwitchedInEvent.new(event.display)
      when EventType::DISPLAY_ORIENTATION
        DisplayOrientationEvent.new(event.display)
      when EventType::DISPLAY_HALT_DRAWING
        DisplayHaltDrawingEvent.new(event.display)
      when EventType::DISPLAY_RESUME_DRAWING
        DisplayResumeDrawingEvent.new(event.display)
      when EventType::DISPLAY_CONNECTED
        DisplayConnectedEvent.new(event.display)
      when EventType::DISPLAY_DISCONNECTED
        DisplayDisconnectedEvent.new(event.display)
      when EventType::KEY_UP
        KeyUpEvent.new(event.keyboard)
      when EventType::KEY_DOWN
        KeyDownEvent.new(event.keyboard)
      when EventType::KEY_CHAR
        KeyCharEvent.new(event.keyboard)
      when EventType::TIMER
        TimerEvent.new(event.timer)
      else
        raise Error.new("Unknown event type #{type} used")
      end
    end
  end

  abstract struct DisplayEvent < Event
    @event : LibCore::DisplayEvent

    private def header : LibCore::EventHeader
      @event.header
    end

    def initialize(@event)
    end

    def display
      Display.new(@event.source)
    end
  end

  struct DisplayExposeEvent < DisplayEvent
    def x
      @event.x
    end

    def y
      @event.y
    end

    def width
      @event.width
    end

    def height
      @event.height
    end
  end

  struct DisplayResizeEvent < DisplayEvent
    def x
      @event.x
    end

    def y
      @event.y
    end

    def width
      @event.width
    end

    def height
      @event.height
    end
  end

  struct DisplayCloseEvent < DisplayEvent
  end

  struct DisplayLostEvent < DisplayEvent
  end

  struct DisplayFoundEvent < DisplayEvent
  end

  struct DisplaySwitchedOutEvent < DisplayEvent
  end

  struct DisplaySwitchedInEvent < DisplayEvent
  end

  struct DisplayOrientationEvent < DisplayEvent
    def orientation
      @event.orientation
    end
  end

  struct DisplayHaltDrawingEvent < DisplayEvent
  end

  struct DisplayResumeDrawingEvent < DisplayEvent
  end

  struct DisplayConnectedEvent < DisplayEvent
  end

  struct DisplayDisconnectedEvent < DisplayEvent
  end

  abstract struct KeyEvent < Event
    @event : LibCore::KeyboardEvent

    def initialize(@event)
    end

    private def header : LibCore::EventHeader
      @event.header
    end

    def keycode
      @event.keycode
    end

    def display
      Display.new(@event.display)
    end
  end

  struct KeyDownEvent < KeyEvent
  end

  struct KeyUpEvent < KeyEvent
  end

  struct KeyCharEvent < KeyEvent
    def unichar
      @event.unichar
    end

    def modifiers
      @event.modifiers
    end

    def repeat
      @event.repeat
    end
  end

  struct TimerEvent < Event
    @event : LibCore::TimerEvent

    def initialize(@event)
    end

    private def header : LibCore::EventHeader
      @event.header
    end

    def count
      @event.count
    end

    def error
      @event.error
    end
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

    # Register to wait events from given display on this queue
    def register(display : Display)
      register(LibCore.al_get_display_event_source(display))
    end

    # Register to wait events from given timer on this queue
    def register(timer : Timer)
      register(LibCore.al_get_timer_event_source(timer))
    end

    # Register to wait events from keyboards on this queue
    #
    # The argument is not used.
    def register(keyboard : Keyboard.class)
      register(LibCore.al_get_keyboard_event_source)
    end

    def unregister(display : Display)
      unregister(LibCore.al_get_display_event_source(display))
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

    def is_empty?
      LibCore.al_is_event_queue_empty(@ptr)
    end

    def to_unsafe
      @ptr
    end
  end
end
