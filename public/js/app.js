$('document').ready(function() {

  // show btn toolbar on hover
  $('.media-list li').hover(function () {
      $(this).find('.btn-group').toggle();
  });

  //upload form stuff
  $('#upload-form').on('submit', function(e) {
    e.preventDefault();
    $('[type=submit]').prop('disabled',true).html('Uploading, Please Wait... <i class="fa fa-spin fa-spinner">');
    $('#uploadModal').modal('hide');
    $(this).off('submit').submit();
  });

  //hide flash message after 7 seconds
  setTimeout(function () {
    $('.alert-info').hide();
  }, 7000);

  //video thumbnail click handler
  $('.thumbnail').on('click', function () {
    $(this).toggleClass('selected').find('.icon').toggle();
  });

  $('#attachVidBtn').on('click', function () {
    var idArray = "";
        
    $(this).attr('disabled',true).html('Attaching... <i class="fa fa-spin fa-spinner">');

    $('.thumbnail').each(function (i, val) {
      idArray += $(this).attr('id') + ',';
    });

    $.get('/attach/' + idArray, function (data) {
      $('#vidListModal').modal('hide');
    });
  });

});
