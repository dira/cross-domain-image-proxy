Application = {} unless Application
Application.Main = class
  constructor: ->
    @proxy = new Application.Proxy
      # url: 'http://dira.dev/code/remote-storage/proxy.html',
      url:         'http://s3-clone.heroku.com/proxy.html' # TODO your application's domain
      application: this

    @images =      document.getElementById('images').getElementsByTagName('img')
    @canvas =      document.getElementById 'main'
    @proof_text  = document.getElementById 'proof_text'
    @proof_image = document.getElementById 'proof_image'

    for image in @images
      @load_image image.getAttribute('data-path')


  load_image: (path) ->
    @proxy.send
      action: 'load'
      path: path


  from_proxy: (message) ->
    switch message.action
      when 'loaded' then @image_bits_loaded message.path, message.bits


  image_bits_loaded: (path, bits) ->
    for image, index in @images
      if image.getAttribute('data-path') == path
        image.onload = ((img, i) =>
          => @image_loaded(img, i))(image, index)
        image.src = bits


  image_loaded: (image, index) ->
    @canvas.getContext('2d').drawImage image, 100 * index, 0

    contents = @canvas.toDataURL()
    @proof_text.innerHTML = contents
    @proof_image.src = contents
