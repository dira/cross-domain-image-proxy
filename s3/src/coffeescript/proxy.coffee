Proxy =
  Proxy: class
    constructor: (args) ->
      @end_point       = args.end_point
      @expected_domain = args.from
      @worker          = new args.worker_class(this)

      window.addEventListener 'message', @message_received, false
      @send action: 'init'


    message_received: (event) =>
      return if event.origin != @expected_domain

      @worker.execute JSON.parse(event.data)


    send: (message) =>
      @end_point.postMessage JSON.stringify(message), @expected_domain


  ImageLoader: class
    constructor: (proxy) ->
      @proxy = proxy


    execute: (message) ->
      switch message.action
        when 'load' then @load_image message.path


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
      @proxy.send
        action: 'loaded'
        path: path
        bits: bits
