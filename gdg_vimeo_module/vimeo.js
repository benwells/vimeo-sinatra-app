rbf_selectQuery('SELECT vimeo_consumer_key, vimeo_consumer_secret, vimeo_access_token, vimeo_access_token_secret, vimeo_user_id FROM $SETTINGS', 1, function (vals) {
  var iframeWidth = '900px',
      iframeHeight = '900px',
      ck = vals[0][0],
      cs = vals[0][1],
      at = vals[0][2],
      as = vals[0][3],
      uid = vals[0][4],
      applicationId = getURLParameter('id'),
      visitorId = current_visitor.id,
      iframe = $("<iframe></iframe>"),
      container = $("<div class='flex-video widescreen'></div>"),
      url = "https://sinatra-blahaas.rhcloud.com/" +
            ck + "/" +
            cs + "/" +
            at + "/" +
            as + "/" +
            uid + "/" +
            visitorId + "/" +
            applicationId;


  container.appendTo('[name="Video Content Target"]');
  iframe.prop('src', url).appendTo('.flex-video');
});
