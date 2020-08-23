module Allegro
  class Font
    @ptr : LibFont::Font
    @finalize : Bool

    def self.builtin_font : Font
      ptr = LibFont.al_create_builtin_font
      if ptr.null?
        raise Error.new("Failed to load builtin font")
      end
      new(ptr, finalize: true)
    end

    def self.load(filename : String | ::Path, size : Int, flags : Int) : Font
      ptr = LibFont.al_load_font(filename.to_s, size, flags)
      if ptr.null?
        raise Error.new("Failed to load font: #{filename}")
      end
      new(ptr, finalize: true)
    end

    # :nodoc:
    def initialize(@ptr, *, @finalize = true)
    end

    def finalize
      if @finalize
        close
      end
    end

    # Draw ASCII text to current target bitmap
    #
    # This may not optimize your app. Use `#draw` instead.
    def draw_text(text : String, color, x, y, flags)
      LibFont.al_draw_text(@ptr, color, x, y, flags, text)
    end

    def draw(text : AnyUString, color, x, y, flags)
      LibFont.al_draw_ustr(@ptr, color, x, y, flags, text)
    end

    def draw(text : String, color, x, y, flags)
      ustr = StaticUString.new(text)
      LibFont.al_draw_ustr(@ptr, color, x, y, flags, ustr)
    end

    # Explicitly destroys the underlying font
    def close
      if !@ptr.null?
        LibFont.al_destroy_font(@ptr)
      end
      @ptr = Pointer(Void).null.as(LibFont::Font)
    end

    # Initialize Font Addon
    def self.initialize
      if !LibFont.al_init_font_addon
        raise Error.new("Failed to initialize Font Addon")
      end
    end

    # Finalize Font Addon
    def self.finalize
      LibFont.al_shutdown_font_addon
    end
  end
end
