var invitations = new Array();
var page = 1;
var endOfList = false;

$(document).ready(function() {
  // hide the textbox if javascript is enabled!
  $('#invitations').css('display', 'none');
  $('#followers #submit').attr('disabled', 'disabled');

  $('#scrollwindow').infinitescroll({
    navSelector  : "#followers .navigation",            
    nextSelector : "#followers .navigation a:first",
    itemSelector : "#followers ul",
    //debug        : true,                        
    loadingImg   : "/images/loading.gif",
    loadingText  : "Loading more followers...",      
    localMode    : true,
    //animate      : true,
    //extraScrollPx: 50,
    donetext     : "Your follower list has finished loading." 
  });

  $('#followers li.follower').live('mouseover',
    function() { $(this).addClass('hover'); }
  );
  $('#followers li.follower').live('mouseout',
    function() { $(this).removeClass('hover'); }
  );
  $('#followers li.follower').live('click',
    function() {
      $(this).toggleClass('selected');

      var name = $(this).find('.name').text();
      var loc  = $.inArray(name, invitations);
      if (loc == -1) { invitations.push(name); }
      else { invitations.splice(loc, 1); }

      if (invitations.length > 0) { $('#followers input[type=submit]').attr('disabled', false); }
      else { $('#followers input[type=submit]').attr('disabled', 'disabled'); }
    }
  );
  $('#followers form').submit(
    function() {
      $('#invitations textarea').val(invitations.toString());
      return true;
    }
  );
});
