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

});
