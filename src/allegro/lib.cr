module Allegro
  # :nodoc:
  macro define_splitted_pkgversions(version)
    {% a = version.split(".") %}

    # Version information obtained by pkg-config, at compile-time
    PKGVERSION = {{ version }}

    # Major version of allegro, used at compile-time
    PKGVERSION_MAJOR = {{ a[0].to_i }}

    # Minor version of allegro, used at compile-time
    PKGVERSION_MINOR = {{ a[1].to_i }}

    # Patch version of allegro, used at compile-time
    PKGVERSION_PATCH = {{ a[2].to_i }}
  end

  define_splitted_pkgversions({{ `pkg-config --modversion allegro-5`.stringify.chomp }})

  # :nodoc:
  #
  # Argument normalizer for Allegro.id
  def self.id_norm(m : Char | Int32 | UInt32)
    (m.responds_to?(:ord) ? m.ord : m).to_u32 & 0xff_u32
  end

  # Implements AL_ID. We assumes that this will never change.
  def self.id(a, b, c, d)
    (id_norm(a) << 24) | (id_norm(b) << 16) | (id_norm(c) << 8) | id_norm(d)
  end

  macro get_macro_defs(cflags, headerfile, &)
    {% data = run("./get_macro_defs.cr", cflags, headerfile) %}
    {{ yield data }}
  end

  macro define_core_macros(data)
    # :nodoc:
    MACRO_VARIABLES = {{ data.keys }}

    # PI value should be used for allegro library
    #
    # The value can be different from `Math::PI`
    PI = {{ data["ALLEGRO_PI"].id }}

    # :nodoc:
    ALLEGRO_VERSION = {{ data["ALLEGRO_VERSION"].id }}

    # :nodoc:
    ALLEGRO_SUB_VERSION = {{ data["ALLEGRO_SUB_VERSION"].id }}

    # :nodoc:
    ALLEGRO_WIP_VERSION = {{ data["ALLEGRO_WIP_VERSION"].id }}

    # :nodoc:
    ALLEGRO_RELEASE_NUMBER = {{ data["ALLEGRO_RELEASE_NUMBER"].id }}

    # :nodoc:
    ALLEGRO_UNSTABLE_BIT = {{ data["ALLEGRO_UNSTABLE_BIT"].id }}

    # Scrambled version number
    VERSION_INT = {{ data["ALLEGRO_VERSION_INT"].id }}
  end

  # define core macros
  get_macro_defs({{`pkg-config --cflags allegro-5`.stringify.chomp}}, "allegro5/allegro.h") do |data|
    define_core_macros({{data}})
  end

  # Crystal at_exit wrapper for C atexit interface
  AT_EXIT = Proc(Proc(Nil), Void).new do |func|
    ::at_exit do
      func.call
    end
  end

  # Core module
  @[Link(ldflags: "`pkg-config allegro-5 --libs`")]
  lib LibCore
    alias Int = LibC::Int
    alias UInt = LibC::UInt
    alias Float = LibC::Float
    alias Double = LibC::Double
    type Bitmap = Pointer(Void)
    type Config = Pointer(Void)
    type ConfigSection = Pointer(Void)
    type ConfigEntry = Pointer(Void)
    type Display = Pointer(Void)
    type EventSource = Pointer(Void)
    type File = Pointer(Void)
    type Joystick = Pointer(Void)
    type Path = Pointer(Void)

    # System

    @[Raises]
    fun al_install_system(version : Int, atexit : ((-> Void) -> Void)) : Bool
    fun al_uninstall_system : Void
    fun al_is_system_installed : Bool
    fun al_get_allegro_version : UInt32
    fun al_get_standard_path(id : Int) : Path
    fun al_set_exe_name(path : UInt8*) : Void
    fun al_set_app_name(app_name : UInt8*) : Void
    fun al_set_org_name(org_name : UInt8*) : Void
    fun al_get_exe_name : UInt8*
    fun al_get_app_name : UInt8*
    fun al_get_org_name : UInt8*
    fun al_get_system_config : Config
    fun al_get_system_id : SystemID
    fun al_register_assert_handler(handler : (UInt8*, UInt8*, Int, UInt8*) -> Void) : Void
    fun al_register_trace_handler(handler : UInt8* -> Void) : Void
    fun al_get_cpu_count : Int
    fun al_get_ram_size : Int

    # Config File

    fun al_create_config : Config
    fun al_destroy_config(Config) : Void
    fun al_load_config_file(filename : UInt8*) : Config
    fun al_load_config_file_f(file : File) : Config
    fun al_save_config_file(filename : UInt8*, config : Config) : Bool
    fun al_save_config_file_f(File, Config) : Bool
    fun al_add_config_section(Config, name : UInt8*) : Void
    fun al_remove_config_section(Config, section : UInt8*) : Void
    fun al_add_config_comment(Config, section : UInt8*, comment : UInt8*) : Void
    fun al_get_config_value(Config, section : UInt8*, key : UInt8*) : UInt8*
    fun al_set_config_value(Config, section : UInt8*, key : UInt8*, value : UInt8*) : Void
    fun al_remove_config_value(Config, section : UInt8*, key : UInt8*) : Bool
    fun al_get_first_config_section(Config, iterator : ConfigSection*) : UInt8*
    fun al_get_next_config_section(iterator : ConfigSection*) : UInt8*
    fun al_get_first_config_entry(Config, section : UInt8*, iterator : ConfigEntry*)
    fun al_get_next_config_entry(iterator : ConfigEntry*) : UInt8*
    fun al_merge_config(Config, Config) : Config
    fun al_merge_config_into(master : Config, add : Config) : Void

    # Display

    fun al_create_display(w : Int, h : Int) : Display
    fun al_get_new_display_flags : Int
    fun al_set_new_display_flags(flags : Int) : Void
    fun al_get_new_display_option(option : Int, importance : Int*) : Int
    fun al_set_new_display_option(option : Int, value : Int, importance : Int*) : Void
    fun al_get_new_display_position(x : Int*, y : Int*) : Void
    fun al_set_new_display_position(x : Int, y : Int) : Void
    fun al_get_new_display_refresh_rate : Int
    fun al_set_new_display_refresh_rate(refresh_rate : Int) : Void

    fun al_get_display_event_source(Display) : EventSource
    fun al_get_backbuffer(Display) : Bitmap
    fun al_flip_display : Void
    fun al_update_display_region(x : Int, y : Int, width : Int, height : Int) : Void
    fun al_wait_for_vsync : Bool
    fun al_get_display_width(Display) : Int
    fun al_get_display_height(Display) : Int
    fun al_resize_display(Display, width : Int, height : Int) : Bool
    fun al_acknowledge_resize(Display) : Bool
    fun al_get_window_position(Display, x : Int*, y : Int*) : Void
    fun al_set_window_position(Display, x : Int, y : Int) : Void
    fun al_get_window_constraints(Display, min_w : Int*, min_h : Int*, max_w : Int*, max_h : Int*) : Bool
    fun al_set_window_constraints(Display, min_w : Int, min_h : Int, max_w : Int, max_h : Int) : Bool
    fun al_apply_window_contraints(Display, Bool) : Void
    fun al_get_display_flags(Display) : Int
    fun al_set_display_flag(Display, flag : Int, onoff : Bool) : Bool
    fun al_get_display_option(Display, option : Int) : Int
    fun al_set_display_option(Display, option : Int, value : Int) : Void
    fun al_get_display_format(Display) : Int
    fun al_get_display_orientation(Display) : Int
    fun al_get_display_refresh_rate(Display) : Int
    fun al_set_window_title(Display, title : UInt8*) : Void
    fun al_set_new_window_title(title : UInt8*) : Void
    fun al_get_new_window_title : UInt8*
    fun al_set_display_icon(Display, icon : Bitmap) : Void
    fun al_set_display_icons(Display, num_icons : Int, icons : Bitmap*) : Void
    fun al_acknowledge_halt(Display) : Void
    fun al_acknowledge_drawing_resume(Display) : Void
    fun al_inhibit_screensaver(Bool) : Bool
    fun al_get_clipboard_text(Display) : UInt8*
    fun al_set_clipboard_text(Display, text : UInt8*) : Bool
    fun al_clipboard_has_text(Display) : Bool

    # Event

    alias EventType = UInt
    enum Event
      JOYSTICK_AXIS          = 1
      JOYSTICK_BUTTON_DOWN   = 2
      JOYSTICK_BUTTON_UP     = 3
      JOYSTICK_CONFIGURATION = 4

      KEY_DOWN = 10
      KEY_CHAR = 11
      KEY_UP   = 12

      MOUSE_AXES          = 20
      MOUSE_BUTTON_DOWN   = 21
      MOUSE_BUTTON_UP     = 22
      MOUSE_ENTER_DISPLAY = 23
      MOUSE_LEAVE_DISPLAY = 24
      MOUSE_WARPED        = 25

      TIMER = 30

      DISPLAY_EXPOSE         = 40
      DISPLAY_RESIZE         = 41
      DISPLAY_CLOSE          = 42
      DISPLAY_LOST           = 43
      DISPLAY_FOUND          = 44
      DISPLAY_SWITCH_IN      = 45
      DISPLAY_SWITCH_OUT     = 46
      DISPLAY_ORIENTATION    = 47
      DISPLAY_HALT_DRAWING   = 48
      DISPLAY_RESUME_DRAWING = 49

      TOUCH_BEGIN  = 50
      TOUCH_END    = 51
      TOUCH_MOVE   = 52
      TOUCH_CANCEL = 53

      DISPLAY_CONNECTED    = 60
      DISPLAY_DISCONNECTED = 61
    end

    struct EventHeader
      type : EventType
      source : Void*
      timestamp : Double
    end

    struct DisplayEvent
      header : EventHeader
      x : Int
      y : Int
      width : Int
      height : Int
      orientation : Int
    end

    struct JoystickEvent
      header : EventHeader
      id : Joystick
      stick : Int
      axis : Int
      pos : Float
      button : Int
    end

    struct KeyboardEvent
      header : EventHeader
      display : Display
      keycode : Int
      unichar : Int
      modifiers : UInt
      repeat : Bool
    end

    struct MouseEvent
      header : EventHeader
      x : Int
      y : Int
      z : Int
      w : Int
      dx : Int
      dy : Int
      dz : Int
      dw : Int
      button : UInt
      pressure : Float
    end

    struct TimerEvent
      header : EventHeader
      count : Int64
      error : Double
    end

    struct TouchEvent
      header : EventHeader
      display : Display
      id : Int
      x : Float
      y : Float
      dx : Float
      dy : Float
      primary : Bool
    end

    struct UserEvent
      header : EventHeader
      internal_descriptor : Void*
      data1 : LibC::PtrdiffT
      data2 : LibC::PtrdiffT
      data3 : LibC::PtrdiffT
      data4 : LibC::PtrdiffT
    end
  end

  {% p LibC.constants %}
  # :nodoc:
  macro al_id_table_lookup(table_data, a, b, c, d, &)
    {% table = {} of CharLiteral => NumberLiteral %}
    {% for chrset, range in table_data.resolve %}
      {% chrs = chrset.chars %}
      {% nums = range.to_a %}
      {% for n, i in nums %}
        {% table[chrs[i]] = n %}
      {% end %}
    {% end %}
    {{ yield(table[a], table[b], table[c], table[d]) }}
  end

  # :nodoc:
  AL_ASCII_TAB = {
    " "                          => 32..32,
    "0123456789"                 => 48..57,
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ" => 65..90,
    "abcdefghijklmnopqrstuvwxyz" => 97..122,
  }

  # Macro implementation of `Allegro.id` for make literal values
  macro al_id(a, b, c, d)
    Allegro.al_id_table_lookup(AL_ASCII_TAB, {{a}}, {{b}}, {{c}}, {{d}}) do |ia, ib, ic, id|
      (\{{ia}} << 24) | (\{{ib}} << 16) | (\{{ic}} << 8) | \{{id}}
    end
  end

  enum LibCore::SystemID
    # Unknown system ID
    Unknown = 0

    # X Window System, GLX
    XGLX = Allegro.al_id('X', 'G', 'L', 'X')

    # Windows
    Windows = Allegro.al_id('W', 'I', 'N', 'D')

    # MacOS X
    MacOSX = Allegro.al_id('O', 'S', 'X', ' ')

    # Android
    Android = Allegro.al_id('A', 'N', 'D', 'R')

    # iPhone (iOS)
    IPhone = Allegro.al_id('I', 'P', 'H', 'O')

    # GP2XWIZ
    GP2XWIZ = Allegro.al_id('W', 'I', 'Z', ' ')

    # Raspberry Pi
    RaspberryPi = Allegro.al_id('R', 'A', 'S', 'P')

    # SDL
    SDL = Allegro.al_id('S', 'D', 'L', '2')
  end

  alias SystemID = LibCore::SystemID
end

p Allegro::LibCore.al_install_system(Allegro::VERSION_INT, Allegro::AT_EXIT)
