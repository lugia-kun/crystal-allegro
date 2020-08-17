# Usage \{{ run("get_macro_defs.cr", cflags, header_file) }}

require "string_scanner"

CFLAGS_BASE     = ARGV.shift
HeaderFile      = ARGV.shift
CC              = ENV["CRYSTAL_ALLEGRO_CC"]? || "gcc"
CFLAGS_OVERRIDE = ENV["CRYSTAL_ALLEGRO_CFLAGS"]?

cmd = String.build do |str|
  str << CC << " " << CFLAGS_BASE
  if CFLAGS_OVERRIDE
    str << CFLAGS_OVERRIDE
  end
  str << " -dM -E -x c -"
end

STDOUT << "# Getting macro data for <" << HeaderFile << ">\n"
STDOUT << "# via executing " << cmd.inspect << "\n"
ret = Process.run(cmd, shell: true, error: Process::Redirect::Inherit) do |prc|
  prc.input << "#include <" << HeaderFile << ">\n" <<
    "#ifdef _cplusplus\n" <<
    "#error You have invoked C++ compiler\n" <<
    "#endif"
  prc.input.close
  prc.output.gets_to_end
end

# :nodoc:
#
# This file does not required from main code, directly
struct DefData
  property name : String
  property arguments : String?
  property value : String?

  def initialize(@name, @arguments, @value)
  end
end

scanner = StringScanner.new(ret)
defdata = [] of DefData
while scanner.skip_until(/#define +/)
  name = scanner.scan(/[a-zA-Z_][a-zA-Z0-9_]*/).not_nil!
  args = nil
  value = nil
  if scanner.scan(/ *\( *([a-zA-Z_][a-zA-Z0-9_]*|\))/)
    args = String.build do |io|
      m = scanner[1]
      if m != ")"
        io << m
        if scanner.scan(/(( *, *[a-zA-Z_][a-zA-Z0-9_]*)*)\)/)
          io << scanner[1]
        end
      end
    end
  end
  if scanner.scan(/ +/)
    value = scanner.scan_until(/\n/).try(&.chomp)
  end
  defdata << DefData.new(name, args, value)
end

defdata.sort_by!(&.name)
STDOUT.print "{\n"
defdata.each do |data|
  if data.arguments.nil?
    STDOUT << "  " << data.name.inspect << " => "
    if (v = data.value) && !v.empty?
      STDOUT << v.inspect
    else
      STDOUT << "nil"
    end
    STDOUT << ",\n"
  end
end
STDOUT.print "} of String => String?\n"
