var invitations = new Array();
var page = 1;

$(document).ready(function() {
  // hide the textbox if javascript is enabled!
  $('#invitations').css('display', 'none');
  $('#followers #submit').attr('disabled', 'disabled');
  //$('#followers .pages input[type=submit]').attr('disabled', false);

  // load follower list
  $('#followers .next').click(function() {
    page += 1;
    $.getJSON('/users/me/followers.json?page=' + page, function(data) {
      $('#followers ul').html('');
      $.each(data, function(i, item) {
        li = $('<li/>').addClass('follower').appendTo('#followers ul');
        if ($.inArray(item.screen_name, invitations) != -1) { li.addClass('selected'); }

        image = $('<img/>');
        image.attr('src', item.profile_image_url).attr('alt', item.screen_name);
        image.attr('width', 48).attr('height', 48)
        image.appendTo(li);

        $('<div/>').addClass('name').html(item.screen_name).appendTo(li);
      });
    });
    return false;
  });
  $('#followers .prev').click(function() {
    if (page > 1) {
      page -= 1;
      $.getJSON('/users/me/followers.json?page=' + page, function(data) {
        // TOOD: extract this out into a function
        // is this really the cleanest user workflow? what about an iframe with a google reader-ish auto-populate as you scroll?
        $('#followers ul').html('');
        $.each(data, function(i, item) {
          li = $('<li/>').addClass('follower').appendTo('#followers ul');
          if ($.inArray(item.screen_name, invitations) != -1) { li.addClass('selected'); }

          image = $('<img/>');
          image.attr('src', item.profile_image_url).attr('alt', item.screen_name);
          image.attr('width', 48).attr('height', 48)
          image.appendTo(li);

          $('<div/>').addClass('name').html(item.screen_name).appendTo(li);
        });
      });
      //if (page == 1) { $('#followers .prev').attr('disabled', true); }
    }
    return false;
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
