# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

cmake_minimum_required(VERSION 3.5)

file(MAKE_DIRECTORY
  "C:/Users/Ori/AndroidStudioProjects/orsapp/windows/out/build/x64-Debug/_deps/nuget-src"
  "C:/Users/Ori/AndroidStudioProjects/orsapp/windows/out/build/x64-Debug/_deps/nuget-build"
  "C:/Users/Ori/AndroidStudioProjects/orsapp/windows/out/build/x64-Debug/_deps/nuget-subbuild/nuget-populate-prefix"
  "C:/Users/Ori/AndroidStudioProjects/orsapp/windows/out/build/x64-Debug/_deps/nuget-subbuild/nuget-populate-prefix/tmp"
  "C:/Users/Ori/AndroidStudioProjects/orsapp/windows/out/build/x64-Debug/_deps/nuget-subbuild/nuget-populate-prefix/src/nuget-populate-stamp"
  "C:/Users/Ori/AndroidStudioProjects/orsapp/windows/out/build/x64-Debug/_deps/nuget-subbuild/nuget-populate-prefix/src"
  "C:/Users/Ori/AndroidStudioProjects/orsapp/windows/out/build/x64-Debug/_deps/nuget-subbuild/nuget-populate-prefix/src/nuget-populate-stamp"
)

set(configSubDirs )
foreach(subDir IN LISTS configSubDirs)
    file(MAKE_DIRECTORY "C:/Users/Ori/AndroidStudioProjects/orsapp/windows/out/build/x64-Debug/_deps/nuget-subbuild/nuget-populate-prefix/src/nuget-populate-stamp/${subDir}")
endforeach()
