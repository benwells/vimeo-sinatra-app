$('document').ready(function() {

  // show btn toolbar on hover
  // $('.media-list li, .slickel').hover(function () {
  //   $(this).find('#btnContainer').toggle();
  // });

  //upload form stuff
  $('#upload-form').on('submit', function(e) {
    e.preventDefault();
    $('[type=submit]').prop('disabled',true).html('Uploading, Please Wait... <i class="fa fa-spin fa-spinner">');
    // $('#uploadModal').modal('hide');
    $(this).off('submit').submit();
  });

  //hide flash message after 5 seconds
  setTimeout(function () {
    $('.alert-info').hide();
  }, 5000);


  //loop through thumbnails and make an initial assessment of selectedness
  $('.thumbnail').each(function (i, val) {
    if ($(val).hasClass('selected')) {
      $(val).find('.icon').show();
    }
    else {
      $(val).find('.icon').hide();
    }
  });

  //video thumbnail click handler
  $('.thumbnail').on('click', function () {
    var idStr = "",
        detachStr = "",
        _this = $(this);

    _this.toggleClass('selected');
    if (_this.hasClass('selected')) {
      _this.find('.icon').show();
    }
    else {
      _this.find('.icon').hide();
    }

    $('.thumbnail').each(function (i, val) {
      if ($(this).hasClass('selected')) {
        idStr += $(this).attr('id') + ',';
      }
      else {
        detachStr += $(this).attr('id') + ',';
      }
    });

    if (detachStr == "") {
      detachStr = 0;
    }

    if (idStr == "") {
      idStr = 0;
    }

    $('#attachVidBtn').attr('href', '/attach/' + idStr + '/' + detachStr);
  });

  // $('#attachVidBtn').on('click', function () {
  //   var idArray = "";
  //
  //   $(this).attr('disabled',true).html('Attaching... <i class="fa fa-spin fa-spinner">');
  //
  //   $('.thumbnail').each(function (i, val) {
  //     idArray += $(this).attr('id') + ',';
  //   });
  //
  //   // $.get('/attach/' + idArray, function (data) {
  //   //   $('#vidListModal').modal('hide');
  //   //   $('#attachVidBtn').attr('disabled',false).html('Attach');
  //   // });
  // });

  $('#slickcontainer').slick({
    dots: true,
    infinite: false,
    speed: 300,
    slidesToShow: 3,
    // touchMove: true,
    slidesToScroll: 1
  });

});


function modalDelete(id, title) {
  $('#' + id).off('click');
  var vidId = id,
      vidTitle = title,
      confirmation = confirm("Are you sure you want to delete this video?");

  if (confirmation) {
    $('#' + id).find('.fa-check-circle-o').removeClass('fa-check-circle-o').addClass('fa-spinner fa-spin')
    $.get('/delete/' + vidId + '/' + vidTitle, function(data) {
      $('#' + id).remove();
      alert("This video has been successfully deleted");
    }).fail(function(){
      alert("Oops! Something went wrong, please try again");
      $('#' + id).find('.fa-spinner').removeClass('fa-spinner fa-spin').addClass('fa-check-circle-o')
    });
  }
  else {
    $('#' + id).on('click', vidClickHandler).click();
    return;
  }
}

function vidClickHandler() {
  var idStr = "",
      detachStr = "",
      _this = $(this);

    _this.toggleClass('selected');
    if (_this.hasClass('selected')) {
      _this.find('.icon').show();
    }
    else {
      _this.find('.icon').hide();
    }

    $('.thumbnail').each(function (i, val) {
      if ($(this).hasClass('selected')) {
        idStr += $(this).attr('id') + ',';
      }
      else {
        detachStr += $(this).attr('id') + ',';
      }
    });

    if (detachStr == "") {
      detachStr = 0;
    }

    if (idStr == "") {
      idStr = 0;
    }

    $('#attachVidBtn').attr('href', '/attach/' + idStr + '/' + detachStr);
}

function cancelHandler () {
  setTimeout(function () {
    location.reload();
  }, 20);
}
