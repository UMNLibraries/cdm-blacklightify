// renders tooltips for elements with the data-toggle="tooltip" attribute and listens for the ESC key to close any open tooltips or popovers
function toggleTooltip() {
  $('[data-toggle="tooltip"]').tooltip({ placement: 'top' });

  // escape bootstrap tooltip and popover with ESC key
  $.fn.listenEscKeyToCloseOverlays = function () {
    return this.each(function () {
      if (("undefined" !== typeof $.fn.tooltip) || ("undefined" !== typeof $.fn.popover)) {
        document.addEventListener('keydown', function(e) {
          if ('Escape' === e.key) {
            const $openTooltips = $('.tooltip');
            const $openPopovers = $('.popover');

            if ($openPopovers.length || $openTooltips.length) {
              e.stopPropagation();
              $openTooltips.tooltip('hide');
              $openPopovers.popover('hide');
            }
          }
        }, true);
      }
    });
  };

  $(document).listenEscKeyToCloseOverlays();
}
