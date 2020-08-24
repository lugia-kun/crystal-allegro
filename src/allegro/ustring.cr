module Allegro
  struct StaticUString
  end

  struct EmptyUString
  end

  class AllocatedUString
  end

  alias ConstUString = StaticUString | EmptyUString
  alias AnyUString = ConstUString | AllocatedUString

  # This module define methods for any type of `AnyUString`s
  #
  # Note that UString is not mutable.
  module UString
    include Comparable(String)
    include Comparable(AnyUString)

    def <=>(str : String)
      self <=> StaticUString.new(str)
    end

    def <=>(str : AnyUString)
      LibCore.al_ustr_compare(@ptr, str)
    end

    def ==(str : String)
      self == StaticUString.new(str)
    end

    def ==(str : AnyUString)
      LibCore.al_ustr_equal(@ptr, str)
    end

    # Duplicate the string
    def dup : AllocatedUString
      ptr = LibCore.al_ustr_dup(@ptr)
      if ptr.null?
        raise Error.new("Failed to duplicate a string")
      end
      AllocatedUString.new(ptr)
    end

    # Converts to String
    def to_s
      ptr = LibCore.al_cstr(@ptr)
      siz = LibCore.al_ustr_size(@ptr)
      String.new(ptr, siz)
    end

    def to_s(io : ::IO)
      io << to_s
    end

    # Make byte `Slice` contains the data
    def to_slice(size : Int = self.bytesize, *, copy = true)
      strbytesize = self.bytesize
      cptr = LibCore.al_cstr(@ptr)
      if copy
        Bytes.new(size, read_only: false).tap do |slice|
          if size > strbytesize
            slice.copy_from(cptr, strbytesize)
          else
            slice.copy_from(cptr, size)
          end
        end
      else
        if size > strbytesize
          size = strbytesize
        end
        Bytes.new(cptr, size, read_only: true)
      end
    end

    def bytesize
      LibCore.al_ustr_size(@ptr)
    end

    def size
      LibCore.al_ustr_length(@ptr)
    end

    private def substring(start : Int, last : Int) : AllocatedUString
      ptr = LibCore.al_ustr_dup_substr(@ptr, start, last)
      if ptr.null?
        raise Error.new("Failed to create substring")
      end
      AllocatedUString.new(ptr)
    end

    private def substring?(strat : Int, last : Int) : AllocatedUString
      ptr = LibCore.al_ustr_dup_substr(@ptr, start, last)
      if ptr.null?
        nil
      else
        AllocatedUString.new(ptr)
      end
    end

    private def range_to_start_and_last(range : Range)
      s = range.begin
      e = range.end
      if range.excludes_end?
        e += 1
      end
      {s, e}
    end

    def [](index : Int32) : Char
      ord = LibCore.al_ustr_get(@ptr, index)
      if ord == -1
        raise IndexError.new
      end
      if ord == -2
        raise Error.new("Invalid byte sequence in UString")
      end
      ord.unsafe_chr
    end

    def [](range : Range) : AllocatedUString
      substring(*range_to_start_and_last(range))
    end

    def [](start : Int, count : Int) : AllocatedUString
      substring(start, start + count)
    end

    def []?(index : Int32) : Char?
      ord = LibCore.al_ustr_get(@ptr, index)
      if ord < 0
        nil
      else
        ord.unsafe_chr
      end
    end

    def []?(range : Range) : AllocatedUString?
      substring?(*range_to_start_and_last(range))
    end

    def []?(start : Int, count : Int) : AllocatedUString?
      substring?(start, start + count)
    end

    def =~(regex : Regex)
      to_s =~ regex
    end

    def byte_at(index, &block)
      slice = to_slice(copy: false)
      slice.at(index) do
        yield
      end
    end

    def byte_at(index)
      byte_at(index) { IndexError.new }
    end

    def byte_at?(index)
      byte_at(index) { nil }
    end

    def byte_index(byte : Int, offset = 0) : Int32?
      slice = to_slice(copy: false)
      slice.index?(byte, offset)
    end

    def bytes
      to_slice(copy: false).to_a
    end

    # Similar to `Char::Reader` which treats `Allegro::UString`
    # instead of `String`
    class Reader
      enum Error
        OutOfIndex      = -1
        InvalidSequence = -2
      end

      @ref_keeper : AllocatedUString? = nil
      @bytepos : LibCore::Int
      getter pos : Int32
      @ptr : LibCore::Ustr
      getter current_char : Char
      getter error : Error? = nil

      def initialize(string : AllocatedUString, pos : Int = 0)
        @ref_keeper = string
        @ptr = string.to_unsafe
        @pos = pos
        @bytepos = LibCore.al_ustr_offset(@ptr, @pos)
        @current_char = '\u{0}'
        next_char
      end

      def initialize(string : ConstUString, pos : Int = 0)
        @ptr = string.to_unsafe
        @pos = pos
        @bytepos = LibCore.al_ustr_offset(@ptr, @pos)
        @current_char = '\u{0}'
        next_char
      end

      def next_char
        ret = LibCore.al_ustr_get_next(@ptr, pointerof(@bytepos))
        if ret < 0
          @error = Error.new(ret)
          @current_char = '\u{0}'
          nil
        else
          @pos += 1
          @error = nil
          @current_char = ret.unsafe_chr
        end
      end

      def peek_next_char
        bytepos = @bytepos
        ret = LibCore.al_ustr_get_next(@ptr, pointerof(bytepos))
        if ret < 0
          @error = Error.new(ret)
          nil
        else
          @error = nil
          ret.unsafe_chr
        end
      end

      def previous_char
        ret = LibCore.al_ustr_prev_get(@ptr, pointerof(@bytepos))
        if ret < 0
          @error = Error.new(ret)
          nil
        else
          @pos -= 1
          @error = nil
          ret.unsafe_chr
        end
      end

      def pos=(index)
        @bytepos = LibCore.al_ustr_offset(@ptr, index)
        @pos = index
      end
    end

    class Builder < ::IO
      @str : AllocatedUString

      def initialize
        @str = EMPTY_STRING.dup
      end

      def read(slice : Bytes) : Nil
        raise "Not Implemented"
      end

      def write(slice : Bytes) : Nil
        ustr = StaticUString.new(slice)
        if !LibCore.al_ustr_append(@str, ustr)
          raise Error.new("Failed to append string")
        end
      end

      def <<(str : AnyUString)
        if !LibCore.al_ustr_append(@str, str.to_unsafe)
          raise Error.new("Failed to append string")
        end
        self
      end

      def <<(str : String)
        ustr = StaticUString.new(str)
        if !LibCore.al_ustr_append(@str, ustr)
          raise Error.new("Filed to append string")
        end
        self
      end

      def <<(obj)
        super(obj)
      end
    end

    # Similar to `String.build` that generates Allegro::AllocatedUString
    def self.build(&)
      builder = Builder.new
      yield builder
      builder.str
    end

    # Generates `AllocatedUString` from Slice containing UTF-16
    def self.from_utf16(slice : Slice(UInt16)) : AllocatedUString
      slice = Slice(UInt16).new(slice.size + 1) do |ptr|
        slice.copy_to(ptr, slice.size)
        ptr[slice.size] = 0_u16
      end
      ptr = LibCore.al_ustr_new_from_utf16(slice)
      if ptr.null?
        raise Error.new("Failed to create new UString")
      end
      AllocatedUString.new(ptr)
    end

    # Make a slice of UTF-16 string
    def to_utf16
      size = LibCore.al_ustr_size_utf16(@ptr)
      Slice(UInt16).new(size) do |ptr|
        LibCore.al_ustr_encode_utf16(@ptr, size)
      end
    end
  end

  # Statically allocated temporary Allegro-friendly UTF-8 string
  #
  # This is usually enough for Allegro counterpart of Crystal stdlib
  # String. However, the memory location cannot be moved, so you
  # cannot copy the struct. You need `#dup` to treat a string as an
  # objective manner.
  #
  # Modifying string will return AllocatedUString.
  struct StaticUString
    @ptr : LibCore::Ustr
    @info : LibCore::UstrInfo
    @ref : String | Bytes

    include UString

    def initialize(@ref)
      @info = uninitialized LibCore::UstrInfo
      @ptr = Pointer(Void).null.as(LibCore::Ustr)
    end

    # Returns pointer to `const ALLEGRO_USTR`
    #
    # WARNING: constness is not checked by API interface.
    def to_unsafe
      if @ptr.null?
        if @ref.is_a?(String)
          @ptr = LibCore.al_ref_cstr(pointerof(@info), @ref)
        else
          @ptr = LibCore.al_ref_buffer(pointerof(@info), @ref, @ref.size)
        end
      end
      @ptr
    end
  end

  # This is special UString that stores empty UString
  struct EmptyUString
    @ptr : LibCore::Ustr

    include UString

    def initialize
      @ptr = LibCore.al_ustr_empty_string
    end

    # Returns pointer to `const ALLEGRO_USTR`
    #
    # WARNING: constness is not checked by API interface.
    def to_unsafe
      @ptr
    end
  end

  # Allegro-friendly UTF-8 String
  #
  # This is used for that needs deallocation, or generated string by
  # Allegro library
  class AllocatedUString
    @ptr : LibCore::Ustr

    include UString

    def initialize(@ptr)
    end

    def finalize
      if !@ptr.null?
        LibCore.al_ustr_free(@ptr)
      end
    end

    # Returns pointer to `ALLEGRO_USTR`
    def to_unsafe
      @ptr
    end

    def self.from(string : String) : AllocatedUString
      ptr = LibCore.al_ustr_new_from_buffer(string, string.bytesize)
      if ptr.null?
        raise Error.new("Failed to create ALLEGRO_USTR from String")
      end
      AllocatedUString.new(ptr)
    end

    # Append string
    def <<(str : AnyUString)
      if !LibCore.al_ustr_append(@ptr, str)
        raise Error.new("Failed to append string")
      end
      self
    end

    # Append string
    def <<(str : String)
      if !LibCore.al_ustr_append_cstr(@ptr, str)
        raise Error.new("Failed to append string")
      end
      self
    end

    # Append single char
    def <<(chr : Char)
      if LibCore.al_ustr_append_chr(@ptr, chr.ord) == 0
        raise Error.new("Failed to append char")
      end
      self
    end
  end
end

class String
  include Comparable(Allegro::AnyUString)

  def <=>(other : Allegro::AnyUString)
    Allegro::StaticUString.new(self) <=> other
  end
end
