document.addEventListener("DOMContentLoaded",function(){
  var closeBtn=document.getElementById("arrow-back");
  if(closeBtn){
    closeBtn.href="https://michaelakridge-noaa.github.io/optics-si-cloud-tools/";
    closeBtn.addEventListener("click",function(e){
      e.preventDefault();
      window.location.href="https://michaelakridge-noaa.github.io/optics-si-cloud-tools/";
    });
  }
});
