$(document).on('click', '.delete-feature', function (e) {
  var href    = $(e.currentTarget).data('path'),
      feature = $(e.currentTarget).closest('td').next().text(),
      $modal  = $('#delete-feature'),
      $name   = $modal.find('.feature-name'),
      $link   = $modal.find('a');

  $link.attr('href', href);
  $name.text(feature.trim());
  $modal.modal('show');
});
