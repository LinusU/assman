
fs = require 'fs'
nib = require 'nib'
path = require 'path'
glob = require 'glob'
stylus = require 'stylus'
coffee = require 'coffee-script'

handleAsset = (res, asset, cb) ->

  m = asset.match /\.[a-z]+$/
  if m is null then throw new Error "Cannot find extension (#{asset})"

  done = (err, data) ->
    if err then cb err else
      res.write data
      cb null

  switch m[0]
    when '.js' then fs.readFile asset, done
    when '.css' then fs.readFile asset, done
    when '.styl'
      fs.readFile asset, (err, data) ->
        if err then done err else
          stylus(data.toString())
            .set('filename', asset)
            .set('paths', [ path.dirname asset ])
            .set('compress', true)
            .use(nib())
            .import('nib')
            .render(done)
    when '.coffee'
      fs.readFile asset, (err, data) ->
        if err then done err else
          done null, coffee.compile data.toString()
    else
      throw new Error "Cannot handle extension (#{m[0]})"

expandAssets = (assets, cb) ->
  result = []

  # Clone the array
  assets = assets.map (e) -> e

  do next = (err = null) ->
    if err
      cb err
    else if assets.length is 0
      cb null, result
    else
      a = assets.shift()
      if a.indexOf('*') is -1
        result.push a
        next null
      else
        glob a, (err, files) ->
          if err then next err else
            result = result.concat files
            next null

module.exports = exports = (res, type, assets) ->

  switch type
    when 'js' then res.setHeader 'Content-Type', 'text/javascript'
    when 'css' then res.setHeader 'Content-Type', 'text/css'
    else throw new Error "Unknown type (#{type})"

  expandAssets assets, (err, assets) ->
    do next = (err) ->
      if err
        console.log err.name + ':', err.message
        console.log err.stack
      if assets.length is 0
        res.end()
      else
        a = assets.shift()
        handleAsset res, a, next
