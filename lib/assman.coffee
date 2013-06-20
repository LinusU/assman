
state =
  mode: (process.env.NODE_ENV || 'development')
  top: ''
  map: {}

exports._state = state

path = require 'path'
cache = require './cache'
compiler = require './compiler'

exports.top = (top) ->
  state.top = top

exports.register = (type, name, assets) ->
  state.map['/' + name + '.' + type] = { type: type, name: name, assets: assets.map (e) -> path.join state.top, e }

exports.middleware = (req, res, next) ->
  if state.map[req.url]
    if state.mode is 'production'
      cache res, state.map[req.url]
    else
      compiler res, state.map[req.url].type, state.map[req.url].assets
  else do next
