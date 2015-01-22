
class module.exports

  constructor: (@app, @asset) ->

  authorize: -> yes

  getClient: (position) ->
    @asset.client

  getGenome: ->
    @asset.genome
