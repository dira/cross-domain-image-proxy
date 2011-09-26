var Application;
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
if (!Application) {
  Application = {};
}
Application.Main = (function() {
  function _Class() {
    var image, _i, _len, _ref;
    this.proxy = new Application.Proxy({
      url: 'http://s3.dev/proxy.html',
      application: this
    });
    this.images = document.getElementById('images').getElementsByTagName('img');
    this.canvas = document.getElementById('main');
    this.proof_text = document.getElementById('proof_text');
    this.proof_image = document.getElementById('proof_image');
    _ref = this.images;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      image = _ref[_i];
      this.load_image(image.getAttribute('data-path'));
    }
  }
  _Class.prototype.load_image = function(path) {
    return this.proxy.send({
      action: 'load',
      path: path
    });
  };
  _Class.prototype.from_proxy = function(message) {
    switch (message.action) {
      case 'loaded':
        return this.image_bits_loaded(message.path, message.bits);
    }
  };
  _Class.prototype.image_bits_loaded = function(path, bits) {
    var image, index, _len, _ref, _results;
    _ref = this.images;
    _results = [];
    for (index = 0, _len = _ref.length; index < _len; index++) {
      image = _ref[index];
      _results.push(image.getAttribute('data-path') === path ? (image.onload = (__bind(function(img, i) {
        return __bind(function() {
          return this.image_loaded(img, i);
        }, this);
      }, this))(image, index), image.src = bits) : void 0);
    }
    return _results;
  };
  _Class.prototype.image_loaded = function(image, index) {
    var contents;
    this.canvas.getContext('2d').drawImage(image, 100 * index, 0);
    contents = this.canvas.toDataURL();
    this.proof_text.innerHTML = contents;
    return this.proof_image.src = contents;
  };
  return _Class;
})();