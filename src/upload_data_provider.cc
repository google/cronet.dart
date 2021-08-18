#include "upload_data_provider.h"
#include "wrapper_utils.h"
#include <algorithm>
#include <iostream>

extern std::unordered_map<Cronet_UrlRequestPtr, Dart_Port> requestNativePorts;

void UploadDataProvider::Init(int64_t length, Cronet_UrlRequestPtr request) {
  length_ = length;
  request_ = request;
}

int64_t UploadDataProvider::GetLength() { return length_; }

void UploadDataProvider::ReadFunc(Cronet_UploadDataSinkPtr upload_data_sink,
                                  Cronet_BufferPtr buffer) {
  DispatchCallback("ReadFunc", request_,
                   CallbackArgBuilder(2, upload_data_sink, buffer));
}

void UploadDataProvider::RewindFunc(Cronet_UploadDataSinkPtr upload_data_sink) {
  DispatchCallback("RewindFunc", request_,
                   CallbackArgBuilder(1, upload_data_sink));
}

void UploadDataProvider::CloseFunc() {
  DispatchCallback("CloseFunc", request_, CallbackArgBuilder(1, this));
}
