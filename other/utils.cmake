# SPDX-License-Identifier: BSD-2-Clause
cmake_minimum_required(VERSION 3.2)

set(SPACE " ")

function(JOIN VALUES GLUE OUTPUT)
  string (REPLACE ";" "${GLUE}" _TMP_STR "${VALUES}")
  set (${OUTPUT} "${_TMP_STR}" PARENT_SCOPE)
endfunction()

function(PREPEND var prefix)
   set(listVar "")
   foreach(f ${ARGN})
      list(APPEND listVar "${prefix}${f}")
   endforeach(f)
   set(${var} "${listVar}" PARENT_SCOPE)
endfunction(PREPEND)

macro(set_cross_compiler)

   set(CMAKE_C_COMPILER ${GCC_TOOLCHAIN}/${ARCH_GCC_TC}-linux-gcc)
   set(CMAKE_CXX_COMPILER ${GCC_TOOLCHAIN}/${ARCH_GCC_TC}-linux-g++)
   set(CMAKE_ASM_COMPILER ${GCC_TOOLCHAIN}/${ARCH_GCC_TC}-linux-gcc)
   set(OBJCOPY ${GCC_TOOLCHAIN}/${ARCH_GCC_TC}-linux-objcopy)
   set(STRIP ${GCC_TOOLCHAIN}/${ARCH_GCC_TC}-linux-strip)

endmacro()

# For the moment this macro is the same as set_cross_compiler()
macro(set_cross_compiler_userapps)

   set(CMAKE_C_COMPILER ${GCC_TOOLCHAIN}/${ARCH_GCC_TC}-linux-gcc)
   set(CMAKE_CXX_COMPILER ${GCC_TOOLCHAIN}/${ARCH_GCC_TC}-linux-g++)
   set(CMAKE_ASM_COMPILER ${GCC_TOOLCHAIN}/${ARCH_GCC_TC}-linux-gcc)
   set(OBJCOPY ${GCC_TOOLCHAIN}/${ARCH_GCC_TC}-linux-objcopy)
   set(STRIP ${GCC_TOOLCHAIN}/${ARCH_GCC_TC}-linux-strip)

endmacro()

# In case ARCH_GTESTS is ON, we want to use a cross-compiler BUT it has to use
# glibc instead of musl by default.
macro(set_cross_compiler_gtests)

   set(CMAKE_C_COMPILER ${GCC_TOOLCHAIN_GLIBC}/${ARCH_GCC_TC}-linux-gcc)
   set(CMAKE_CXX_COMPILER ${GCC_TOOLCHAIN_GLIBC}/${ARCH_GCC_TC}-linux-g++)
   set(CMAKE_ASM_COMPILER ${GCC_TOOLCHAIN_GLIBC}/${ARCH_GCC_TC}-linux-gcc)
   set(OBJCOPY ${GCC_TOOLCHAIN_GLIBC}/${ARCH_GCC_TC}-linux-objcopy)
   set(STRIP ${GCC_TOOLCHAIN_GLIBC}/${ARCH_GCC_TC}-linux-strip)

endmacro()

#message("CMAKE_ASM_COMPILE_OBJECT: ${CMAKE_ASM_COMPILE_OBJECT}")
#message("CMAKE_C_LINK_EXECUTABLE: ${CMAKE_C_LINK_EXECUTABLE}")
#message("CMAKE_C_COMPILE_OBJECT: ${CMAKE_C_COMPILE_OBJECT}")
#message("CMAKE_C_LINK_FLAGS: ${CMAKE_C_LINK_FLAGS}")
#message("CMAKE_CXX_COMPILE_OBJECT: ${CMAKE_CXX_COMPILE_OBJECT}")


function(h2d_char hc dec_out)

   if ("${hc}" MATCHES "[0-9]")
      set(${dec_out} ${hc} PARENT_SCOPE)
   elseif ("${hc}" STREQUAL "a")
      set(${dec_out} 10 PARENT_SCOPE)
   elseif("${hc}" STREQUAL "b")
      set(${dec_out} 11 PARENT_SCOPE)
   elseif("${hc}" STREQUAL "c")
      set(${dec_out} 12 PARENT_SCOPE)
   elseif("${hc}" STREQUAL "d")
      set(${dec_out} 13 PARENT_SCOPE)
   elseif("${hc}" STREQUAL "e")
      set(${dec_out} 14 PARENT_SCOPE)
   elseif("${hc}" STREQUAL "f")
      set(${dec_out} 15 PARENT_SCOPE)
   else()
      message(FATAL_ERROR "Invalid digit '${hc}'")
   endif()

endfunction()

function(hex2dec val out)

   if (NOT "${val}" MATCHES "^0x[0-9a-f]+$")
      message(FATAL_ERROR "Invalid hex number '${val}'")
   endif()

   string(LENGTH "${val}" len)
   math(EXPR len "${len} - 2")
   string(SUBSTRING "${val}" 2 ${len} val) # skip the "0x" prefix


   set(res 0)
   set(mul 1)
   math(EXPR len "${len} - 1")

   foreach (i RANGE "${len}")

      math(EXPR j "${len} - ${i}")
      string(SUBSTRING "${val}" ${j} 1 c)

      h2d_char(${c} c)

      math(EXPR res "${res} + ${c} * ${mul}")
      math(EXPR mul "${mul} * 16")

      if (${res} LESS 0)
         string(CONCAT err "The hex number 0x${val} is too big "
                           "for CMake: it does not fit in a signed 32-bit int")

         message(FATAL_ERROR "${err}")
      endif()

   endforeach()

   set(${out} ${res} PARENT_SCOPE)

endfunction()


function(dec2hex val out)

   if (NOT "${val}" MATCHES "^[0-9]+$")
      message(FATAL_ERROR "Invalid decimal number '${val}'")
   endif()

   set(hex_chars "0123456789abcdef")
   set(res "")

   if (${val} EQUAL 0)
      set(${out} "0x0" PARENT_SCOPE)
   else()

      while (${val} GREATER 0)

         math (EXPR q "${val} % 16")
         string(SUBSTRING "${hex_chars}" ${q} 1 c)
         set(res "${c}${res}")

         math (EXPR val "${val} / 16")
      endwhile()

      set(${out} "0x${res}" PARENT_SCOPE)

   endif()
endfunction()
