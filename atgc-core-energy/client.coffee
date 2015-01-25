

###
Manages all the jets at the same time
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

  ###
  Update jets
  ###
  render: ->


  build: ->

  # Returns options to build a segment
  #
  # Options are spline points etc..
  #
  getBuildOptions: ->
    splinePoints:
      type: "new THREE.Vector3"
      args: 3

  # Returns build price
  #
  #
  getBuildPrice: (opts, cb) ->
    # price depends upon:
    # - volume
    # - material properties (weight, rigidity..)

  #
  # Build part. the account will be debited.
  #
  buildPart: (account, opts, cb) ->

    splinePoints = for args in opts.splinePoints
      new THREE.Vector3 args[0], args[1], args[2]

    pipeSpline = new THREE.SplineCurve3 splinePoints


    cb
      splinePoints: splinePoints
      pipeSpline: pipeSpline

    return

  # called at loading. Tests should not impact production,
  # and clean after themselves
  test: ->

    testOpts =
      splinePoints: [
        [0, 10, -10]
        [10, 0, -10]
        [20, 0, 0]
        [30, 0, 10]
        [30, 0, 20]
        [20, 0, 30]
        [10, 0, 30]
        [0, 0, 30]
      ]

    console.log "calling buildPart with these options:", testOpts
    @buildPart testOpts, (result) ->
      console.log "result from buildPart: ", result
