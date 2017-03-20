var prepareTableControlls = function(table_id) {
  var columnCount = getColumnCount(table_id)
  window.info_global = $('.dataTables_info').detach()
  window.pagination_global = $('.dataTables_paginate').detach()
  window.record_select_global = $('.dataTables_length').detach()
  window.search_global = $('.dataTables_filter').detach()
    
  pagination_global.on('click', function() {
    updateTable(table_id, columnCount)
  })
  record_select_global.on('change', function() {
    updateTable(table_id, columnCount)
  })
  search_global.find('input').on('keyup', function() {
    updateTable(table_id, columnCount)
  })
  $(table_id + ' thead').on('click', 'tr:first-child', function() {
    updateTable(table_id, columnCount)
  })
}
  
// Change View of Search Field
var updateSearchField = function(table_id) {
  var search_label = search_global.find('label')
  var search_input = search_global.find('input')
  search_label.replaceWith(search_input)
  $(table_id + '_wrapper').before(search_global)
  search_global.find('input').attr('placeholder', 'Search Documents...')
}
  
var updateTable = function(table_id) {
  var colspan = getColumnCount(table_id) / 3
  if ($(table_id + ' tr:last').attr('id') === undefined) {
    $(table_id + ' tr:last').after('<tr id="control-row" class="control-row">' + '<td colspan=' + colspan + ' align="left" id="pagination_cell" style="text-align: center;"></td>' +
                                             '<td colspan=' + colspan + ' align="center" id="record_select_cell"></td>' + 
                                             '<td colspan=' + colspan + ' align="right" id="info_cell"></td>' + '</tr>')
  }
  
  // Place controlls to table bottom row
  $('#info_cell').append(info_global)
  $('#pagination_cell').append(pagination_global)
  $('#record_select_cell').append(record_select_global)
  
  // Change Text of Table Records Information
  var table_info_text = info_global.text()
  table_info_text = table_info_text.replace('Showing', 'Viewing')
  table_info_text = table_info_text.replace(' to ', '-')
  table_info_text = table_info_text.replace(' entries', '')
  info_global.text(table_info_text)
  
  // Replace button classes for paginating
  $('a.paginate_button').addClass('paginate_button_custom')
  $('a.paginate_button').removeClass('paginate_button')
    
  // Change View of Number of records selection
  var show_entries_label = record_select_global.find('label')
  var show_entries_select = record_select_global.find('select')
  show_entries_label.replaceWith(show_entries_select)
}

var getColumnCount = function(table_id){
  return $(table_id + ' thead').find('tr:first-child th').length
}