$('document').ready(function() {

  // show btn toolbar on hover
  $('.media-list li').hover(function () {
      $(this).find('.btn-group').toggle();
  });

  //upload form stuff
  // $('#upload-form').submit(function(e) {
  //   // e.preventDefault();
  //   $(this).find('.btn').attr('disabled', true);
  //   if ($('#file').val()) {
  //     console.log('submit');
  //   }
  // });
});
