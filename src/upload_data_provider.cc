#include "upload_data_provider.h"
#include "wrapper_utils.h"
#include <algorithm>
#include <iostream>

extern std::unordered_map<Cronet_UrlRequestPtr, Dart_Port> requestNativePorts;

Cronet_RawDataPtr (*_Cronet_Buffer_GetData)(Cronet_BufferPtr);
uint64_t (*_Cronet_Buffer_GetSize)(Cronet_BufferPtr);
void (*_Cronet_UploadDataSink_OnReadSucceeded)(Cronet_UploadDataSinkPtr,
                                               uint64_t, bool);
void (*_Cronet_UploadDataSink_OnRewindSucceeded)(Cronet_UploadDataSinkPtr);

void InitCronetUploadApi(
    Cronet_RawDataPtr (*Cronet_Buffer_GetData)(Cronet_BufferPtr),
    uint64_t (*Cronet_Buffer_GetSize)(Cronet_BufferPtr),
    void (*Cronet_UploadDataSink_OnReadSucceeded)(Cronet_UploadDataSinkPtr,
                                                  uint64_t, bool),
    void (*Cronet_UploadDataSink_OnRewindSucceeded)(Cronet_UploadDataSinkPtr)) {
  if (!(Cronet_Buffer_GetData && Cronet_Buffer_GetSize &&
        Cronet_UploadDataSink_OnReadSucceeded &&
        Cronet_UploadDataSink_OnRewindSucceeded)) {
    std::cerr << "Invalid pointer(s): null" << std::endl;
    return;
  }
  _Cronet_Buffer_GetData = Cronet_Buffer_GetData;
  _Cronet_Buffer_GetSize = Cronet_Buffer_GetSize;
  _Cronet_UploadDataSink_OnReadSucceeded = Cronet_UploadDataSink_OnReadSucceeded;
  _Cronet_UploadDataSink_OnRewindSucceeded = Cronet_UploadDataSink_OnRewindSucceeded;
}

void UploadDataProvider::Init(int64_t length, Cronet_UrlRequestPtr request) {
  length_ = length;
  request_ = request;
}

void UploadDataProvider::SetData(char *data, int64_t length) {
  data_ = data;
  length_ = length;
  std::cout << "Data Set" << data_ << length_ << std::endl;
}

int64_t UploadDataProvider::GetLength() {std::cout << "Get length" << std::endl; return length_; }

void UploadDataProvider::ReadFunc(Cronet_UploadDataSinkPtr upload_data_sink,
                                  Cronet_BufferPtr buffer) {
  std::cout << "ReadFunc: length" << length_ << std::endl;
  uint64_t remainingBytes = length_ - bytesSent_;
  std::cout << "ReadFunc: remainingBytes" << remainingBytes << std::endl;
  uint64_t chunkSize = std::min(_Cronet_Buffer_GetSize(buffer), remainingBytes);
  std::cout << "ReadFunc: chunkSize" << chunkSize << std::endl;
  memcpy(_Cronet_Buffer_GetData(buffer), data_, chunkSize);
  bytesSent_ += chunkSize;
  _Cronet_UploadDataSink_OnReadSucceeded(upload_data_sink, chunkSize, false);
  DispatchCallback("ReadFunc", request_, CallbackArgBuilder(2, upload_data_sink, buffer));
}

void UploadDataProvider::RewindFunc(Cronet_UploadDataSinkPtr upload_data_sink) {
  std::cout << "RewindFunc" << std::endl;
  // bytesSent_ = 0;
  // _Cronet_UploadDataSink_OnRewindSucceeded(upload_data_sink);
  DispatchCallback("RewindFunc", request_, CallbackArgBuilder(1, upload_data_sink));
}

void UploadDataProvider::CloseFunc() {
  std::cout << "Upload Closed" << std::endl;
  DispatchCallback("CloseFunc", request_, CallbackArgBuilder(0));
}
