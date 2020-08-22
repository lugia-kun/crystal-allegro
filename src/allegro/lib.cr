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
    alias UChar = LibC::UChar
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
    type Timer = Pointer(Void)
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

    enum EventType : UInt
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
      keycode : Key
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

    # Fullscreen modes

    struct DisplayMode
      width : Int
      height : Int
      format : Int
      refresh_rate : Int
    end

    fun al_get_display_mode(index : Int, mode : DisplayMode*) : DisplayMode*
    fun al_get_num_display_modes : Int

    # Graphic

    struct Color
      r : Float
      g : Float
      b : Float
      a : Float
    end

    fun al_map_rgb(r : UChar, g : UChar, b : UChar) : Color
    fun al_map_rgb_f(r : Float, g : Float, b : Float) : Color
    fun al_map_rgba(r : UChar, g : UChar, b : UChar, a : UChar) : Color
    fun al_premul_rgba(r : UChar, g : UChar, b : UChar, a : UChar) : Color
    fun al_map_rgba_f(r : Float, g : Float, b : Float, a : Float) : Color
    fun al_premul_rgba_f(r : Float, g : Float, b : Float, a : Float) : Color
    fun al_unmap_rgb(Color, r : UChar*, g : UChar*, b : UChar*) : Color
    fun al_unmap_rgb_f(Color, r : Float*, g : Float*, b : Float*) : Color
    fun al_unmap_rgba(Color, r : UChar*, g : UChar*, b : UChar*, a : UChar*) : Color
    fun al_unmap_rgba_f(Color, r : Float*, g : Float*, b : Float*, a : UChar*) : Color

    struct LockedRegion
      data : Void*
      format : Int
      pitch : Int
      pixel_size : Int
    end

    enum PixelFormat
      ANY                  =  0
      ANY_NO_ALPHA         =  1
      ANY_WITH_ALPHA       =  2
      ANY_15_NO_ALPHA      =  3
      ANY_16_NO_ALPHA      =  4
      ANY_16_WITH_ALPHA    =  5
      ANY_24_NO_ALPHA      =  6
      ANY_32_NO_ALPHA      =  7
      ANY_32_WITH_ALPHA    =  8
      ARGB_8888            =  9
      RGBA_8888            = 10
      ARGB_4444            = 11
      RGB_888              = 12
      RGB_565              = 13
      RGB_555              = 14
      RGBA_5551            = 15
      ARGB_1555            = 16
      ABGR_8888            = 17
      XBGR_8888            = 18
      BGR_888              = 19
      BGR_565              = 20
      BGR_555              = 21
      RGBX_8888            = 22
      XRGB_8888            = 23
      ABGR_F32             = 24
      ABGR_8888_LE         = 25
      RGBA_4444            = 26
      SINGLE_CHANNEL_8     = 27
      COMPRESSED_RGBA_DXT1 = 28
      COMPRESSED_RGBA_DXT3 = 29
      COMPRESSED_RGBA_DXT5 = 30
    end

    fun al_get_pixel_size(format : Int) : Int
    fun al_get_pixel_format_bits(format : Int) : Int
    fun al_get_pixel_block_size(format : Int) : Int
    fun al_get_pixel_block_height(format : Int) : Int
    fun al_lock_bitmap(Bitmap, format : Int, flags : Int) : LockedRegion*
    fun al_lock_bitmap_region(Bitmap, x : Int, y : Int, width : Int, height : Int, format : Int, flags : Int) : LockedRegion*
    fun al_unlock_bitmap(Bitmap) : Void
    fun al_lock_bitmap_blocked(Bitmap, flags : Int) : LockedRegion*
    fun al_lock_bitmap_region_blocked(Bitmap, x_block : Int, y_block : Int, width_block : Int, height_block : Int, flags : Int) : LockedRegion*

    fun al_create_bitmap(w : Int, h : Int) : Bitmap
    fun al_create_sub_bitmap(Bitmap, x : Int, y : Int, w : Int, h : Int) : Bitmap
    fun al_clone_bitmap(Bitmap) : Bitmap
    fun al_convert_bitmap(Bitmap) : Void
    fun al_convert_memory_bitmaps : Void
    fun al_destroy_bitmap(Bitmap) : Void
    fun al_get_new_bitmap_flags : Int
    fun al_get_new_bitmap_format : Int
    fun al_set_new_bitmap_flags(flags : Int) : Void
    fun al_add_new_bitmap_flag(flags : Int) : Void
    fun al_set_new_bitmap_format(format : Int) : Void
    fun al_set_new_bitmap_depth(depth : Int) : Void
    fun al_get_new_bitmap_depth : Int
    fun al_set_new_bitmap_samples(samples : Int) : Void
    fun al_get_bitmap_flags(Bitmap) : Int
    fun al_get_bitmap_format(Bitmap) : Int
    fun al_get_bitmap_height(Bitmap) : Int
    fun al_get_bitmap_width(Bitmap) : Int
    fun al_get_bitmap_depth(Bitmap) : Int
    fun al_get_bitmap_samples(Bitmap) : Int
    fun al_is_bitmap_locked(Bitmap) : Bool
    fun al_is_compatible_bitmap(Bitmap) : Bool
    fun al_is_sub_bitmap(Bitmap) : Bool
    fun al_get_parent_bitmap(Bitmap) : Bitmap
    fun al_get_bitmap_x(Bitmap) : Int
    fun al_get_bitmap_y(Bitmap) : Int
    fun al_reparent_bitmap(Bitmap, parent : Bitmap, x : Int, y : Int, w : Int, h : Int) : Void
    fun al_get_bitmap_blender(op : Int*, src : Int*, dst : Int*) : Void
    fun al_get_separate_bitmap_blender(op : Int*, src : Int*, dst : Int*, alpha_op : Int*, alpha_src : Int*, alpha_dst : Int*) : Void
    fun al_get_bitmap_blend_color : Color
    fun al_set_bitmap_blender(op : Int, src : Int, dest : Int) : Void
    fun al_set_separate_bitmap_blender(op : Int, src : Int, dst : Int, alpha_op : Int, alpha_src : Int, alpha_dst : Int) : Void
    fun al_set_bitmap_blend_color(Color) : Void
    fun al_reset_bitmap_blender : Void

    fun al_clear_to_color(Color) : Void
    fun al_clear_depth_buffer(z : Float) : Void
    fun al_draw_bitmap(Bitmap, dx : Float, dy : Float, flags : Int) : Void
    fun al_draw_tinted_bitmap(Bitmap, tint : Color, dx : Float, dy : Float, flags : Int) : Void
    fun al_draw_bitmap_region(Bitmap, sx : Float, sy : Float, sw : Float, sh : Float, dx : Float, dy : Float, flags : Int) : Void
    fun al_draw_tinted_bitmap_region(Bitmap, tint : Color, sx : Float, sy : Float, sw : Float, sh : Float, dx : Float, dy : Float, flags : Int) : Void
    fun al_draw_pixel(x : Float, y : Float, color : Color) : Void
    fun al_draw_rotated_bitmap(Bitmap, cx : Float, cy : Float, dx : Float, dy : Float, angle : Float, flags : Int) : Void
    fun al_draw_tinted_rotated_bitmap(Bitmap, tint : Color, cx : Float, cy : Float, dx : Float, dy : Float, angle : Float, flags : Int) : Void
    fun al_draw_scaled_rotated_bitmap(Bitmap, cx : Float, cy : Float, dx : Float, dy : Float, xscale : Float, yscale : Float, angle : Float, flags : Int) : Void
    fun al_draw_tinted_scaled_rotated_bitmap(Bitmap, tint : Color, cx : Float, cy : Float, dx : Float, dy : Float, xscale : Float, yscale : Float, angle : Float, flags : Int) : Void
    fun al_draw_tinted_scaled_rotated_bitmap_region(Bitmap, sx : Float, sy : Float, sw : Float, sh : Float, tint : Color, cx : Float, cy : Float, dx : Float, dy : Float, xscale : Float, yscale : Float, angle : Float, flags : Int) : Void
    fun al_draw_scaled_bitmap(Bitmap, sx : Float, sy : Float, sw : Float, sh : Float, dx : Float, dy : Float, dw : Float, dh : Float, flags : Int) : Void
    fun al_draw_tinted_scaled_bitmap(Bitmap, tint : Color, sx : Float, sy : Float, sw : Float, sh : Float, dx : Float, dy : Float, dw : Float, dh : Float, flags : Int) : Void
    fun al_get_target_bitmap : Bitmap
    fun al_put_pixel(x : Int, y : Int, color : Color) : Void
    fun al_put_blended_pixel(x : Int, y : Int, color : Color) : Void

    fun al_set_target_bitmap(Bitmap) : Void
    fun al_set_target_back_buffer(Display) : Void
    fun al_get_current_display : Display

    fun al_get_blender(op : Int*, src : Int*, dst : Int*) : Void
    fun al_get_separate_blender(op : Int*, src : Int*, dst : Int*, alpha_op : Int*, alpha_src : Int*, alpha_dst : Int*) : Void
    fun al_get_blend_color : Color
    fun al_set_blender(op : Int, src : Int, dst : Int) : Void
    fun al_set_separate_blender(op : Int, src : Int, dst : Int, alpha_op : Int, alpha_src : Int, alpha_dst : Int) : Void

    fun al_get_clipping_rectangle(x : Int*, y : Int*, w : Int*, h : Int*) : Void
    fun al_set_clipping_rectangle(x : Int, y : Int, w : Int, h : Int) : Void
    fun al_reset_clipping_rectangle : Void

    fun al_convert_mask_to_alpha(Bitmap, mask_color : Color) : Void

    fun al_hold_bitmap_drawing(Bool) : Void
    fun al_is_bitmap_drawing_held : Void

    fun al_register_bitmap_loader(extension : UInt8*, loader : (UInt8*, Int) -> Bitmap) : Bool
    fun al_register_bitmap_saver(extension : UInt8*, saver : (UInt8*, Bitmap) -> Bool) : Bool
    fun al_register_bitmap_loader_f(extension : UInt8*, fs_loader : (File, Int) -> Bitmap) : Bool
    fun al_register_bitmap_saver_f(extension : UInt8*, fs_saver : (File, Bitmap) -> Bitmap) : Bool

    @[Raises]
    fun al_load_bitmap(filename : UInt8*) : Bitmap
    @[Raises]
    fun al_load_bitmap_flags(filename : UInt8*, flags : Int) : Bitmap
    @[Raises]
    fun al_load_bitmap_f(File, ident : UInt8*) : Bitmap
    @[Raises]
    fun al_load_bitmap_flags_f(File, ident : UInt8*, flags : Int) : Bitmap
    @[Raises]
    fun al_save_bitmap(filename : UInt8*, bitmap : Bitmap) : Bool
    @[Raises]
    fun al_save_bitmap_f(filename : UInt8*, bitmap : Bitmap) : Bool

    fun al_register_bitmap_identifier(extension : UInt8*, idendifier : File -> Bool) : Bool
    fun al_identify_bitmap(filename : UInt8*) : UInt8*
    fun al_identify_bitmap_f(File) : UInt8*

    enum RenderState
      # ALPHA_TEST was the name of a rare bitmap flag only used on the
      # Wiz port.  Reuse the name but retain the same value.
      ALPHA_TEST       = 0x0010
      WRITE_MASK
      DEPTH_TEST
      DEPTH_FUNCTION
      ALPHA_FUNCTION
      ALPHA_TEST_VALUE
    end

    enum RenderFunction
      NEVER
      ALWAYS
      LESS
      EQUAL
      LESS_EQUAL
      GREATER
      NOT_EQUAL
      GREATER_EQUAL
    end

    @[Flags]
    enum RenderWriteMaskFlags
      RED   = 1 << 0
      GREEN = 1 << 1
      BLUE  = 1 << 2
      ALPHA = 1 << 3
      DEPTH = 1 << 4
      RGB   = (RED | GREEN | BLUE)
      RGBA  = (RGB | ALPHA)
    end

    # Keyboard

    enum Key : Int
      KEY_A =  1
      KEY_B =  2
      KEY_C =  3
      KEY_D =  4
      KEY_E =  5
      KEY_F =  6
      KEY_G =  7
      KEY_H =  8
      KEY_I =  9
      KEY_J = 10
      KEY_K = 11
      KEY_L = 12
      KEY_M = 13
      KEY_N = 14
      KEY_O = 15
      KEY_P = 16
      KEY_Q = 17
      KEY_R = 18
      KEY_S = 19
      KEY_T = 20
      KEY_U = 21
      KEY_V = 22
      KEY_W = 23
      KEY_X = 24
      KEY_Y = 25
      KEY_Z = 26

      KEY_0 = 27
      KEY_1 = 28
      KEY_2 = 29
      KEY_3 = 30
      KEY_4 = 31
      KEY_5 = 32
      KEY_6 = 33
      KEY_7 = 34
      KEY_8 = 35
      KEY_9 = 36

      KEY_PAD_0 = 37
      KEY_PAD_1 = 38
      KEY_PAD_2 = 39
      KEY_PAD_3 = 40
      KEY_PAD_4 = 41
      KEY_PAD_5 = 42
      KEY_PAD_6 = 43
      KEY_PAD_7 = 44
      KEY_PAD_8 = 45
      KEY_PAD_9 = 46

      KEY_F1  = 47
      KEY_F2  = 48
      KEY_F3  = 49
      KEY_F4  = 50
      KEY_F5  = 51
      KEY_F6  = 52
      KEY_F7  = 53
      KEY_F8  = 54
      KEY_F9  = 55
      KEY_F10 = 56
      KEY_F11 = 57
      KEY_F12 = 58

      KEY_ESCAPE     = 59
      KEY_TILDE      = 60
      KEY_MINUS      = 61
      KEY_EQUALS     = 62
      KEY_BACKSPACE  = 63
      KEY_TAB        = 64
      KEY_OPENBRACE  = 65
      KEY_CLOSEBRACE = 66
      KEY_ENTER      = 67
      KEY_SEMICOLON  = 68
      KEY_QUOTE      = 69
      KEY_BACKSLASH  = 70
      KEY_BACKSLASH2 = 71
      KEY_COMMA      = 72
      KEY_FULLSTOP   = 73
      KEY_SLASH      = 74
      KEY_SPACE      = 75

      KEY_INSERT = 76
      KEY_DELETE = 77
      KEY_HOME   = 78
      KEY_END    = 79
      KEY_PGUP   = 80
      KEY_PGDN   = 81
      KEY_LEFT   = 82
      KEY_RIGHT  = 83
      KEY_UP     = 84
      KEY_DOWN   = 85

      KEY_PAD_SLASH    = 86
      KEY_PAD_ASTERISK = 87
      KEY_PAD_MINUS    = 88
      KEY_PAD_PLUS     = 89
      KEY_PAD_DELETE   = 90
      KEY_PAD_ENTER    = 91

      KEY_PRINTSCREEN = 92
      KEY_PAUSE       = 93

      KEY_ABNT_C1    =  94
      KEY_YEN        =  95
      KEY_KANA       =  96
      KEY_CONVERT    =  97
      KEY_NOCONVERT  =  98
      KEY_AT         =  99
      KEY_CIRCUMFLEX = 100
      KEY_COLON2     = 101
      KEY_KANJI      = 102

      KEY_PAD_EQUALS = 103
      KEY_BACKQUOTE  = 104
      KEY_SEMICOLON2 = 105
      KEY_COMMAND    = 106

      KEY_BACK        = 107
      KEY_VOLUME_UP   = 108
      KEY_VOLUME_DOWN = 109

      KEY_SEARCH      = 110
      KEY_DPAD_CENTER = 111
      KEY_BUTTON_X    = 112
      KEY_BUTTON_Y    = 113
      KEY_DPAD_UP     = 114
      KEY_DPAD_DOWN   = 115
      KEY_DPAD_LEFT   = 116
      KEY_DPAD_RIGHT  = 117
      KEY_SELECT      = 118
      KEY_START       = 119
      KEY_BUTTON_L1   = 120
      KEY_BUTTON_R1   = 121
      KEY_BUTTON_L2   = 122
      KEY_BUTTON_R2   = 123
      KEY_BUTTON_A    = 124
      KEY_BUTTON_B    = 125
      KEY_THUMBL      = 126
      KEY_THUMBR      = 127

      KEY_UNKNOWN = 128

      KEY_MODIFIERS = 215

      KEY_LSHIFT     = 215
      KEY_RSHIFT     = 216
      KEY_LCTRL      = 217
      KEY_RCTRL      = 218
      KEY_ALT        = 219
      KEY_ALTGR      = 220
      KEY_LWIN       = 221
      KEY_RWIN       = 222
      KEY_MENU       = 223
      KEY_SCROLLLOCK = 224
      KEY_NUMLOCK    = 225
      KEY_CAPSLOCK   = 226

      MAX

      def name
        String.new(LibCore.al_keycode_to_name(self))
      end
    end

    @[Flags]
    enum KeyMod : Int
      SHIFT      = 0x00001
      CTRL       = 0x00002
      ALT        = 0x00004
      LWIN       = 0x00008
      RWIN       = 0x00010
      MENU       = 0x00020
      ALTGR      = 0x00040
      COMMAND    = 0x00080
      SCROLLLOCK = 0x00100
      NUMLOCK    = 0x00200
      CAPSLOCK   = 0x00400
      INALTSEQ   = 0x00800
      ACCENT1    = 0x01000
      ACCENT2    = 0x02000
      ACCENT3    = 0x04000
      ACCENT4    = 0x08000
    end

    NKEY_DOWN = (Key::MAX + 31) // 32

    struct KeyboardState
      display : Display
      key_down : UInt8[NKEY_DOWN]
    end

    fun al_install_keyboard : Bool
    fun al_is_keyboard_installed : Bool
    fun al_uninstall_keyboard : Void
    fun al_get_keyboard_state(ret_state : KeyboardState*) : Void
    fun al_clear_keyboard_state(display : Display) : Void
    fun al_key_down(KeyboardState*, keycode : Key) : Void
    fun al_keycode_to_name(keycode : Key) : UInt8*
    fun al_set_keyboard_leds(leds : KeyMod) : Bool
    fun al_get_keyboard_event_source : EventSource

    # Misc

    fun al_run_main(argc : Int, argv : UInt8**, user_main : (Int, UInt8**) -> Int) : Int

    # Timer

    fun al_create_timer(Double) : Timer
    fun al_start_timer(Timer) : Void
    fun al_stop_timer(Timer) : Void
    fun al_resume_timer(Timer) : Void
    fun al_get_timer_started(Timer) : Bool
    fun al_destroy_timer(Timer) : Void
    fun al_get_timer_count(Timer) : Int64
    fun al_set_timer_count(Timer, new_count : Int64) : Void
    fun al_add_timer_count(Timer, diff : Int64) : Void
    fun al_get_timer_speed(Timer) : Double
    fun al_set_timer_speed(Timer, speed : Double) : Void
    fun al_get_timer_event_source(Timer) : EventSource
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
  alias EventType = LibCore::EventType
  alias Key = LibCore::Key
  alias KeyModifiers = LibCore::KeyMod
end
