# stichはecoテンプレート
stitch = require('../assets/stitch')
Stitch = require('./stitch')

class Specs
  constructor: (@path) ->

  compile: ->
    @stitch  = new Stitch([@path])
# テンプレートに変数入れてるだけ
# @stitch.resolveはフラットにしたpathの配列を返す
    stitch(identifier: 'specs', modules: @stitch.resolve())

  createServer: ->
    (env, callback) =>
      callback(200,
        'Content-Type': 'text/javascript',
        @compile())

module.exports =
  Specs: Specs
  createPackage: (path) ->
    new Specs(path)