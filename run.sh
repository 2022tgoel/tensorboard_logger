cd proto/ 
/home/gridsan/dliveoak/.conda/envs/ml2/bin/protoc *.proto --cpp_out=./
cd ..
mkdir build && cd build
cmake .. -DBUILD_TEST=ON