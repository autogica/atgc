
class module.exports

  constructor: (@app, @asset) ->
    @owners = {}

  authorize: (entity) ->
    #console.log "checking authorization for entity #{entity}"
    yes

  canUse: (entity) ->
    console.log "checking if entity #{entity} can use item.."
    yes

  getClient: (position) ->
    @asset.client

  getClientSettings: ->
    @asset.clientSettings
