module Allegro
  @[Link(ldflags: "`pkg-config --libs allegro_font-5`")]
  lib LibFont
    type Font = Pointer(Void)
    alias Color = LibCore::Color
    alias Ustr = LibCore::Ustr
    alias Int = LibCore::Int
    alias Float = LibCore::Float

    struct Glyph
      x : Int
      y : Int
      w : Int
      h : Int
      kerning : Int
      offset_x : Int
      offset_y : Int
      advance : Int
    end

    enum FontFlags : Int
      NO_KERNING    = -1
      ALIGN_LEFT    =  0
      ALIGN_CENTRE  =  1
      ALIGN_CENTER  =  1
      ALIGN_RIGHT   =  2
      ALIGN_INTEGER =  4
    end

    fun al_init_font_addon : Bool
    fun al_is_font_addon_initialized : Bool
    fun al_shutdown_font_addon : Void
    fun al_load_font(filename : UInt8*, size : Int, flags : Int) : Font
    fun al_destroy_font(Font)
    fun al_register_font_loader(extension : UInt8*, load_font : (UInt8*, Int) -> Font) : Bool
    fun al_get_font_line_height(Font) : Int
    fun al_get_font_ascent(Font) : Int
    fun al_get_font_descent(Font) : Int
    fun al_get_text_width(Font, str : UInt8*) : Int
    fun al_get_ustr_width(Font, Ustr) : Int
    fun al_draw_text(Font, Color, x : Float, y : Float, flags : Int, text : UInt8*) : Void
    fun al_draw_ustr(Font, Color, x : Float, y : Float, flags : Int, text : Ustr) : Void
    fun al_draw_justified_text(Font, Color, x1 : Float, x2 : Float, y : Float, diff : Float, flags : Int, text : UInt8*) : Void
    fun al_draw_justified_ustr(Font, Color, x1 : Float, x2 : Float, y : Float, diff : Float, flags : Int, text : Ustr) : Void
    fun al_draw_textf(Font, Color, x : Float, y : Float, flags : Int, format : UInt8*, ...) : Void
    fun al_draw_justified_textf(Font, Color, x1 : Float, x2 : Float, y : Float, diff : Float, flags : Int, format : UInt8*, ...) : Void
    fun al_get_text_dimensions(Font, text : UInt8*, bbx : Int*, bby : Int*, bbw : Int*, bbh : Int*) : Void
    fun al_get_ustr_dimensions(Font, ustr : Ustr, bbx : Int*, bby : Int*, bbw : Int*, bbh : Int*) : Void
    fun al_get_allegro_font_version : Void
    fun al_get_font_ranges(Font, ranges : Int, ranges : Int*) : Int
    fun al_set_fallback_font(Font, Font) : Void
    fun al_get_fallback_font(Font) : Font

    fun al_create_builtin_font : Font
  end

  alias FontFlags = LibFont::FontFlags
end
