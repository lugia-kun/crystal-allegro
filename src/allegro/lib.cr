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

    # Math PI value defined for Allegro library
    #
    # The value can be different from Crystal's `Math::PI`
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
    alias IntPtrT = LibC::SSizeT # TODO: SizeT is based on Allowable size, not representing address space
    alias SizeT = LibC::SizeT
    alias OffT = LibC::OffT
    alias TimeT = LibC::TimeT
    type Bitmap = Pointer(Void)
    type Config = Pointer(Void)
    type ConfigSection = Pointer(Void)
    type ConfigEntry = Pointer(Void)
    type Display = Pointer(Void)
    type EventQueue = Pointer(Void)
    type EventSource = Pointer(Void)
    type File = Pointer(Void)
    type FileSystemEntry = Pointer(Void)
    type Joystick = Pointer(Void)
    type Path = Pointer(Void)
    type Ustr = Pointer(Void)
    type Fixed = Int32

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

    alias EventTypeValue = UInt
    enum EventType
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
      type : EventTypeValue
      source : Void*
      timestamp : Double
    end

    struct AnyEvent
      header : EventHeader
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
      data1 : IntPtrT
      data2 : IntPtrT
      data3 : IntPtrT
      data4 : IntPtrT
    end

    union Event
      any : AnyEvent
      display : DisplayEvent
      joystick : JoystickEvent
      keyboard : KeyboardEvent
      mouse : MouseEvent
      timer : TimerEvent
      touch : TouchEvent
      user : UserEvent
    end

    fun al_create_event_queue : EventQueue
    fun al_destroy_event_queue(EventQueue) : Void
    fun al_register_event_source(EventQueue, EventSource) : Void
    fun al_unregister_event_source(EventQueue, EventSource) : Void
    fun al_pause_event_source(EventQueue, Bool) : Void
    fun al_is_event_queue_paused(EventQueue) : Bool
    fun al_is_event_queue_empty(EventQueue) : Bool
    fun al_get_next_event(EventQueue, ret_event : Event*) : Bool
    fun al_peek_next_event(EventQueue, ret_event : Event*) : Bool
    fun al_drop_next_event(EventQueue) : Bool
    fun al_flush_event_queue(EventQueue) : Void
    fun al_wait_for_event(EventQueue, ret_event : Event*) : Void
    fun al_wait_for_event_timed(EventQueue, ret_event : Event*, secs : Float) : Bool
    fun al_wait_for_event_until(EventQueue, ret_event : Event*, timeout : Float) : Bool

    fun al_init_user_event_source(EventSource) : Void
    fun al_destroy_user_event_source(EventSource) : Void
    fun al_emit_user_event(EventSource, event : Event*, dtor : Event* -> Void) : Void
    fun al_unref_user_event(UserEvent*) : Void
    fun al_set_event_source_data(EventSource, data : Void*) : Void # Real prototype is IntPtrT
    fun al_get_event_source_data(EventSource) : Void*

    # File I/O

    struct FileInterface
      fi_fopen : (UInt8*, UInt8*) -> Void*
      fi_fclose : File -> Bool
      fi_fread : (File, Void*, SizeT) -> SizeT
      fi_fwrite : (File, Void*, SizeT) -> SizeT
      fi_fflush : File -> Bool
      fi_ftell : File -> Int64
      fi_fseek : (File, Int64, Int) -> Bool
      fi_feof : File -> Bool
      fi_ferror : File -> Int
      fi_ferrmsg : File -> UInt8*
      fi_fclearerr : File -> Void
      fi_fungetc : (File, Int) -> Int
      fi_fsize : File -> OffT
    end

    enum Seek
      SET = 0
      CUR
      END
    end

    @[Raises]
    fun al_fopen(path : UInt8*, mode : UInt8*) : File
    @[Raises]
    fun al_fopen_interface(vt : FileInterface, path : UInt8*, mode : UInt8*) : File
    @[Raises]
    fun al_fopen_slice(fp : File, initial_size : SizeT, mode : UInt8*) : File
    @[Raises]
    fun al_fclose(File) : Bool
    @[Raises]
    fun al_fread(File, ptr : Void*, size : SizeT) : SizeT
    @[Raises]
    fun al_fwrite(File, ptr : Void*, size : SizeT) : SizeT
    @[Raises]
    fun al_fflush(File) : Bool
    @[Raises]
    fun al_ftell(File) : Int64
    @[Raises]
    fun al_fseek(File, offset : Int64, whence : Int) : Bool
    @[Raises]
    fun al_feof(File) : Bool
    @[Raises]
    fun al_ferror(File) : Int
    @[Raises]
    fun al_ferrmsg(File) : UInt8*
    @[Raises]
    fun al_fclearerr(File) : Void
    @[Raises]
    fun al_fungetc(File, c : Int) : Int
    @[Raises]
    fun al_fsize(File) : Int64
    @[Raises]
    fun al_fgetc(File) : Int
    @[Raises]
    fun al_fputc(File, c : Int) : Int
    @[Raises]
    fun al_fprintf(File, format : UInt8*, ...) : Int
    @[Raises]
    fun al_vfprintf(File, format : UInt8*, args : LibC::VaList) : Int
    @[Raises]
    fun al_fread16le(File) : Int16
    @[Raises]
    fun al_fread16be(File) : Int16
    @[Raises]
    fun al_fwrite16le(File, Int16) : SizeT
    @[Raises]
    fun al_fwrite16be(File, Int16) : SizeT
    @[Raises]
    fun al_fread32le(File) : Int32
    @[Raises]
    fun al_fread32be(File) : Int32
    @[Raises]
    fun al_fwrite32le(File, Int32) : SizeT
    @[Raises]
    fun al_fwrite32be(File, Int32) : SizeT
    @[Raises]
    fun al_fgets(File, buf : UInt8*, max : SizeT) : UInt8*
    @[Raises]
    fun al_fget_ustr(File) : Ustr
    @[Raises]
    fun al_fopen_fd(fd : Int, mode : UInt8*) : File
    fun al_make_temp_file(template : UInt8*, ret_path : Path*) : File
    fun al_set_new_file_interface(FileInterface*) : Void
    fun al_standard_file_interface : Void
    fun al_get_new_file_interface : FileInterface*
    @[Raises]
    fun al_create_file_handle(drv : FileInterface*, uesrdata : Void*) : File
    fun al_get_file_userdata(File) : Void*

    # FIlesystem

    @[Flags]
    enum FileMode
      Read    = 1
      Write   = 1 << 1
      Execute = 1 << 2
      Hidden  = 1 << 3
      IsFile  = 1 << 4
      IsDir   = 1 << 5
    end

    struct FileSystemInterface
      fs_create_entry : UInt8* -> FileSystemEntry
      fs_destroy_entry : FileSystemEntry -> Void
      fs_entry_name : FileSystemEntry -> UInt8*
      fs_update_entry : FileSystemEntry -> Bool
      fs_entry_mode : FileSystemEntry -> UInt32
      fs_entry_atime : FileSystemEntry -> TimeT
      fs_entry_mtime : FileSystemEntry -> TimeT
      fs_entry_ctime : FileSystemEntry -> TimeT
      fs_entry_size : FileSystemEntry -> OffT
      fs_entry_exists : FileSystemEntry -> Bool
      fs_remove_entry : FileSystemEntry -> Bool

      fs_open_directory : FileSystemEntry -> Bool
      fs_read_directory : FileSystemEntry -> FileSystemEntry
      fs_get_current_directory : -> UInt8*
      fs_change_directory : UInt8* -> Bool
      fs_make_directory : UInt8* -> Bool
      fs_open_file : (FileSystemEntry, UInt8*) -> File
    end

    enum FileSystemEntryResult
      ERROR = -1
      OK    =  0
      SKIP  =  1
      STOP  =  2
    end

    @[Raises]
    fun al_create_fs_entry(path : UInt8*) : FileSystemEntry
    @[Raises]
    fun al_destroy_fs_entry(FileSystemEntry) : Void
    @[Raises]
    fun al_get_fs_entry_name(FileSystemEntry) : UInt8*
    @[Raises]
    fun al_update_fs_entry(FileSystemEntry) : Bool
    @[Raises]
    fun al_get_fs_entry_mode(FileSystemEntry) : UInt32
    @[Raises]
    fun al_get_fs_entry_atime(FileSystemEntry) : TimeT
    @[Raises]
    fun al_get_fs_entry_ctime(FileSystemEntry) : TimeT
    @[Raises]
    fun al_get_fs_entry_mtime(FileSystemEntry) : TimeT
    @[Raises]
    fun al_get_fs_entry_size(FileSystemEntry) : OffT
    @[Raises]
    fun al_get_fs_entry_exists(FileSystemEntry) : Bool
    @[Raises]
    fun al_remove_fs_entry(FileSystemEntry) : Bool
    @[Raises]
    fun al_filename_exists(path : UInt8*) : Bool
    @[Raises]
    fun al_remove_filename(path : UInt8*) : Bool

    @[Raises]
    fun al_open_directory(FileSystemEntry) : FileSystemEntry
    @[Raises]
    fun al_read_directory(FileSystemEntry) : FileSystemEntry
    @[Raises]
    fun al_close_directory(FileSystemEntry) : Bool
    @[Raises]
    fun al_get_current_directory : UInt8*
    @[Raises]
    fun al_change_directory(path : UInt8*) : Bool
    @[Raises]
    fun al_make_directory(path : UInt8*) : Bool
    @[Raises]
    fun al_open_entry(FileSystemEntry, mode : UInt8*) : File

    @[Raises]
    fun al_for_each_fs_entry(FileSystemEntry, callback : (FileSystemEntry, Void*) -> Int, extra : Void*) : Int

    fun al_set_fs_interface(FileSystemInterface*) : Void
    fun al_set_standard_fs_interface : Void
    fun al_get_fs_interface : FileSystemInterface*

    # Fixed point path

    fun al_itofix(Int) : Fixed
    fun al_fixtoi(Fixed) : Int
    fun al_fixfloor(Fixed) : Int
    fun al_fixceil(Fixed) : Int
    fun al_ftofix(Double) : Fixed
    fun al_fixtof(Fixed) : Double
    fun al_fixmul(Fixed, Fixed) : Fixed
    fun al_fixdiv(Fixed, Fixed) : Fixed
    fun al_fixadd(Fixed, Fixed) : Fixed
    fun al_fixsub(Fixed, Fixed) : Fixed

    $al_fixtorad_r : Fixed # 1608
    $al_radtofix_r : Fixed # 2670177

    fun al_fixsin(Fixed) : Fixed
    fun al_fixcos(Fixed) : Fixed
    fun al_fixtan(Fixed) : Fixed
    fun al_fixasin(Fixed) : Fixed
    fun al_fixacos(Fixed) : Fixed
    fun al_fixatan(Fixed) : Fixed
    fun al_fixatan2(Fixed, Fixed) : Fixed
    fun al_fixsqrt(Fixed) : Fixed
    fun al_fixhypot(Fixed, Fixed) : Fixed
  end

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
