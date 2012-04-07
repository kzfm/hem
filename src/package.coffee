fs           = require('fs')
# これどこで使うの？
eco          = require('eco')
uglify       = require('uglify-js')
compilers    = require('./compilers')
stitch       = require('../assets/stitch')
Dependency   = require('./dependency')
Stitch       = require('./stitch')
{toArray}    = require('./utils')

class Package
  constructor: (config = {}) ->
    @identifier   = config.identifier
    @libs         = toArray(config.libs)
    @paths        = toArray(config.paths)
    @dependencies = toArray(config.dependencies)

  compileModules: ->
    @dependency or= new Dependency(@dependencies)
    @stitch       = new Stitch(@paths)
    @modules      = @dependency.resolve().concat(@stitch.resolve())
    stitch(identifier: @identifier, modules: @modules)

  # @libsのファイルを読み込んで改行で連結する
  compileLibs: ->
    (fs.readFileSync(path, 'utf8') for path in @libs).join("\n")

　# コンパイルしたライブラリとモジュールを改行で連結して、uglifyを使ってミニファイ
  compile: (minify) ->
    result = [@compileLibs(), @compileModules()].join("\n")
    result = uglify(result) if minify
    result

  createServer: ->
    (env, callback) =>
      callback(200,
        'Content-Type': 'text/javascript',
        @compile())

module.exports =
  compilers:  compilers
  Package:    Package
  createPackage: (config) ->
    new Package(config)