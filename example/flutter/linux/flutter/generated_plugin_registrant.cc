//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <cronet/cronet_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) cronet_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "CronetPlugin");
  cronet_plugin_register_with_registrar(cronet_registrar);
}
