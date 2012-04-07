{resolve} = require('path')
compilers = require('./compilers')

class CSS
  constructor: (path) ->
    try
# pathの解決をする
#
# [require.resolve](http://nodejs.org/docs/v0.6.14/api/globals.html#globals_require_resolve)
# と
# [path.resolve](http://nodejs.org/docs/v0.6.14/api/path.html#path_path_resolve_from_to)

      @path = require.resolve(resolve(path))
    catch e
  # キャッシュを削除してrequireし直す
  compile: ->
    return unless @path
    delete require.cache[@path]
    require(@path)
  # どこで使うかよくわからん
  createServer: ->
    (env, callback) =>
      callback(200,
        'Content-Type': 'text/css',
        @compile())

module.exports =
  CSS: CSS
  createPackage: (path) ->
    new CSS(path)