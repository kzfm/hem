Module = require('module')
# [pathモジュール](http://nodejs.org/docs/v0.6.14/api/path.html)
# #### join
# joinする
# #### extname
# 拡張子名が返る（ドットはついたまま）
# #### dirname
# ディレクトリ名が返る
# #### basename
#
#    path.basename('/foo/bar/baz/asdf/quux.html')
#    // returns
#    'quux.html'
#
#    path.basename('/foo/bar/baz/asdf/quux.html', '.html')
#    // returns
#    'quux'
#
# #### resolve
# 絶対パスをつくる
{join, extname, dirname, basename, resolve} = require('path')

#/からはじまるかどうか
isAbsolute = (path) -> /^\//.test(path)

# Normalize paths and remove extensions
# to create valid CommonJS module names
modulerize = (id, filename = id) ->
  ext = extname(filename)
  modName = join(dirname(id), basename(id, ext))
  modName.replace('\\', '/');

# 現在のディレクトリを_nodeModulePathsに設定
modulePaths = Module._nodeModulePaths(process.cwd())

invalidDirs = ['/', '.']

repl =
  id: 'repl'
  filename: join(process.cwd(), 'repl')
  paths: modulePaths

# Resolves a `require()` call. Pass in the name of the module where
# the call was made, and the path that was required.
# Returns an array of: [moduleName, scriptPath]
module.exports = (request, parent = repl) ->
# [Module](http://nodejs.org/docs/v0.6.14/api/modules.html)の内部メソッド
# \_resolveLookupPaths
#
#    > Module._resolveLookupPaths('spine')
#    [ 'spine',
#      [ '/Users/kzfm/.nvm/v0.6.14/lib/node_modules',
#        '/Users/kzfm/.node_modules',
#        '/Users/kzfm/.node_libraries',
#        '/Users/kzfm/.nvm/v0.6.14/lib/node' ] ]
#
# pathsが帰ってくるので_findPathで探す
#
#    > Module._findPath('hem',paths)
#    '/Users/kzfm/.nvm/v0.6.14/lib/node_modules/hem/lib/hem.js'
#
# dirにfilenameを突っ込んでるのは?
#
  [_, paths]  = Module._resolveLookupPaths(request, parent)
  filename    = Module._findPath(request, paths)
  dir         = filename

  throw("Cannot find module: #{request}. Have you run `npm install .` ?") unless filename

  # Find package root relative to localModules folder
  while dir not in invalidDirs and dir not in modulePaths
    dir = dirname(dir)

  throw("Load path not found for #{filename}") if dir in invalidDirs

# filenameからdir部分を削る
  id = filename.replace("#{dir}/", '')

# CommonJSのモジュール名とファイル名を返す
# modulerize参照
  [modulerize(id, filename), filename]

module.exports.paths = (filename) ->
  Module._nodeModulePaths(dirname(filename))

module.exports.modulerize = modulerize