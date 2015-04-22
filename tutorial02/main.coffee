gl = undefined
shaders =
  fragReady: false
  vertReady: false
  frag: undefined
  vert: undefined
shaderProgram = undefined

mvMatrix = mat4.create()
pMatrix = mat4.create()

triangleVertexPositionBuffer = undefined
triangleVertexColorBuffer = undefined
squareVertexPositionBuffer = undefined
squareVertexColorBuffer = undefined

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

initShaders = ->
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

setMatrixUniforms = ->
  gl.uniformMatrix4fv shaderProgram.pMatrixUniform, false, pMatrix
  gl.uniformMatrix4fv shaderProgram.mvMatrixUniform, false, mvMatrix

initBuffers = ->
# triangle vertex positions
  triangleVertexPositionBuffer = gl.createBuffer()
  gl.bindBuffer gl.ARRAY_BUFFER, triangleVertexPositionBuffer
  vertices = [0, 1, 0
              -1, -1, 0
              1, -1, 0]
  gl.bufferData gl.ARRAY_BUFFER, new Float32Array(vertices), gl.STATIC_DRAW
  triangleVertexPositionBuffer.itemSize = 3
  triangleVertexPositionBuffer.numItems = 3

  # triangle vertex colors
  triangleVertexColorBuffer = gl.createBuffer()
  gl.bindBuffer gl.ARRAY_BUFFER, triangleVertexColorBuffer
  colors = [1, 0, 0, 1  # red
            0, 1, 0, 1  # green
            0, 0, 1, 1  # blue]
            gl.bufferData gl.ARRAY_BUFFER, new Float32Array(colors), gl.STATIC_DRAW
            triangleVertexColorBuffer.itemSize = 4
            triangleVertexColorBuffer.numItems = 3

# TODO: do square stuff here!

    drawScene = ->
# get scene ready
      gl.viewport 0, 0, gl.viewportWidth, gl.viewportHeight
      gl.clear (gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
      mat4.perspective 45, gl.viewportWidth / gl.viewportHeight, 0.1, 100.0, pMatrix
      mat4.identity mvMatrix

      # setup positions
      mat4.translate mvMatrix, [-1.5, 0.0, -7.0]
      gl.bindBuffer gl.ARRAY_BUFFER, triangleVertexPositionBuffer
      gl.vertexAttribPointer(shaderProgram.vertexPositionAttribute, triangleVertexPositionBuffer.itemSize, gl.FLOAT,
          false, 0, 0)

      # setup colors
      gl.bindBuffer gl.ARRAY_BUFFER, triangleVertexColorBuffer
      gl.vertexAttribPointer(shaderProgram.vertexColorAttribute, triangleVertexColorBuffer.itemSize, gl.FLOAT, false, 0,
          0)

      # draw triangles
      setMatrixUniforms()
      gl.drawArrays gl.TRIANGLES, 0, triangleVertexPositionBuffer.numItems

# TODO: draw squares!

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
    initBuffers()
    gl.clearColor 0, 0, 0, 1 # default background color: black
    gl.enable gl.DEPTH_TEST
    drawScene()

  waitForShaders(finishGLInit)

