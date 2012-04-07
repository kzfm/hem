{extname} = require('path')
fs        = require('fs')
# [これ](https://github.com/substack/node-detective)を参照
detective = require('fast-detective')
resolve   = require('./resolve')
compilers = require('./compilers')

mtime = (path) ->
  fs.statSync(path).mtime.valueOf()

class Module
  @walk: ['js', 'coffee']

  constructor: (request, parent) ->
    # modulenameとファイルパスが返ってくる
    [@id, @filename] = resolve(request, parent)
    @ext   = extname(@filename).slice(1)
    @mtime = mtime(@filename)
    @paths = resolve.paths(@filename)

  # 拡張子に応じてコンパイラを切り替える
  compile: ->
    if not @_compile or @changed()
      @mtime    = mtime(@filename)
      @_compile = compilers[@ext](@filename)
    @_compile

  modules: ->
    if not @_modules or @changed()
      @_modules = @resolve()
    @_modules

  # 更新されているかどうか
  changed: ->
    @mtime isnt mtime(@filename)

  resolve: ->
    for path in @calls()
  # これはどういうこと？
      new @constructor(path, @)

  # Find calls to require()
  calls: ->
# @constructor.walkがどこから来てるのかわからん
# @walkのことか？
    if @ext in @constructor.walk
      detective(@compile())
    else []

class Dependency
  constructor: (paths = []) ->
    @paths = paths

  resolve: ->
    @modules or= (new Module(path) for path in @paths)
    @deepResolve(@modules)

  # Private

  deepResolve: (modules = [], result = [], search = {}) ->
    for module in modules when not search[module.filename]
      search[module.filename] = true
      result.push(module)
      @deepResolve(
        module.modules(),
        result
        search
      )
    result

module.exports = Dependency
module.exports.Module = Module