require "./allegro/lib.cr"
require "./allegro/lib_font.cr"

require "./allegro/display.cr"
require "./allegro/keyboard.cr"
require "./allegro/timer.cr"
require "./allegro/event.cr"

require "./allegro/font.cr"

# Allegro 5, game engine
module Allegro
  # Version number of the crystal binding library
  VERSION = "0.1.0"

  # Allegro Runtime Error
  class Error < Exception
  end

  # Allegro Assertion Failed
  class AssertionFailed < Exception
    def initialize(expr, file, line, func)
      msg = String.build do |io|
        io << "Allegro assertion `" << expr << "` failed at " << file <<
          "(" << line << "): in function '" << func << "'"
      end
      super(msg)
    end
  end

  # Main function wrapper of Allegro
  #
  # Normally, you don't have to call this method.
  #
  # You can implement your `main` function with adding
  # `-Dno_auto_allegro_main` flag. Typically, your `main` function looks like:
  #
  # ```
  # fun main(argc : Int32, argv : UInt8**) : Int32
  #   # Some additional process before initialize Allegro
  #   Allegro.main(argc, argv) do |ac, av|
  #     # Some additional process before initialize Crystal
  #     # (note: code inside `Allegro.main` may be run on a different
  #     #  thread from the one executed `main`. See Allegro's doc for
  #     #  `al_run_main`.)
  #     Crystal.main do
  #       # Some additional process before running user code
  #       Crystal.main_user_code(ac, av)
  #       # Some additional process after running user code
  #     rescue e : Exception
  #       # Catch up unhandled exceptions
  #     end
  #     # Some additional process after cleanup Crystal
  #     # (note: Allegro is already cleaned up here too)
  #   end
  #   # Some additional process after running main function.
  # end
  # ```
  #
  # If your environment does not properly initialize Crystal matter,
  # adding `-Dno_auto_allegro_main` and try to implement the `main`
  # function proper way. Please report an issue in this case.
  #
  # See also the documentation of `Crystal.main`.
  def self.main(argc : Int32, argv : Pointer(Pointer(UInt8)), &block : Int32, Pointer(Pointer(UInt8)) -> Int32)
    LibCore.al_run_main(argc, argv, block)
  end

  # Initialize Allegro library.
  #
  # It is safe to call this method multiple times.
  def self.initialize
    if !LibCore.al_install_system(VERSION_INT, AT_EXIT)
      raise Error.new("Failed to initialize Allegro")
    end
  end

  # Returns true if Allegro is initialized.
  def self.initialized?
    LibCore.al_is_system_installed
  end

  # Uninitialize Allegro
  #
  # Usually, you do not have to call this method manually.
  #
  # It is safe to call this method multiple times.
  #
  # Returns true if Allegro was initialized.
  def self.finalize
    LibCore.al_uninstall_system
  end

  # Runtime version of Allegro
  #
  # Returns tuple of Major, Minor, Revision and Release versions
  def self.version : Tuple(UInt32, UInt32, UInt32, UInt32)
    ver = LibCore.al_get_allegro_version
    maj = ver >> 24
    min = (ver >> 16) & 255
    rev = (ver >> 8) & 255
    rel = ver & 255
    {maj, min, rev, rel}
  end

  # :nodoc:
  ASSERTION_HANDLER = ->(expr : UInt8*, file : UInt8*, line : LibC::Int, func : UInt8*) do
    raise AssertionFailed.new(String.new(expr), String.new(file), line, String.new(func))
    nil
  end
  LibCore.al_register_assert_handler(ASSERTION_HANDLER)

  TRACE_HANDLER = ->(expr : UInt8*) do
    STDERR.puts String.new(expr)
  end
  LibCore.al_register_trace_handler(TRACE_HANDLER)
end

{% if !flag?(:no_auto_allegro_main) %}
  fun main(argc : Int32, argv : UInt8**) : Int32
    Allegro.main(argc, argv) do |ac, av|
      Crystal.main do
        Crystal.main_user_code(ac, av)
      rescue e : Exception
        STDERR << "Unhandled exception: "
        e.inspect_with_backtrace(STDERR)
        1
      end
    end
  end
{% end %}
