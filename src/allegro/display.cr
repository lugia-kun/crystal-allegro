
module Allegro
  class Display
    @ptr : LibCore::Display

    # :nodoc:
    def initialize(@ptr)
    end

    def initialize(width : Int, height : Int)
      display = LibCore.al_create_display(width, height)
      if display.null?
        raise Error.new("Failed to create a display")
      end
      @ptr = display
    end

    # Flips double-buffered display
    #
    # No effect if displays are not double-buffered
    def self.flip
      LibCore.al_flip_display
    end
  end
end
