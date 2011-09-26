Application = {} unless Application

Application.Proxy = class
  constructor: (options) ->
    window.addEventListener 'message', @on_message, false

    @application = options.application

    @load options.url


  load: (url) ->
    @remote_domain = url.match(/http:\/\/[^/]+/)[0]

    loader = document.createElement 'iframe'
    loader.setAttribute 'style', 'display:none'
    loader.src = "#{url}?stamp=#{@timestamp()}" # force the browser to download the file and execute the JS
    document.body.appendChild loader


  is_loaded: ->
    !!@end_point


  on_message: (event) =>
    return unless event.origin == @remote_domain

    message = JSON.parse event.data
    switch message.action
      when 'init'
        @end_point = event.source
      else
        @application.from_proxy message


  send: (message) ->
    if @is_loaded()
      @end_point.postMessage JSON.stringify(message), @remote_domain
    else
      window.setTimeout ( => @send message), 200


  timestamp: ->
    (Math.random() + "").substr(-10)
