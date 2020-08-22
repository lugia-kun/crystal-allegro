module Allegro
  class Timer
    def self.for(seconds : Float | Int)
      ptr = LibCore.al_create_timer(seconds.to_f64)
      if ptr.null?
        raise Error.new("Failed create a timer")
      end
      Timer.new(ptr)
    end

    def self.for(span : ::Time::Span)
      Timer.for(span.seconds)
    end

    # :nodoc:
    def initialize(@ptr : LibCore::Timer)
    end

    def finalize
      LibCore.al_destroy_timer(@ptr)
    end

    def start
      LibCore.al_start_timer(@ptr)
    end

    def stop
      LibCore.al_stop_timer(@ptr)
    end

    def resume
      LibCore.al_resume_timer(@ptr)
    end

    def started? : Bool
      LibCore.al_get_timer_started(@ptr)
    end

    def count
      LibCore.al_get_timer_count(@ptr)
    end

    def count=(value)
      LibCore.al_set_timer_count(@ptr, value)
      value
    end

    def add_to_count(diff)
      LibCore.al_add_timer_count(@ptr, diff)
    end

    def speed
      LibCore.al_get_timer_speed(@ptr)
    end

    def speed=(value)
      LibCore.al_set_timer_speed(@ptr, value)
      value
    end

    # Returns pointer to `ALLEGRO_TIMER` for using Allegro API directly
    def to_unsafe
      @ptr
    end
  end
end
