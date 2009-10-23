(function($) {
  $.fn.untinyurl = function(options) {
    var options = $.extend({}, $.fn.untinyurl.defaults, options);
	$.fn.untinyurl.defaults = {url: this, format: 'json'}
    console.log(options.format);
	var untiny = 'http://untiny.me/api/1.0/extract?';
	var long_url;
    untiny += 'url=' + url;
    untiny += '&format=' + format;
    console.log(untiny);
    $.get(untiny, function(response){
      console.log(response);
      var res = JSON.parse(response);
      console.log(res[0]);
	  var long_url = res[0];
    });
	return long_url;
  }
})(jQuery);
