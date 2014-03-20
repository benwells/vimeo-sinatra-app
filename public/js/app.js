$('document').ready(function() {

  // show btn toolbar on hover
  $('.media-list li').hover(function () {
      $(this).find('.btn-group').toggle();
  });

  //upload form stuff
  $('#upload-form').on('submit', function(e) {
    e.preventDefault();
    $('[type=submit]').prop('disabled',true).html('Uploading, Please Wait... <i class="fa fa-spin fa-spinner">');
    $(this).off('submit').submit();
  });

  //hide flash message after 7 seconds
  setTimeout(function () {
    $('.alert-info').hide();
  }, 7000);

});
