global = window
gl = undefined
vertShaderLoaded = false
fragShaderLoaded = false
shaders = {vertShader: undefined, fragShader: undefined}
shaderProgram = undefined
mvMatrix = mat4.create()
pMatrix = mat4.create()
triangleVertexPositionBuffer = undefined
squareVertexPositionBuffer = undefined

initGL = (canvas) ->
  try
    gl = canvas.getContext('experimental-webgl')
    gl.viewportWidth = canvas.width
    gl.viewportHeight = canvas.height
  catch e
  if !gl
    alert 'Could not initialise WebGL, sorry :-('
  gl

loadShaders = ->
  vertShaderScript = undefined
  fragShaderScript = undefined

  vReq = new XMLHttpRequest()
  vReq.open('GET', 'vertex.glsl', true)
  vReq.onreadystatechange = () ->
    if (vReq.readyState is 4) and (vReq.status is 200)
      vertShaderScript = vReq.responseText
      console.log("vertex.glsl loaded:\n#{vertShaderScript}")
      shaders.vertShader = gl.createShader(gl.VERTEX_SHADER)
      gl.shaderSource(shaders.vertShader, vertShaderScript)
      gl.compileShader(shaders.vertShader)
      vertShaderLoaded = true
  vReq.send(null)

  fReq = new XMLHttpRequest()
  fReq.open('GET', 'fragment.glsl', true)
  fReq.onreadystatechange = () ->
    if (fReq.readyState is 4) and (fReq.status is 200)
      fragShaderScript = fReq.responseText
      console.log("fragment.glsl loaded:\n#{fragShaderScript}")
      shaders.fragShader = gl.createShader(gl.FRAGMENT_SHADER)
      gl.shaderSource(shaders.fragShader, fragShaderScript)
      gl.compileShader(shaders.fragShader)
      fragShaderLoaded = true
  fReq.send(null)

initShaders = ->
  fragmentShader = shaders.fragShader
  vertexShader = shaders.vertShader
  shaderProgram = gl.createProgram()
  gl.attachShader shaderProgram, vertexShader
  gl.attachShader shaderProgram, fragmentShader
  gl.linkProgram shaderProgram
  if !gl.getProgramParameter(shaderProgram, gl.LINK_STATUS)
    alert 'Could not initialise shaders'
  gl.useProgram shaderProgram
  shaderProgram.vertexPositionAttribute = gl.getAttribLocation(shaderProgram, 'aVertexPosition')
  gl.enableVertexAttribArray shaderProgram.vertexPositionAttribute
  shaderProgram.pMatrixUniform = gl.getUniformLocation(shaderProgram, 'uPMatrix')
  shaderProgram.mvMatrixUniform = gl.getUniformLocation(shaderProgram, 'uMVMatrix')


setMatrixUniforms = ->
  gl.uniformMatrix4fv shaderProgram.pMatrixUniform, false, pMatrix
  gl.uniformMatrix4fv shaderProgram.mvMatrixUniform, false, mvMatrix


initBuffers = ->
  triangleVertexPositionBuffer = gl.createBuffer()
  gl.bindBuffer gl.ARRAY_BUFFER, triangleVertexPositionBuffer
  vertices = [0.0, 1.0, 0.0
              -1.0, -1.0, 0.0
              1.0, -1.0, 0.0
  ]
  gl.bufferData gl.ARRAY_BUFFER, new Float32Array(vertices), gl.STATIC_DRAW
  triangleVertexPositionBuffer.itemSize = 3
  triangleVertexPositionBuffer.numItems = 3
  squareVertexPositionBuffer = gl.createBuffer()
  gl.bindBuffer gl.ARRAY_BUFFER, squareVertexPositionBuffer
  vertices = [1.0
              1.0
              0.0
              -1.0
              1.0
              0.0
              1.0
              -1.0
              0.0
              -1.0
              -1.0
              0.0]
  gl.bufferData gl.ARRAY_BUFFER, new Float32Array(vertices), gl.STATIC_DRAW
  squareVertexPositionBuffer.itemSize = 3
  squareVertexPositionBuffer.numItems = 4


drawScene = ->
  gl.viewport 0, 0, gl.viewportWidth, gl.viewportHeight
  gl.clear gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT
  mat4.perspective 45, gl.viewportWidth / gl.viewportHeight, 0.1, 100.0, pMatrix
  mat4.identity mvMatrix
  mat4.translate mvMatrix, [-1.5
                            0.0
                            -7.0]
  gl.bindBuffer gl.ARRAY_BUFFER, triangleVertexPositionBuffer
  gl.vertexAttribPointer shaderProgram.vertexPositionAttribute, triangleVertexPositionBuffer.itemSize, gl.FLOAT, false, 0, 0
  setMatrixUniforms()
  gl.drawArrays gl.TRIANGLES, 0, triangleVertexPositionBuffer.numItems
  mat4.translate mvMatrix, [3.0
                            0.0
                            0.0]
  gl.bindBuffer gl.ARRAY_BUFFER, squareVertexPositionBuffer
  gl.vertexAttribPointer shaderProgram.vertexPositionAttribute, squareVertexPositionBuffer.itemSize, gl.FLOAT, false, 0, 0
  setMatrixUniforms()
  gl.drawArrays gl.TRIANGLE_STRIP, 0, squareVertexPositionBuffer.numItems

waitForShaders = ->
  console.log(shaders)
  if not (vertShaderLoaded and fragShaderLoaded)
    setTimeout((() -> waitForShaders()), 20)
  else
    initShaders()
    initBuffers()
    gl.clearColor(0.0, 0.0, 0.0, 1.0)
    gl.enable(gl.DEPTH_TEST)
    drawScene()

global.webGLStart = ->
  canvas = document.getElementById('lesson01-canvas')
  initGL canvas
  loadShaders()
  waitForShaders()