
module Allegro
  module Image
    def self.initialize
      if !LibImage.al_init_image_addon
        raise Error.new("Failed initalize Image Addon")
      end
    end

    def self.initialized?
      LibImage.al_is_image_addon_initialized
    end

    def self.finalize
      LibImage.al_shutdown_image_addon
    end

    def self.version
      Allegro.version_to_tuple(LibImage.al_get_allegro_image_version)
    end
  end
end
