


class module.exports

  constructor: (old) ->

    @series = {}
    @installed = no
    @changed = no
    if old?
      @series = old.series ? {}
      @installed = old.installed ? no

  config: (conf) -> conf

  update: (init) ->
    if init

      console.log "atgc-core-metrics.update init: connecting to InfluxDB.."
      influxdb = new InfluxDB
        host: @conf.influxdb.host ? 'localhost'
        port: @conf.influxdb.port ? '8086'
        username: @conf.influxdb.username ? 'atgc'
        password: @conf.influxdb.password ? 'atgc'
        database: @conf.influxdb.database ? 'atgc'

      @influxdb = influxdb

      unless @installed
        @installed = yes
        @changed = yes
        syncOftenIfNecessary = =>
          if @changed
            @changed = no
            for serie, values of @series
              influxdb.writePoint serie, values
        setInterval syncOftenIfNecessary, 500

        syncRarelyAlways = =>
          for serie, values of @series
            influxdb.writePoint serie, values
        setInterval syncRarelyAlways, 5000

  addValue: (serie, key, value) ->
    console.log "atgc-core-metrics.addValue(#{key}, #{value})"
    unless serie of @series
      @series[serie] = {}

    @series[serie][key] ?= 0
    @series[serie][key] += value

    @changed = yes

  inc: (serie, key, value=1) ->
    @addValue serie, key, value

  dec: (serie, key, value=1) ->
    @addValue serie, key, -value


  render: ->
