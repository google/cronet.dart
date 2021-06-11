#ifndef WRAPPER_EXPORT_H_
#define WRAPPER_EXPORT_H_

#if defined(WIN32)
#define CRONET_EXPORT __declspec(dllexport)
#else
#define CRONET_EXPORT __attribute__((visibility("default")))
#endif

#endif  // WRAPPER_EXPORT_H_