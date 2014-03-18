$('document').ready(function() {

  // show btn toolbar on hover
  $('.media-list li').hover(function () {
      $(this).find('.btn-group').toggle();
  });
});
