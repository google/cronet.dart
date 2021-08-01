#ifndef FLUTTER_PLUGIN_CRONET_PLUGIN_H_
#define FLUTTER_PLUGIN_CRONET_PLUGIN_H_

#include <flutter_linux/flutter_linux.h>

G_BEGIN_DECLS

#ifdef FLUTTER_PLUGIN_IMPL
#define FLUTTER_PLUGIN_EXPORT __attribute__((visibility("default")))
#else
#define FLUTTER_PLUGIN_EXPORT
#endif

typedef struct _CronetPlugin CronetPlugin;
typedef struct {
  GObjectClass parent_class;
} CronetPluginClass;

FLUTTER_PLUGIN_EXPORT GType cronet_plugin_get_type();

FLUTTER_PLUGIN_EXPORT void cronet_plugin_register_with_registrar(
    FlPluginRegistrar* registrar);

G_END_DECLS

#endif  // FLUTTER_PLUGIN_CRONET_PLUGIN_H_
