var victim = null;

$(document).ready(function() {
  // hide the selectbox if javascript is enabled!
  $('#voting').css('display', 'none');

  $('#players li.player').hover(
    function() { if (!$(this).hasClass('dead')) { $(this).addClass('hover'); }},
    function() { if (!$(this).hasClass('dead')) { $(this).removeClass('hover'); }}
  );
  $('#players li.player').click(
    function() {
      if (!$(this).hasClass('dead')) {
        $(this).toggleClass('selected');
        victim = $(this).attr('id').split('_')[1];

        $('#victims').val(victim);
        $('#voting form').submit();
      }
    }
  );
});
