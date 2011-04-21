beef.execute(function() {

    var repeat_value = "<%= @repeat_string %>";
    var iterations = <%= @repeat %>;
    var str = "";

    for (var i = 0; i < iterations; i++) {
        str += repeat_value;
    }

    console.log(str);
    beef.net.send("<%= @command_url %>", <%= @command_id %>, str);

});

