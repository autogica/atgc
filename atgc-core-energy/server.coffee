
###
Decajoule
###
if !0.daJ?
  Object.defineProperty Number.prototype, "daJ",
    enumerable: no
    configurable: no
    get: -> @ * 10

###
Hectojoule
Order of magnitude: "3×102 J: kinetic energy of an average person jumping as high as they can" (Wikipedia)
###
if !0.hJ?
  Object.defineProperty Number.prototype, "hJ",
    enumerable: no
    configurable: no
    get: -> @ * 10 ** 2

###
Kilojoule
Order of magnitude: "to vaporize 1 gram of almost any material, such as
aluminum, requires approximately 10kJ" (Internet)

" a successful HEL weapon will have to be able to deliver at least 5,000-10,000
joules per square centimeter on the target." (Internet)
###
if !0.kJ?
  Object.defineProperty Number.prototype, "kJ",
    enumerable: no
    configurable: no
    get: -> @ * 10 ** 3

###
Megajoule
###
if !0.MJ?
  Object.defineProperty Number.prototype, "MJ",
    enumerable: no
    configurable: no
    get: -> @ * 10 ** 6

###
Gigajoule
Order of magnitude: "6 GJ is about the amount of potential chemical energy in
a barrel of oil, when combusted" (Wikipedia)
###
if !0.GJ?
  Object.defineProperty Number.prototype, "GJ",
    enumerable: no
    configurable: no
    get: -> @ * 10 ** 9

###
Terajoule
Order of magnitude: "6.4×1012 J: energy contained in jet fuel in a
Boeing 747-100B aircraft at max fuel capacity" (Wikipedia)
###
if !0.TJ?
  Object.defineProperty Number.prototype, "TJ",
    enumerable: no
    configurable: no
    get: -> @ * 10 ** 12

###
Petajoule
Order of magnitude: "1×1015 J: yearly electricity consumption in Greenland as
of 2008" (Wikipedia)
###
if !0.PJ?
  Object.defineProperty Number.prototype, "PJ",
    enumerable: no
    configurable: no
    get: -> @ * 10 ** 15



class module.exports

  constructor: (@app, @asset) ->

    # target level of energy
    # if there is use more than this in circulation, we increase
    # dissipation, if there is less, we reduce it
    @targetGlobalEnergyLevel = 1000

    # account holding the energy for each entity
    @root = "atgc-core-energy/root"

    @accounts = {}
    @accounts[@root.id] = energy: 10


  # check if we can give access to core-energy to the user
  authorize: -> yes

  # generate source code for the user
  getClient: (position) ->
    @asset.client

  # generate some settings for the user
  getClientSettings: ->
    @asset.clientSettings

  ###
  update energy of en entity, by adding up an amount
  if the amount is negative, the entity's account will be
  decreased, otherwise it is increased
  if the entity is new and has no account, a new one will be created
  this method should never be called directly
  ###
  _update: (id, amount, onComplete) ->
    unless id?
      throw "cannot update entity's energy level: invalid entity id"
    if isNaN(amount) or !isFinite(amount)
      amount = 0

    # create account if it does not exist
    account = @accounts[id]
    unless account?
      account = @accounts[id] = energy: 0

    # do the actual update
    account.energy += amount

    # return the new energy level for this entity
    onComplete account.energy

    return

  ###
  transfer energy from one system to another
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
