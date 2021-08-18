// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#ifndef UPLOAD_DATA_PROVIDER_H_
#define UPLOAD_DATA_PROVIDER_H_

#include "../third_party/cronet/cronet.idl_c.h"
#include "../third_party/dart-sdk/dart_api_dl.h"
#include "wrapper.h"

#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

// Expose Cronet_Buffer_GetSize, Cronet_Buffer_GetData;

class UploadDataProvider {
    public:
        // Sets the data to be uploaded.
        void SetData(char *data, int64_t length);
        void Init(int64_t length, Cronet_UrlRequestPtr request_);
        void ReadFunc(Cronet_UploadDataSinkPtr upload_data_sink,
                Cronet_BufferPtr buffer);
        void RewindFunc(Cronet_UploadDataSinkPtr upload_data_sink);
        void CloseFunc();
        // Gets the length of the data to be uploaded.
        int64_t GetLength();
    private:
        char *data_;
        // Length of the data.
        int64_t length_ = 0;
        // Pointer to the request |this| is providing to.
        Cronet_UrlRequestPtr request_;
        // Holds how many bytes of data has been uploaded.
        uint64_t bytesSent_ = 0;
};

#endif // UPLOAD_DATA_PROVIDER_H_
