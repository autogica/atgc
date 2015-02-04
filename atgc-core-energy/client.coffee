

###
Manages the energy in the scene
###
class module.exports

  constructor: (old) ->

    if old?
      @objects = old.objects
      @material = old.material
      @geometry = old.geometry

  config: (conf) ->

    length: conf.length

  remove: (obj) ->

  render: ->


  ###
  transfer energy from one unit to another
  energy transfers are unidirectional because it's easier
  to understand, log and trace errors.
  if you want to transfer from target to source, you have to
  do it manually
  ###
  transfer: (source, target, joules, onComplete) ->
    joules = Math.abs joules

    @_update source, -joules, (newEnergyLevelForSource) ->
      @_update source, +joules, (newEnergyLevelForTarget) ->
        console.log "atgc-core-energy: transfered #{joules} from #{source.id} (now #{newEnergyLevelForSource}J) to #{target.id} (now #{newEnergyLevelForTarget}J)"
        onComplete joules

  get: (id) ->
    unless id?
      throw "cannot update entity's energy level: invalid entity id"

    account = @accounts[id]
    unless account?
      account = @accounts[id] = energy: 0

    return account.energy

        # do th
  test: (onComplete) ->

    foo = "atgc-core-energy/tests/test1/foo"

    bar = "atgc-core-energy/tests/test1/bar"

    @transfer @root, foo, 10.kJ, =>
      @transfer @root, bar, 20.kJ, =>
        @transfer foo, bar, 5.kj, =>
          fooJ = @get foo
          barJ = @get bar
          unless fooJ is barJ
            throw "test failed"
          console.log "test passed: #{fooJ} equals #{barJ}"
