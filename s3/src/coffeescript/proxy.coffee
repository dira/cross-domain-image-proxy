Proxy =
  ImageLoader: class
    constructor: (end_point, expected_domain) ->
      @end_point = end_point
      @expected_domain = expected_domain

      window.addEventListener 'message', @receive_message, false
      @send_message action: 'init'


    receive_message: (event) =>
      return  if event.origin != @expected_domain

      data = JSON.parse(event.data)
      @load_image(data.path) if data.action == 'load'


    send_message: (message) =>
      @end_point.postMessage JSON.stringify(message), @expected_domain


    load_image: (path) ->
      image = document.createElement('img')
      image.setAttribute 'data-path', path
      image.onload =  image.onerror = image.onabort = @loaded
      image.src = path
      document.body.appendChild image


    loaded: (e) =>
      image = e.target
      canvas = document.createElement('canvas')
      canvas.width  = image.width
      canvas.height = image.height
      canvas.getContext('2d').drawImage image, 0, 0

      bits = canvas.toDataURL()
      path = image.getAttribute('data-path')
      @send_message
        action: 'loaded'
        path: path
        bits: bits
