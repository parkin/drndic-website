$('.data-other-src').bind('mouseenter mouseleave', function() {
	    $(this).attr({
		            src: $(this).attr('data-other-src') 
		            , 'data-other-src': $(this).attr('src') 
		        })
});
