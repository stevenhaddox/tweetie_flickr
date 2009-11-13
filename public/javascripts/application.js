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

  if($('div#photos div#thumbs').size()>0) {
  var gallery = $('div#photos div#thumbs').galleriffic({
    delay:                     3000, // in milliseconds
    numThumbs:                 10, // The number of thumbnails to show page
    preloadAhead:              20, // Set to -1 to preload all images
    enableTopPager:            false,
    enableBottomPager:         true,
    maxPagesToShow:            7,  // The maximum number of pages to display in either the top or bottom pager
    imageContainerSel:         '', // The CSS selector for the element within which the main slideshow image should be rendered
    controlsContainerSel:      '', // The CSS selector for the element within which the slideshow controls should be rendered
    captionContainerSel:       '', // The CSS selector for the element within which the captions should be rendered
    loadingContainerSel:       '', // The CSS selector for the element within which should be shown when an image is loading
    renderSSControls:          true, // Specifies whether the slideshow's Play and Pause links should be rendered
    renderNavControls:         true, // Specifies whether the slideshow's Next and Previous links should be rendered
    playLinkText:              'Play',
    pauseLinkText:             'Pause',
    prevLinkText:              'Previous',
    nextLinkText:              'Next',
    nextPageLinkText:          'Next &rsaquo;',
    prevPageLinkText:          '&lsaquo; Prev',
    enableHistory:             false, // Specifies whether the url's hash and the browser's history cache should update when the current slideshow image changes
    enableKeyboardNavigation:  true, // Specifies whether keyboard navigation is enabled
    autoStart:                 false, // Specifies whether the slideshow should be playing or paused when the page first loads
    syncTransitions:           false, // Specifies whether the out and in transitions occur simultaneously or distinctly
    defaultTransitionDuration: 1000, // If using the default transitions, specifies the duration of the transitions
    onSlideChange:             undefined, // accepts a delegate like such: function(prevIndex, nextIndex) { ... }
    onTransitionOut:           undefined, // accepts a delegate like such: function(slide, caption, isSync, callback) { ... }
    onTransitionIn:            undefined, // accepts a delegate like such: function(slide, caption, isSync) { ... }
    onPageTransitionOut:       undefined, // accepts a delegate like such: function(callback) { ... }
    onPageTransitionIn:        undefined, // accepts a delegate like such: function() { ... }
    onImageAdded:              undefined, // accepts a delegate like such: function(imageData, $li) { ... }
    onImageRemoved:            undefined  // accepts a delegate like such: function(imageData, $li) { ... }
  });
  } // end selector test for div#photos index 
  
});
