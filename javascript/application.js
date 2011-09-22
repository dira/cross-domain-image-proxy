var Application;
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
$(document).ready(function() {
  var application;
  return application = new Application.Main();
});
Application = {
  Main: (function() {
    function _Class() {
      this.on_load = __bind(this.on_load, this);      this.proxy = new Application.Proxy(this.on_load);
      this.canvas = $('canvas#main').dom[0];
      this.proof_text = $('#proof_text');
      this.proof_image = $('#proof_image').dom[0];
      $("#images img").each(__bind(function(e) {
        return this.proxy.send_message({
          action: 'load',
          path: e.getAttribute('data-path')
        });
      }, this));
    }
    _Class.prototype.on_load = function(path, bits) {
      return $("#images img").each(__bind(function(el, index) {
        if (el.getAttribute('data-path') === path) {
          el.onload = __bind(function() {
            var contents;
            this.canvas.getContext('2d').drawImage(el, 100 * index, 0);
            contents = this.canvas.toDataURL();
            this.proof_text.text(contents);
            return this.proof_image.src = contents;
          }, this);
          return el.src = bits;
        }
      }, this));
    };
    return _Class;
  })(),
  Proxy: (function() {
    function _Class(on_load) {
      this.receive_message = __bind(this.receive_message, this);      this.on_load = on_load;
      window.addEventListener("message", this.receive_message, false);
      this.proxy = null;
      this.load_proxy();
    }
    _Class.prototype.load_proxy = function() {
      var proxy_url, stamp;
      this.proxy_element = $('#proxy').dom[0];
      proxy_url = this.proxy_element.getAttribute('data-proxy-url');
      this.remote_domain = proxy_url.match(/http:\/\/[^/]+/)[0];
      stamp = (Math.random() + "").substr(-10);
      return this.proxy_element.src = "" + proxy_url + "?stamp=" + stamp;
    };
    _Class.prototype.loaded = function() {
      return !!this.proxy;
    };
    _Class.prototype.receive_message = function(event) {
      var data;
      if (event.origin !== this.remote_domain) {
        return;
      }
      data = JSON.parse(event.data);
      switch (data.action) {
        case 'init':
          return this.proxy = event.source;
        case 'loaded':
          return this.on_load(data.path, data.bits);
      }
    };
    _Class.prototype.send_message = function(message) {
      if (this.loaded()) {
        return this.proxy.postMessage(JSON.stringify(message), this.remote_domain);
      } else {
        return window.setTimeout((__bind(function() {
          return this.send_message(message);
        }, this)), 200);
      }
    };
    return _Class;
  })()
};