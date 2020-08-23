module Allegro
  @[Link(ldflags: "`pkg-config allegro_image-5`")]
  lib LibImage
    fun al_init_image_addon : Void
    fun al_is_image_addon_initialized : Bool
    fun al_shutdown_image_addon : Void
    fun al_get_allegro_image_version : UInt32
  end
end
