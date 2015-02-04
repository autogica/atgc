
class module.exports

  constructor: (@app, @asset) ->
    @jets = []


  # check if we can give access to a jet to the user
  authorize: -> yes

  # generate source code for the user
  getClient: (position) ->
    @asset.client

  # generate some settings for the user
  getClientSettings: ->
    @asset.clientSettings
