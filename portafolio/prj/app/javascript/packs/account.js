// jquery syntax causes problems with these rules
/* eslint-disable no-undef */
/* eslint-disable no-invalid-this */

$(document).on('turbolinks:load', function() {
  $('#transaction-filter').on('change paste keyup', function(event) {
    const filter = $(this).val().toLowerCase();
    const table = $('#transactions-table');
    const rows = table.find('tr');

    rows.each(function(index, tr) {
      const rowCategory = $(this).find('td').eq(3).text().toLowerCase();

      if (rowCategory.includes(filter)) {
        $(this).css('display', '');
      } else {
        $(this).css('display', 'none');
      }
    });
  });
});
