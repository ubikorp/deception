$(document).ready(function() {
  // display fancy javascript notices / errors for flash
  $('.flash').each(function(i) {
    if ($(this).hasClass('error')) {
      pre = 'ERROR: ';
    } else {
      pre = 'NOTICE: ';
    }

    msg = "<strong>" + pre + "</strong><span class='indent'>" + $(this).html() + "</span>";
    humanMsg.displayMsg(msg);

    $(this).css('display', 'none');
  });
});
