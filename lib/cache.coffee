
compiler = require './compiler'

module.exports = exports = (res, obj) ->
  if obj.cache
    obj.cache.push res
  else
    data = ''
    headers = []
    obj.cache = []
    fakeRes =
      setHeader: (key, val) ->
        headers.push([key, val])
        res.setHeader key, val
      write: (d) ->
        data += d.toString()
        res.write d
      end: ->
        res.end()
        arr = obj.cache
        obj.cache = 
          push: (res) ->
            headers.forEach ([k, v]) -> res.setHeader k, v
            res.send 200, data
        arr.forEach obj.cache.push

    compiler fakeRes, obj.type, obj.assets
