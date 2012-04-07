npath        = require('path')
fs           = require('fs')
compilers    = require('./compilers')
{modulerize} = require('./resolve')
{flatten}    = require('./utils')

class Stitch
  constructor: (@paths = []) ->
    # pathを綺麗に
    @paths = (npath.resolve(path) for path in @paths)

  # Moduleの配列をフラットな配列にする
  resolve: ->
    flatten(@walk(path) for path in @paths)

  # Private
  # 再帰的にたどってモジュールにしていく
  walk: (path, parent = path, result = []) ->
    return unless npath.existsSync(path)
    for child in fs.readdirSync(path)
      child = npath.join(path, child)
      stat  = fs.statSync(child)
      if stat.isDirectory()
        @walk(child, parent, result)
      else
        module = new Module(child, parent)
        result.push(module) if module.valid()
    result

class Module
  constructor: (@filename, @parent) ->
    # ドットを取り除く
    @ext = npath.extname(@filename).slice(1)
    @id  = modulerize(@filename.replace(npath.join(@parent, '/'), ''))

  compile: ->
    compilers[@ext](@filename)

  valid: ->
    !!compilers[@ext]

module.exports = Stitch