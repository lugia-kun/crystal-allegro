
module Allegro
  struct KeyboardState
    @state = LibCore::KeyboardState

    def initialize(@state = LibCore::KeyboardState.new)
    end

    def is_down?(key : Key)
      LibCore.al_key_down(pointerof(@state), key)
    end

    def to_unsafe
      pointerof(@state)
    end
  end

  module Keyboard
    def self.initialize
      if !LibCore.al_install_keyboard
        raise Error.new("Failed to install keyboard")
      end
    end

    def self.initialized?
      LibCore.al_is_keyboard_installed
    end

    def self.finalize
      LibCore.al_uninstall_keyboard
    end

    def self.state
      state = KeyboardState.new
      LibCore.al_get_keyboard_state(state)
      state
    end
  end
end
