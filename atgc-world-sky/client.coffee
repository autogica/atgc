class module.exports

  constructor: ->
    @position = [0, 0, 0] # center of the object
    @range = 100000 # some can have infinite range
    @hour = 0

  # read / transform config
  config: (conf) ->

    radius: conf.radius
    segmentsWidth: conf.segmentsWidth
    segmentsHeight: conf.segmentsHeight

    hemiLightSkyColorH: conf.hemiLightSkyColorHSL[0]
    hemiLightSkyColorS: conf.hemiLightSkyColorHSL[1]
    hemiLightSkyColorL: conf.hemiLightSkyColorHSL[2]
    hemiLightGroundColorH: conf.hemiLightGroundColorHSL[0]
    hemiLightGroundColorS: conf.hemiLightGroundColorHSL[1]
    hemiLightGroundColorL: conf.hemiLightGroundColorHSL[2]
    hemiLightIntensity: conf.hemiLightIntensity
    hemiLightAltitude: conf.hemiLightAltitude

    spotLightColorH: conf.spotLightColorHSL[0]
    spotLightColorS: conf.spotLightColorHSL[1]
    spotLightColorL: conf.spotLightColorHSL[2]
    spotLightShadowDarkness: conf.spotLightShadowDarkness
    spotLightShadowBias: conf.spotLightShadowBias
    spotLightIntensity: conf.spotLightIntensity
    spotLightDistance: conf.spotLightDistance

    fogDensity: conf.fogDensity
    fogColorH: conf.fogColorHSL[0]
    fogColorS: conf.fogColorHSL[1]
    fogColorL: conf.fogColorHSL[2]
    fogNear: conf.fogNear
    fogFar: conf.fogFar

    temperature: conf.temperature
    humidity: conf.humidity
    wind: conf.wind


    turbidity: conf.turbidity # min: 1.0, max: 20.0
    reileigh: conf.reileigh # min: 0.0, max: 4.0
    mieCoefficient: conf.mieCoefficient # min: 0.0, max: 0.1
    mieDirectionalG: conf.mieDirectionalG # min: 0.0, max: 1.0
    luminance: conf.luminance # min: 0.0, max: 2.0
    inclination: conf.inclination # min: 0.0, max: 1.0, elevation / inclination
    azimuth: conf.azimuth # min: 0.0, max: 1.0, Facing front
    distance: conf.distance


  addLight: ( h, s, l, x, y, z ) ->
    light = new THREE.PointLight 0xffffff, 1.5, 4500
    light.color.setHSL h, s, l
    light.position.set x, y, z
    @app.scene.add light

    flareColor = new THREE.Color 0xffffff
    flareColor.setHSL h, s, l + 0.5

    lensFlare = new THREE.LensFlare @textureFlare0, 700, 0.0, THREE.AdditiveBlending, flareColor

    lensFlare.add @textureFlare2, 512, 0.0,  THREE.AdditiveBlending
    lensFlare.add @textureFlare2, 512, 0.0,  THREE.AdditiveBlending
    lensFlare.add @textureFlare2, 512, 0.0,  THREE.AdditiveBlending

    lensFlare.add @textureFlare3, 60,  0.6,  THREE.AdditiveBlending
    lensFlare.add @textureFlare3, 70,  0.7,  THREE.AdditiveBlending
    lensFlare.add @textureFlare3, 120, 0.9,  THREE.AdditiveBlending
    lensFlare.add @textureFlare3, 70,  1.0,  THREE.AdditiveBlending

    lensFlare.customUpdateCallback = (object) ->
      vecX =  - object.positionScreen.x * 2
      vecY =  - object.positionScreen.y * 2

      for f in [0...object.lensFlares.length]
        flare = object.lensFlares[ f ]
        flare.x = object.positionScreen.x + vecX * flare.distance
        flare.y = object.positionScreen.y + vecY * flare.distance
        flare.rotation = 0

        object.lensFlares[ 2 ].y += 0.025
        object.lensFlares[ 3 ].rotation = object.positionScreen.x * 0.5 + THREE.Math.degToRad( 45 )

        lensFlare.position.copy light.position
        @app.scene.add lensFlare


  # called whenever the config file change. init will be true if src changed
  update: (init) ->

    # reset is true when we need to reinstall stuff
    if init
      console.log @conf
      # actually we cannot remove fog, just change the density

      # fog is disabled
      if @app.scene.fog?
        @app.scene.fog.density = 0
      else
        @app.scene.fog = new THREE.Fog 0xffffff, @conf.fogNear, @conf.fogFar
        @app.scene.fog.density = 0


      if @sky?
        console.log "there is already a sky"
        # sky mesh
      else
        @sky = new THREE.Sky()
        @app.scene.add @sky.mesh

      if @geometry?
        0
      else
        #@geometry = new THREE.SphereGeometry @conf.radius, @conf.segmentsWidth, @conf.segmentsHeight
        @geometry = new THREE.SphereGeometry 20000, 30, 30

      if @material?
        0
      else
        #@material = new THREE.MeshBasicMaterial shading: THREE.FlatShading
        # sunMaterial
        @material = new THREE.MeshBasicMaterial
          color: 0xffffff
          wireframe: no
          shading: THREE.FlatShading
          fog: no # do not apply fog color on it


      if @mesh?
        @app.scene.remove @mesh
        delete @mesh['material'] # not necessary?
        delete @mesh['geometry'] # not necessary?

      @mesh = new THREE.Mesh @geometry, @material
      #mesh.position.set 10, 1000, 10 # old
      @mesh.position.y = -700000
      @mesh.visible = yes

      @app.scene.add @mesh
      @textureFlare0 = THREE.ImageUtils.loadTexture "textures/lensflare/lensflare0.png"
      @textureFlare2 = THREE.ImageUtils.loadTexture "textures/lensflare/lensflare2.png"
      @textureFlare3 = THREE.ImageUtils.loadTexture "textures/lensflare/lensflare3.png"
      @addLight 0.55, 0.9, 0.5, 5000, 0, -1000

      # texture used for clouds
      @textureCloud = THREE.ImageUtils.loadTexture 'textures/cloud10.png'
      @textureCloud.magFilter = THREE.LinearMipMapLinearFilter
      @textureCloud.minFilter = THREE.LinearMipMapLinearFilter

      # global illumination
      #@ambient = new THREE.AmbientLight 0xffeebb
      #@app.scene.add @ambient


      # old version
      #@app.renderer.gammaInput = yes
      #@app.renderer.gammaOutput = yes
      #@app.renderer.shadowMapEnabled = yes
      #@app.renderer.shadowMapSoft = yes

      # ??
      #@app.renderer.shadowMapType = THREE.PCFShadowMap

      # vector version
      @app.renderer.gammaInput = true
      @app.renderer.gammaOutput = true
      @app.renderer.shadowMapEnabled = true
      @app.renderer.shadowMapCullFace = THREE.CullFaceBack

      ###
      if @hemiLight?
        @app.scene.remove @hemiLight
      @hemiLight = new THREE.HemisphereLight 0xffffff, 0xffffff, 0.6 # @conf.hemiLightIntensity
      @hemiLight.position.set 0, @conf.hemiLightAltitude, 0
      #@app.scene.add @hemiLight

      if @spotLight?
        @app.scene.remove @spotLight
      @spotLight = new THREE.SpotLight( 0xffffff )

      @spotLight.position = @app.camera.position  #.set( 0, 400, 0 )

      @spotLight.castShadow = yes

      @spotLight.shadowMapWidth = 2048
      @spotLight.shadowMapHeight = 2048
      @spotLight.shadowDarkness = 0.2
      @spotLight.shadowCameraNear = 40
      @spotLight.shadowCameraFar = 8000
      @spotLight.shadowCameraFov = 30
      @spotLight.shadowCameraVisible = yes

      @app.scene.add @spotLight
      # end of initialization
      ###

      # LIGHTS
      @hemiLight = new THREE.HemisphereLight 0xffffff, 0xffffff, 0.6
      @hemiLight.color.setHSL( 0.6, 1, 0.6 )
      @hemiLight.groundColor.setHSL 0.095, 1, 0.75
      @hemiLight.position.set 0, 500, 0
      @app.scene.add @hemiLight

      @dirLight = new THREE.DirectionalLight 0xffffff, 1
      @dirLight.color.setHSL 0.1, 1, 0.95
      @dirLight.position.set -1, 1.75, 1
      @dirLight.position.multiplyScalar 50
      @app.scene.add @dirLight

      @dirLight.castShadow = true

      @dirLight.shadowMapWidth = 2048
      @dirLight.shadowMapHeight = 2048

      d = 50

      @dirLight.shadowCameraLeft = -d
      @dirLight.shadowCameraRight = d
      @dirLight.shadowCameraTop = d
      @dirLight.shadowCameraBottom = -d

      @dirLight.shadowCameraFar = 3500
      @dirLight.shadowBias = -0.0001
      @dirLight.shadowDarkness = 0.35
      #dirLight.shadowCameraVisible = true;


    #@hemiLight.color.setHSL @conf.hemiLightSkyColorH, @conf.hemiLightSkyColorS, @conf.hemiLightSkyColorL
    #@hemiLight.groundColor.setHSL @conf.hemiLightGroundColorH, @conf.hemiLightGroundColorS, @conf.hemiLightGroundColorL

    # moving sun light
    #@spotLight.shadowBias =  @conf.spotLightShadowBias
    #@spotLight.shadowDarkness = @conf.spotLightShadowDarkness
    #@spotLight.color.setHSL @conf.spotLightColorH, @conf.spotLightColorS, @conf.spotLightColorsL
    #@spotLight.distance = @conf.spotLightDistance
    #@spotLight.intensity = @conf.spotLightIntensity

    #@spotLight.position.set 1, 570.0285641649532, -9934.80094134473

    # fog
    if @app.scene.fog?
      @app.scene.fog.density = @conf.fogDensity
      @app.scene.fog.color.setHSL @conf.fogColorH, @conf.fogColorS, @conf.fogColorL
      # prettier if renderer clear color is same as fog
      @app.renderer.setClearColor @app.scene.fog.color.getHex(), 1


    if @sky?
      @sky.uniforms.turbidity.value = @conf.turbidity
      @sky.uniforms.reileigh.value = @conf.reileigh
      @sky.uniforms.luminance.value = @conf.luminance
      @sky.uniforms.mieCoefficient.value = @conf.mieCoefficient
      @sky.uniforms.mieDirectionalG.value = @conf.mieDirectionalG

      theta = Math.PI * (@conf.inclination - 0.5)
      phi = 2 * Math.PI * (@conf.azimuth - 0.5)

      @mesh.position.x = @conf.distance * Math.cos(phi)
      @mesh.position.y = @conf.distance * Math.sin(phi) * Math.sin(theta)
      @mesh.position.z = @conf.distance * Math.sin(phi) * Math.cos(theta)

      #@mesh.visible = yes # skyConfig.sun

      @sky.uniforms.sunPosition.value.copy @mesh.position


  # called on each frame
  render: ->
    #@mesh.position.z = Math.sin(@app.time * 0.2) * 10000
    #@mesh.position.y = Math.cos(@app.time * 0.2) * 5000
    #@mesh.position.x = 1#Math.cos(@app.time * 3)
    #@spotLight.position.set @mesh.position.x, @mesh.position.y, @mesh.position.z
    #if @mesh.position.y < 0
    #  @spotLight.intensity = (1 + Math.cos(@app.time * 0.1)) * 0.4
