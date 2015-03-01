
class module.exports

  constructor: ->

  config: (conf) -> conf

  update: (init) ->
    if init
      console.log @conf
      host = @conf.influxdb.host
      port = @conf.influxdb.port
      username = @conf.influxdb.username
      password = @conf.influxdb.password
      database = @conf.influxdb.database

      console.log "atgc-core-metrics.update init: connecting to InfluxDB.."
      influxdb = new InfluxDB host, port, username, password, database

      @influxdb = influxdb

      @write = (key, values) ->
        influxdb.writePoint key, values

  write: (key, values) ->
    console.log "atgc-core-metrics.write: not connect to server yet, ignoring update to #{key}"

  render: ->
