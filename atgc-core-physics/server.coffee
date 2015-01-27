
class module.exports

  constructor: (@app, @asset) ->

  authorize: ->
    yes

  getStatus: ->
    'ok'

  getClient: (position) ->
    @asset.client

  getclientSettings: ->
    @asset.clientSettings
