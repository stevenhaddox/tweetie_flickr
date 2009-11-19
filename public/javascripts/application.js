// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(document).ready(function() {
  // $.untinyurl('http://flic.kr/p/79HeuN');

	$('textarea#photo_caption').maxlength({ 
	  events:             [], // Array of events to be triggerd 
	  maxCharacters:      125, // Characters limit 
	  status:             true, // True to show status indicator bewlow the element 
	  statusClass:        "counter notice", // The class on the status div 
	  statusText:         "", // The status text 
	  notificationClass:  "error",    // Will be added when maxlength is reached 
	  showAlert:          false, // True to show a regular alert message 
	  alertText:          "Too many characters.", // Text in alert message 
	  slider:             false // True Use counter slider 
	}); 


	// Initially set opacity on thumbs and add
	// additional styling for hover effect on thumbs
	if($('div#photos div#thumbs').size()>0) {
		var onMouseOutOpacity = 0.67;
		$('div#photos div#thumbs ul.thumbs li').opacityrollover({
			mouseOutOpacity: onMouseOutOpacity,
			mouseOverOpacity: 1.0,
			fadeSpeed: 'fast',
			exemptionSelector: '.selected'
		});

		// Initialize Advanced Galleriffic Gallery
		var gallery = $('div#photos div#thumbs').galleriffic({
			delay: 2500,
			numThumbs: 10,
			// preloadAhead: 10,
			enableTopPager: false,
			enableBottomPager: false,
			// maxPagesToShow: 7,
			imageContainerSel: '#slideshow',
			controlsContainerSel: '#controls',
			captionContainerSel: '#caption',
			loadingContainerSel: '#loading',
			renderSSControls: false,
			renderNavControls: false,
			playLinkText: 'Play Slideshow',
			pauseLinkText: 'Pause Slideshow',
			prevLinkText: '&lsaquo; Previous Photo',
			nextLinkText: 'Next Photo &rsaquo;',
			nextPageLinkText: 'Next &rsaquo;',
			prevPageLinkText: '&lsaquo; Prev',
			enableHistory: false,
			autoStart: false,
			syncTransitions: false,
			defaultTransitionDuration: 900,
			onSlideChange: function(prevIndex, nextIndex) {
			// 'this' refers to the gallery, which is an extension of $('#thumbs')
			this.find('ul.thumbs').children()
			.eq(prevIndex).fadeTo('fast', onMouseOutOpacity).end()
			.eq(nextIndex).fadeTo('fast', 1.0);
			},
			onPageTransitionOut: function(callback) {
			this.fadeTo('fast', 0.0, callback);
			},
			onPageTransitionIn: function() {
			this.fadeTo('fast', 1.0);
			}
		});
	}
  
});
