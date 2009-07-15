var invitations = new Array();

$(document).ready(function() {
  // hide the textbox if javascript is enabled!
  $('#invitations').css('display', 'none');

  $('#followers li.follower').hover(
    function() { $(this).addClass('hover'); },
    function() { $(this).removeClass('hover'); }
  );
  $('#followers li.follower').click(
    function() {
      $(this).toggleClass('selected');

      var name = $(this).find('.name').text();
      var loc  = $.inArray(name, invitations);
      if (loc == -1) { invitations.push(name); }
      else { invitations.splice(loc, 1); }
    }
  );
  $('#followers form').submit(
    function() {
      $('#invitations textarea').val(invitations.toString());
      return true;
    }
  );
});
