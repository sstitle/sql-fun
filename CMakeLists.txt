cmake_minimum_required(VERSION 3.15)
project(sql_fun VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED True)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

add_executable(sql_fun main.cpp)

install(TARGETS sql_fun DESTINATION bin)
