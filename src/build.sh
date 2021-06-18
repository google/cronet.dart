# Takes the path to wrapper source code path & cronet version as parameter
if [ $# -le 1 ]
  then
    echo "Provide <dir> '\"<cronet_version>\"'"
    exit 2
fi
cd $1
g++ -std=c++11 -DCRONET_VERSION=$2 -fPIC -rdynamic -shared -W -o wrapper.so wrapper.cc ../third_party/cronet_impl/sample_executor.cc ../third_party/dart-sdk/dart_api_dl.c -ldl -I../third_party/cronet/ -I../third_party/dart-sdk/ -DDART_SHARED_LIB -fpermissive -Wl,-z,origin -Wl,-rpath,'$ORIGIN' -Wl,-rpath,'$ORIGIN/cronet_binaries/linux64/'
