project(
  'lua-5.4', 'c',
  license: 'MIT',
  meson_version: '>=0.49.2',
  version: '5.4.4',
)

lua_versions = meson.project_version().split('.')
# Override the c_std and warning_level of any superproject.
project_options = ['c_std=c99', 'warning_level=2']
cc = meson.get_compiler('c')

# Skip bogus warning.
if cc.get_id() == 'clang'
  add_project_arguments('-Wno-string-plus-int', language: 'c')
elif cc.get_id() == 'gcc'
  add_project_arguments('-Wno-stringop-overflow', language: 'c')
endif

# Platform-specific defines.
is_posix = host_machine.system() not in ['windows', 'emscripten', 'android']
if is_posix
  add_project_arguments('-DLUA_USE_POSIX', language: 'c')
elif get_option('default_library') != 'static'
  add_project_arguments('-DLUA_BUILD_AS_DLL', language: 'c')
endif

# Library dependencies.
lua_lib_deps = [cc.find_library('m', required: false)]

if get_option('loadlib')
  dl_dep = cc.find_library('dl', required: false)
  lua_lib_deps += [dl_dep]
  add_project_arguments('-DLUA_USE_DLOPEN', language: 'c')
endif


# Interpreter dependencies.
lua_exe_deps = []
lua_exe_args = []

if get_option('line_editing')
  readline_dep = dependency('readline', required: false)
  if not readline_dep.found()
    readline_dep = dependency('libedit', required: false)
    if not readline_dep.found()
      error('''Didn't find readline or libedit, can't enable line editing.''')
    endif
  endif
  lua_exe_deps += [readline_dep]
  lua_exe_args += ['-DLUA_USE_READLINE']
endif

# Targets.
lua_lib = library('lua',
  'src/lapi.c',
  'src/lauxlib.c',
  'src/lbaselib.c',
  'src/lcode.c',
  'src/lcorolib.c',
  'src/lctype.c',
  'src/ldblib.c',
  'src/ldebug.c',
  'src/ldo.c',
  'src/ldump.c',
  'src/lfunc.c',
  'src/lgc.c',
  'src/linit.c',
  'src/liolib.c',
  'src/llex.c',
  'src/lmathlib.c',
  'src/lmem.c',
  'src/loadlib.c',
  'src/lobject.c',
  'src/lopcodes.c',
  'src/loslib.c',
  'src/lparser.c',
  'src/lstate.c',
  'src/lstring.c',
  'src/lstrlib.c',
  'src/ltable.c',
  'src/ltablib.c',
  'src/ltm.c',
  'src/lundump.c',
  'src/lutf8lib.c',
  'src/lvm.c',
  'src/lzio.c',
  dependencies: lua_lib_deps,
  version: meson.project_version(),
  soversion: lua_versions[0] + '.' + lua_versions[1],
  override_options: project_options,
  implicit_include_directories: false,
)

lua_link = lua_lib

if get_option('interpreter')
  lua_exe = executable('lua',
    'src/lua.c',
    c_args: lua_exe_args,
    link_with: lua_link,
    dependencies: lua_exe_deps,
    export_dynamic: get_option('loadlib'),
    override_options: project_options,
    implicit_include_directories: false,
  )

  if get_option('default_library') == 'static'
    luac_exe = executable('luac',
      'src/luac.c',
      link_with: lua_link,
      override_options: project_options,
      implicit_include_directories: false,
    )
  endif
endif

inc = include_directories('src')
lua_dep = declare_dependency(link_with: lua_lib, include_directories: inc)
