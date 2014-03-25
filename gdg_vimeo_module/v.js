function init_vimeo_iframe (mode, height) {
  rbf_selectQuery('SELECT v_c_k, v_c_s, v_a_t, v_a_t_s, v_u_i FROM $SETTINGS', 1, function (vals) {
    var iframeWidth = '900px',
        ck = vals[0][0],
        cs = vals[0][1],
        at = vals[0][2],
        as = vals[0][3],
        uid = vals[0][4],
        applicationId = getURLParameter('id'),
        visitorId = current_visitor.id,
        iframe = $("<iframe height='" + height + "'></iframe>"),
        container = $("<div class='flex-video widescreen'></div>"),
        url = ["https://sinatra-blahaas.rhcloud.com",
              ck,
              cs,
              at,
              as,
              uid,
              visitorId,
              applicationId,
              mode];

    url = url.join('/');
    container.appendTo('[name="Video Content Target"]');
    iframe.prop('src', url).appendTo('.flex-video');
  });
}

$('document').ready(function () {
  var g = getURLParameter('g');
  if (g == portal_pages.video_edit_page) {
    init_vimeo_iframe('e', '2000px');
  }
  else if (g == portal_pages.video_review_page) {
    init_vimeo_iframe('v', '500px');
  }
  else if (g == portal_pages.video_view_page) {
    init_vimeo_iframe('v', '500px');
  }
});
