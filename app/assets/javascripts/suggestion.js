//$('#q').autoComplete({
//  source: function(term, response) {
//      minLength: 2,
//      source: ''
//      focus: function(event, ui) {
//          //len = ui.item.name.length();
//          //alert("OK");
//          $('input#<%= input_field_name %>').val(ui.item.name);
//          return false;
//      },
//  }//});

$(function () {
    $("#q").autoComplete({
        minChars: 2,
        source: function (term, response) {
            $.getJSON("/homepage/search_by_address?term=" + term, function (data) {
                console.log(data);
                response(data);
            });
        }
        //focus: function (event, ui) {
        //    $('#q').val(ui.item.name);
        //    return false;
        //}
    });
});
