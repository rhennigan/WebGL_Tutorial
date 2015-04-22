gl = undefined
shaders =
  fragReady: false
  vertReady: false
  frag: undefined
  vert: undefined
shaderProgram = undefined

mvMatrix = mat4.create()
pMatrix = mat4.create()

initGL = (canvas) ->
  try
    gl = canvas.getContext "experimental-webgl"
    gl.viewportWidth = canvas.width
    gl.viewportHeight = canvas.height
  catch e
    alert "initGL error: #{e}"
  if not gl then alert "Could not initialize WebGL"

loadShader = (path, type) ->
  request = new XMLHttpRequest()
  request.open 'GET', path, true
  request.onreadystatechange = ->
    if request.readyState is 4 and request.status is 200
      sourceString = request.responseText
      if type is 'frag'
        shaders.frag = gl.createShader gl.FRAGMENT_SHADER
        gl.shaderSource shaders.frag, sourceString
        gl.compileShader shaders.frag
        shaders.fragReady = true
      else if type is 'vert'
        shaders.vert = gl.createShader gl.VERTEX_SHADER
        gl.shaderSource shaders.vert, sourceString
        gl.compileShader shaders.vert
        shaders.vertReady = true
      else
        alert "unknown shader type: #{type}"
  request.send()

initShaders = () ->
  if not shaders.fragReady
    alert "fragment shader script is not loaded"
  else if not shaders.vertReady
    alert "vertex shader script is not loaded"
  else
    shaderProgram = gl.createProgram()
    gl.attachShader shaderProgram, shaders.vert
    gl.attachShader shaderProgram, shaders.frag
    gl.linkProgram shaderProgram
    if not gl.getProgramParameter shaderProgram, gl.LINK_STATUS
      console.log shaders
      alert "failed to initialize shaders"
    else
      gl.useProgram shaderProgram
      shaderProgram.vertexPositionAttribute = gl.getAttribLocation shaderProgram, "aVertexPosition"
      shaderProgram.vertexColorAttribute = gl.getAttribLocation shaderProgram, "aVertexColor"
      gl.enableVertexAttribArray shaderProgram.vertexPositionAttribute
      gl.enableVertexAttribArray shaderProgram.vertexColorAttribute
      shaderProgram.pMatrixUniform = gl.getUniformLocation shaderProgram, "uPMatrix"
      shaderProgram.mvMatrixUniform = gl.getUniformLocation shaderProgram, "uMVMatrix"

window.testing = ->
  canvas = document.getElementById 'canvas'
  initGL canvas
  loadShader 'fragment.glsl', 'frag'
  loadShader 'vertex.glsl', 'vert'

  waitForShaders = (continuation) ->
    console.log "fragment shader: #{shaders.fragReady}"
    console.log "vertex shader: #{shaders.vertReady}"
    if not (shaders.fragReady and shaders.vertReady)
      setTimeout (-> waitForShaders continuation), 10
    else
      continuation()

  finishGLInit = ->
    initShaders()
    alert "ready"

  waitForShaders finishGLInit