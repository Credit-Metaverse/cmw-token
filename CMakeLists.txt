cmake_minimum_required(VERSION 3.9)
project(hisoetoken)
include_directories(include)

if ("${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
    # we have to enable C++17 because apple implementation C++14 does not support variant
    set(CMAKE_CXX_STANDARD 17)
    set(CMAKE_CXX_STANDARD_REQUIRED ON)
    #    set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "/Users/valery/code/freelance/wax-cdt/build/modules")
    set(CMAKE_OSX_SYSROOT /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk)
    set(EOSIOLIB ${EOSIO}/eosiolib)
    add_definitions(-DNOEOS)


    add_executable(hisoetoken src/hisoetoken.cpp include/eosio.token/hisoetoken.hpp)
    target_include_directories(hisoetoken PUBLIC ${EOSIO}/ ${EOSIOLIB}/core ${EOSIOLIB}/contracts ${EOSIOLIB}/capi ${EOSIOLIB}/native)



else ()
    find_package(eosio.cdt REQUIRED)

    add_compile_options(-Os)
    add_contract(
            hisoetoken hisoetoken
            src/hisoetoken.cpp
    )
endif ()
