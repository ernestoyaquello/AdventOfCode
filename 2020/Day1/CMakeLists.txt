cmake_minimum_required (VERSION 3.8)

add_executable (Day1 "day1.cpp" )
#add_executable (Day1 "day1_recursive.cpp" )
configure_file("input.txt" "input.txt" VS_COPY_TO_OUT_DIR)