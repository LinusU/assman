
path = require 'path'
compiler = require './compiler'

state =
  top: ''
  map: {}

module.exports = exports =
  top: (top) -> state.top = top
  register: (type, name, assets) ->
    state.map['/' + name + '.' + type] = { type: type, name: name, assets: assets.map (e) -> path.join state.top, e }
  middleware: (req, res, next) ->
    if state.map[req.url]
      compiler res, state.map[req.url].type, state.map[req.url].assets
    else do next
