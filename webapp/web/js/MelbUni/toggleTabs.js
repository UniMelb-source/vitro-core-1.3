var ie = (document.all) ? true : false;

function toggleTabs()
{
	if(document.getElementById('displayDiv').style.display == 'block')
    {
        document.getElementById('displayDiv').style.display='none';
        document.getElementById('horizontalTabs').style.display='none';
        document.getElementById('verticalTabs').style.display='block';
		showClass("activeVerticalTab");
    }
    else
    {
        document.getElementById('displayDiv').style.display='block';
        document.getElementById('horizontalTabs').style.display='block';
        document.getElementById('verticalTabs').style.display='none';		
		hideClass("activeVerticalTab");
    }
}

function getElementByClass(objClass){
//  This function is similar to 'getElementByID' since there
//  is no inherent function to get an element by it's class
//  Works with IE and Mozilla based browsers
var elements = (ie) ? document.all : document.getElementsByTagName('*');
  for (i=0; i<elements.length; i++){
    //alert(elements[i].className)
    //alert(objClass)
    if (elements[i].className==objClass){
    return elements[i]
    }
  }
}

function hideClass(objClass){
//  This function will hide Elements by object Class
//  Works with IE and Mozilla based browsers

var elements = (ie) ? document.all : document.getElementsByTagName('*');
  for (i=0; i<elements.length; i++){
    if (elements[i].className==objClass){
      	//elements[i].style.visibility="hidden"
		//https://vitro.versi.edu.au:8443/vivo/themes/vivo-basic/site_icons/grouping/h3_tab_left-hidden.gif
		elements[i].style.backgroundImage = "url(https://vitro.versi.edu.au:8443/vivo/themes/vivo-basic/site_icons/grouping/h3_tab_left-hidden.gif)"
		elements[i].childNodes[0].style.backgroundImage = "url(https://vitro.versi.edu.au:8443/vivo/themes/vivo-basic/site_icons/grouping/h3_tab_left-hidden.gif)"
    }
  }
}

function showClass(objClass){
//  This function will show Elements by object Class
//  Works with IE and Mozilla based browsers
var elements = (ie) ? document.all : document.getElementsByTagName('*');
  for (i=0; i<elements.length; i++){
    if (elements[i].className==objClass){
      //elements[i].style.visibility="visible"
		elements[i].style.backgroundImage = "url(https://vitro.versi.edu.au:8443/vivo/themes/vivo-basic/site_icons/grouping/h3_tab_left.gif)"
		elements[i].childNodes[0].style.backgroundImage = "url(https://vitro.versi.edu.au:8443/vivo/themes/vivo-basic/site_icons/grouping/h3_tab_right.gif)"
    }
  }
}
