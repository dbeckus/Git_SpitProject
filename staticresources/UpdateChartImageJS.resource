function updatechartimage(iframe) {

	var chartImage;
	
	if(iframe.contentDocument) {
		chartImage = iframe.contentDocument.chartimage;
	} else if(iframe.contentWindow){
		chartImage = iframe.contentWindow.document.chartimage;
	
		//this is IE and we need to move the form elements off the screen as they bleed through the image
		var oSelects = iframe.contentWindow.document.getElementsByTagName("select");
		
		for(var i=0;i<oSelects.length;i++) {
		oSelects[i].className =" hidden";
		}
	}
	
	chartImage.style.position= "Absolute";
	chartImage.style.top= "-94px";
	chartImage.style.left= "0px";
	chartImage.setAttribute('onclick', 'window.open("'+iframe.src+'")');
	iframe.height="100%";
	iframe.width="100%";
	
	var iframeParent = iframe.parentNode;
	iframeParent.style.height = chartImage.height + 'px';
	iframeParent.style.width = chartImage.width + 'px';
}
