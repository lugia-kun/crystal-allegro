module Allegro
  class Font
    @ptr : LibFont::Font

    def self.builtin_font : Font
      ptr = LibFont.al_create_builtin_font
      if ptr.null?
        raise Error.new("Failed to load builtin font")
      end
      new(ptr)
    end

    # :nodoc:
    def initialize(@ptr)
    end

    def draw(text, color, x, y, flags)
      LibFont.al_draw_text(@ptr, color, x, y, flags, text)
    end

    def close
      LibFont.al_destroy_font(@ptr)
      @ptr = Pointer.null
    end
  end
end
