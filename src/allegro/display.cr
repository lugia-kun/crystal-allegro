module Allegro
  struct Color
    @color : LibCore::Color

    def initialize(@color)
    end

    def initialize(r : Int, g : Int, b : Int)
      @color = LibCore.al_map_rgb(r.to_u8, g.to_u8, b.to_u8)
    end

    def initialize(r : Int, g : Int, b : Int, a : Int)
      @color = LibCore.al_map_rgba(r.to_u8, g.to_u8, b.to_u8, a.to_u8)
    end

    def initialize(r : Float, g : Float, b : Float)
      @color = LibCore.al_map_rgb_f(r, g, b)
    end

    def initialize(r : Float, g : Float, b : Float, a : Float)
      @color = LibCore.al_map_rgba_f(r, g, b, a)
    end

    def r
      @color.r
    end

    def g
      @color.g
    end

    def b
      @color.b
    end

    def a
      @color.a
    end

    def to_unsafe
      @color
    end

    def to_rgb
      LibCore.al_unmap_rgb(@color, out r, out g, out b)
      {r, g, b}
    end

    def to_rgba
      LibCore.al_unmap_rgba(@color, out r, out g, out b, out a)
      {r, g, b, a}
    end

    def to_rgb_f
      LibCore.al_unmap_rgb_f(@color, out r, out g, out b)
      {r, g, b}
    end

    def to_rgba_f
      LibCore.al_unmap_rgba_f(@color, out r, out g, out b, out a)
      {r, g, b, a}
    end
  end

  struct Display
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

    def to_unsafe
      @ptr
    end

    def self.clear_to_color(color : Color)
      LibCore.al_clear_to_color(color)
    end
  end
end
