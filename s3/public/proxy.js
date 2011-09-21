var Proxy;
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
Proxy = {
  ImageLoader: (function() {
    function _Class(end_point, expected_domain) {
      this.loaded = __bind(this.loaded, this);
      this.send_message = __bind(this.send_message, this);
      this.receive_message = __bind(this.receive_message, this);      this.end_point = end_point;
      this.expected_domain = expected_domain;
      window.addEventListener('message', this.receive_message, false);
      this.send_message({
        action: 'init'
      });
    }
    _Class.prototype.receive_message = function(event) {
      var data;
      if (event.origin !== this.expected_domain) {
        return;
      }
      data = JSON.parse(event.data);
      if (data.action === 'load') {
        return this.load_image(data.url);
      }
    };
    _Class.prototype.send_message = function(message) {
      return this.end_point.postMessage(JSON.stringify(message), this.expected_domain);
    };
    _Class.prototype.load_image = function(url) {
      var image;
      image = document.createElement('img');
      image.setAttribute('data-url', url);
      image.onload = image.onerror = image.onabort = this.loaded;
      image.src = url;
      return document.body.appendChild(image);
    };
    _Class.prototype.loaded = function(e) {
      var bits, canvas, image, url;
      image = e.target;
      canvas = document.createElement('canvas');
      canvas.width = image.width;
      canvas.height = image.height;
      canvas.getContext('2d').drawImage(image, 0, 0);
      bits = canvas.toDataURL();
      url = image.getAttribute('data-url');
      return this.send_message({
        action: 'loaded',
        url: url,
        bits: bits
      });
    };
    return _Class;
  })()
};