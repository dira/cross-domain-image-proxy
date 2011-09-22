$(document).ready ->
  application = new Application.Main()

Application =
  Main: class
    constructor: ->
      @proxy = new Application.Proxy(@on_load)

      @canvas = $('canvas#main').dom[0]
      @proof_text  = $('#proof_text')
      @proof_image = $('#proof_image').dom[0]
      $("#images img").each (e) =>
        @proxy.send_message
          action: 'load',
          path: e.getAttribute('data-path')


    on_load: (path, bits) =>
      $("#images img").each (el, index) =>
        if el.getAttribute('data-path') == path
          el.onload = () =>
            @canvas.getContext('2d').drawImage(el, 100 * index, 0)

            contents = @canvas.toDataURL()
            @proof_text.text(contents)
            @proof_image.src = contents
          el.src = bits


  Proxy: class
    constructor: (on_load) ->
      @on_load = on_load
      window.addEventListener "message", @receive_message, false

      @proxy = null
      @load_proxy()


    load_proxy: ->
      @proxy_element = $('#proxy').dom[0]

      proxy_url = @proxy_element.getAttribute('data-proxy-url')
      @remote_domain = proxy_url.match(/http:\/\/[^/]+/)[0]

      # add a timestamp to avoid some browsers taking the file from cache
      # and not executing the JS
      stamp = (Math.random() + "").substr(-10)
      @proxy_element.src = "#{proxy_url}?stamp=#{stamp}"


    loaded: ->
      !!@proxy


    receive_message: (event) =>
      return unless event.origin == @remote_domain

      data = JSON.parse(event.data)
      switch data.action
        when 'init' then @proxy = event.source
        when 'loaded'
          @on_load(data.path, data.bits)


    send_message: (message) ->
      if @loaded()
        @proxy.postMessage(JSON.stringify(message), @remote_domain)
      else
        window.setTimeout ( => @send_message message), 200
