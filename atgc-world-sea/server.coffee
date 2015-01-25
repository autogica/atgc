class module.exports
  constructor: (@app, @asset) ->

  authorize: -> yes

  getClient: -> @asset.client

  getClientSettings: -> @asset.clientSettings
