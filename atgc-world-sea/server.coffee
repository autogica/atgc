class module.exports
  constructor: (@app, @asset) ->

  authorize: -> yes

  getClient: -> @asset.client

  getGenome: -> @asset.genome
