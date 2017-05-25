var DatatableUpdate = function(tableId, tableSettings, desirableColspan, extraOptions) {
  $(tableId).DataTable(tableSettingsGenerate(tableSettings[0], tableSettings[1], tableSettings[2], extraOptions));
  // Save all controls to variables and add listeners
  var controlsArray = prepareTableControls(tableId, desirableColspan)

  // Change table to match design
  updateSearchField(tableId, controlsArray, tableSettings[1])
  updateTable(tableId, desirableColspan, controlsArray)
}

var tableSettingsGenerate = function(lengthMenuValues, recordName, aaSortingValues, extraOptions) {
  return $.extend({
    paging: true,
    lengthMenu: lengthMenuValues,
    searching: true,
    info: true,
    pagingType: 'numbers',
    language: {
      'emptyTable': 'No ' + recordName + ' available.',
      'zeroRecords': 'No ' + recordName + ' found.'
    },
    aaSorting: aaSortingValues,
    'aoColumnDefs': [{
      'bSortable': false,
      'aTargets': ['nosort']
    }, {
      'bSearchable': false,
      'aTargets': ['nosearch']
    }]
  }, extraOptions);
}

var prepareTableControls = function(table_id, desirableColspan) {
  var info_global = $(table_id + '_info' + '.dataTables_info')//.detach()
  var pagination_global = $(table_id + '_paginate' +'.dataTables_paginate')//.detach()
  var record_select_global = $(table_id + '_length' +'.dataTables_length')//.detach()
  var search_global = $(table_id + '_filter' +'.dataTables_filter')//.detach()
  var controlsArray = [info_global, pagination_global, record_select_global, search_global]
    
  controlsArray[1].on('click', function() {
    updateTable(table_id, desirableColspan, controlsArray)
  })
  controlsArray[2].on('change', function() {
    updateTable(table_id, desirableColspan, controlsArray)
  })
  controlsArray[3].find('input').on('keyup', function() {
    updateTable(table_id, desirableColspan, controlsArray)
  })
  $(table_id + ' thead').on('click', 'tr:first-child', function() {
    updateTable(table_id, desirableColspan, controlsArray)
  })
  return controlsArray;
}
  
// Change View of Search Field
var updateSearchField = function(table_id, controlsArray, recordName) {
  var search_label = controlsArray[3].find('label')
  var search_input = controlsArray[3].find('input')
  search_label.replaceWith(search_input)
  $(table_id + '_wrapper').before(controlsArray[3])
  controlsArray[3].find('input').attr('placeholder', 'Search ' + capitalize(recordName) + '...')
}
  
var updateTable = function(table_id, desirableColspan, controlsArray) {
  if(tableEmpty(table_id)) return;

  var colspan = []
  if (desirableColspan == null) {
    colspan[0] = getColumnCount(table_id) / 3
    colspan[1] = getColumnCount(table_id) / 3
    colspan[2] = getColumnCount(table_id) / 3
  } else {
    colspan = desirableColspan
  }

  if ($(table_id + ' tr:last').attr('id') == null) {
    $(table_id + ' tr:last').after('<tr id="control-row" class="control-row">' + '<td colspan=' + colspan[0] + ' align="left" id="pagination_cell" style="text-align: center;"></td>' +
                                             '<td colspan=' + colspan[1] + ' align="center" id="record_select_cell"></td>' + 
                                             '<td colspan=' + colspan[2] + ' align="right" id="info_cell"></td>' + '</tr>')
  }

  // Place controls to table bottom row
  $(table_id + ' #info_cell').append(controlsArray[0])
  $(table_id + ' #pagination_cell').append(controlsArray[1])
  $(table_id + ' #record_select_cell').append(controlsArray[2])
  
  // Change Text of Table Records Information
  var table_info_text = controlsArray[0].text()
  table_info_text = table_info_text.replace('Showing', 'Viewing')
  table_info_text = table_info_text.replace(' to ', '-')
  table_info_text = table_info_text.replace(' entries', '')
  controlsArray[0].text(table_info_text)
  
  // Replace button classes for paginating
  $('a.paginate_button').addClass('paginate_button_custom')
  $('a.paginate_button').removeClass('paginate_button')
    
  // Change View of Number of records selection
  var show_entries_label = controlsArray[2].find('label')
  var show_entries_select = controlsArray[2].find('select')
  show_entries_label.replaceWith(show_entries_select)
}

var getColumnCount = function(table_id) {
  return $(table_id + ' thead').find('tr:first-child th').length
}

var tableEmpty = function (table_id) {
  var table = $(table_id).DataTable()
  var recordsDisplayed = table.page.info().recordsDisplay
  if(!table.data().any() || recordsDisplayed === 0) {
    return true
  } else {
    return false
  }
}

// Helper Functions
var capitalize = function(str) {
  return str.charAt(0).toUpperCase() + str.slice(1)
}
