<%@ Page Title="PastPowerOutages" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="PastPowerOutages.aspx.cs" Inherits="PowerInterruptions.PastPowerOutages" %>

<asp:Content ID="Content1" ContentPlaceHolderID="CPHead" runat="server">

    <!-- Styles to make your graphs work go here -->
     <style>
        .table-hover tbody tr:hover td, .table-hover tbody tr:hover th
         {
            background-color: goldenrod;
         }
         .jumbotron {
			padding-top: 20px;
			padding-bottom: 10px;
			color: white;
			background-color: #4570a5;
		}
		.jumbotron>h1 {
			font-size: 75pt;
			font-family: "Times New Roman", Times, serif;
			margin: 0;
		}
		.jumbotron>p {
			margin: 0;
		}
        .chart-container {
	        position: relative;
	        display: inline-block;
	        height: 100%;
	        padding-top: 15px;
	        padding-bottom: 25px;
            width: 600px !important;
        }
        .chart {
	        float: left;
	        z-index:1;
	        display: inline-block;
	        position: relative;
	        padding-bottom: 10px;
	        padding-top: 10px;
	        border-left: thin solid #cccccc;
	        border-bottom: thin solid #cccccc;
        }
        .chart-row {
	        height: 25px;
        }
    .bar {
	    position: relative;
	    background-color: #6b9bd6;
	    height: 19px;
	    margin-top: 3px;
	    margin-bottom: 3px;
	    border-radius: 0 2px 2px 0;
    }
    .bar:hover {
	    border-top: 2px solid black;
	    border-bottom: 2px solid black;
	    border-right: 2px solid black;
    }
    .legend-left {
	    clear: both;
	    display: inline-block;
	    position: relative;
	    margin-top: 17px;
	    float: left;
    }
    .heading {
	    font-size: 8pt;
	    font-weight: bold;
	    color: #aaaaaa;
	    height: 19px;
    }
    .heading-left {
	    text-align: right;
	    line-height: 5px;
	    position: relative;
	    max-width: 200px;
	    margin-top: 3px;
	    margin-bottom: 3px;
	    margin-right: 7px;
    }
    .data-point {
	    height: 25px;
	    width: 25px;
	    position: relative;
	    float: left;
	    margin-left: -13px;
    }
    .legend-bottom {
	    position: absolute;
	    bottom: -10px;
    }
    .chart-label {
	    font-size: 7pt;
	    font-weight: bold;
	    color: #aaaaaa;
	    position: absolute;
	    bottom: -10px;
	    z-index:0;
	    float: left;
    }
    .chart-label-hr {
	    position: absolute;
	    bottom: 0;
	    z-index:-1;
	    background-color: #cccccc;
	    width: 1px;
	    height: 4px;
    }
    .chart-title {
	    text-align: center;
	    font-size: 10pt;
	    font-weight: bold;
    }
    .fade{
        opacity: 1;
    }

    .tooltip {
        opacity: 1;
    }

    #tableData{
        float: left;
        width: 450px;
        margin: 10px;
    }
    #graphData{
        float: right;
    }

    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="CPBody" runat="server">


<!-- Your HTML and JavaScript goes here -->
    <script>
        (function ($) {

            // Borrow and modify some code from http://www.jqueryscript.net/chart-graph/Simple-Bar-Chart-Plugin-with-jQuery-Bootstrap-jchart.html
            $.fn.jChart = function (options) {
                var selector = $(this);
                var default_color = "#6b9bd6";
                var bar_height = 19;

                var settings = $.extend({
                    width: 750,
                    name: null,
                    type: "bar",
                    headers: null,
                    values: null,
                    footers: Array(),
                    sort: false,
                    sort_colors: false,
                    colors: Array(),
                }, options);

                //Initialize some settings that can be set via HTML
                if (settings.name == null) {
                    settings.name = $(this).attr("name");
                }
                if ($(this).data("sort") == true) {
                    settings.sort = true;
                }
                if ($(this).data("width") != null) {
                    settings.width = parseInt($(this).data("width"));
                }
             

                var chart_width = settings.width;
                if ($(this).hasClass("chart-sm")) {
                    bar_height = 17;
                }
                else if ($(this).hasClass("chart-lg")) {
                    bar_height = 25;
                }
                else if (settings.width != null) {
                    chart_width = parseInt(settings.width);
                }

                checkForHTMLSettings();

                //Clear the data in the jChart div
                $(this).html("");

                //Create the html containers for the chart
                var chart_title =
                    $("<div>", {
                        class: "chart-title",
                        html: settings.name
                    });
                var legend_left =
                    $("<div>", {
                        class: "legend legend-left"
                    });
              

                //Calculate what the chart width should be
                var max_data = Math.max.apply(Math, settings.values);
                var max_footer = Math.max.apply(Math, settings.footers);
                var maxes = [max_data, max_footer];
                var chart_max = Math.max.apply(Math, maxes);
                var container_width = chart_width + 250;

                var chart_container =
                    $("<div>", {
                        class: "chart-container",
                        width: container_width + "px"
                    });
                var chart =
                    $("<div>", {
                        class: "chart",
                        width: chart_width + "px"
                    });
                var legend_bottom =
                    $("<div>", {
                        class: "legend-bottom"
                    });

                //Place the containers into the target element
                $(this).append(chart_container);
                chart_container.append(chart_title);
                chart_container.append(legend_left);
                chart_container.append(chart);

                //Sort the data if the setting is enabled (Insertion sort)
                if (settings.sort) {
                    for (var i = 1; i < settings.values.length; i++) {
                        var j = i;
                        while (j > 0 && settings.values[j - 1] <= settings.values[j]) {
                            var temp = settings.values[j];
                            var head_temp = settings.headers[j];
                            settings.values[j] = settings.values[j - 1];
                            settings.values[j - 1] = temp;

                            //Sort headings
                            settings.headers[j] = settings.headers[j - 1];
                            settings.headers[j - 1] = head_temp;

                            //Sort colors
                            if (settings.sort_colors) {
                                if (settings.values[j] == settings.values[j - 1])
                                    settings.colors[j - 1] = settings.colors[j];
                                else {
                                    var color_temp = settings.colors[j];
                                    settings.colors[j] = settings.colors[j - 1];
                                    settings.colors[j - 1] = color_temp;
                                }
                            }
                            j--;
                        }
                    }
                }

                //Loop through headings and create/place them and their corresponding value bars
                for (var i = 0; i < settings.headers.length; i++) {
                    var heading =
                        $("<div>", {
                            class: "heading heading-left",
                            style: "height: " + bar_height + "px;font-size: 10pt;",
                            html: settings.headers[i]
                        });
                    var bar_width = (settings.values[i] / chart_max) * chart_width;
                    var bar =
                        $("<div>", {
                            class: "bar " + settings.headers[i],
                            "data-placement": "right",
                            "data-toggle": "tooltip",
                            title: commaSeparateNumber(settings.values[i]),
                            style: "height:" + bar_height + "px;background-color:" + settings.colors[i % settings.colors.length],
                            width: bar_width
                        });
                    legend_left.append(heading);
                    chart.append(bar);
                }
                chart.append(legend_bottom);
                for (var i = 0; i < settings.footers.length; i++) {
                    var margin = "margin-left:" + ((settings.footers[i] / chart_max) * chart_width - 9).toString() + "px;";
                    var chart_label_bottom =
                        $("<div>", {
                            class: "chart-label chart-label-bottom",
                            style: margin,
                            html: commaSeparateNumber(settings.footers[i])
                        });
                    var margin = "margin-left:" + ((settings.footers[i] / chart_max) * chart_width - 2).toString() + "px;";
                    var chart_label_hr =
                        $("<div>", {
                            class: "chart-label-hr",
                            style: margin

                        });
                    legend_bottom.append(chart_label_bottom);
                    chart.append(chart_label_hr);
                }

                //Enable hover details
                $(".bar").tooltip('show');

                return this;

                /**
                 * Checks for settings defined in the HTML
                 * like chart-define-row and chart-define-footer classes
                 */
                function checkForHTMLSettings() {
                    //Check for HTML defined bar chart data
                    if (selector.find(".define-chart-row").length > 0) {
                        settings.headers = Array();
                        settings.values = Array();
                        selector.find(".define-chart-row").each(function () {
                            settings.headers.push($(this).attr("title"));
                            var value = $(this).html();
                            if (value == null || value == "") {
                                settings.values.push(0);
                            }
                            else {
                                settings.values.push(parseInt(value));
                            }
                            var color = $(this).data("color");
                            if (color != null) {
                                settings.sort_colors = true;
                                settings.colors.push(color);
                            }
                            else {
                                settings.colors.push(default_color);
                            }
                        });
                    }
                    else {
                        settings.colors.push(default_color);
                    }
                    //Check for HTML defined footers
                    if (selector.find(".define-chart-footer").length > 0) {
                        settings.footers = Array();
                        selector.find(".define-chart-footer").each(function () {
                            var footer = $(this).html();
                            if (footer != null && footer != "") {
                                settings.footers.push(parseInt(footer));
                            }
                        });
                    }
                }

                /**
                 * Converts a number into a comma separated string
                 */
                function commaSeparateNumber(val) {
                    while (/(\d+)(\d{3})/.test(val.toString())) {
                        val = val.toString().replace(/(\d+)(\d{3})/, '$1' + ',' + '$2');
                    }
                    return val;
                }
            };
        })(jQuery);




        $.getJSON("/api/AnnualPowerInterruptions", function (data) {

        })
              .success(function (data) {
                  $('#myTable').append('<thead><tr><td>Year</td><td>Events</td><td>Customers</td><td>Duration</td></tr></thead>');
                  var headers = [];
                  var values = [];
                  $('#myTable').append('<tbody>');
                  $.each(data, function (key, value) {
                      $('#myTable').append('<tr class="row_' + value.year + '"><td><a href="#" onclick="doSomethingElse(' + value.year + ');">' + value.year + '</a></td><td>' + value.totalEvents + '</td><td>' + value.customers + '</td><td>' + value.avgDuration + '</td></tr>');
                      headers.push(value.year);
                      values.push(value.customers);
                  });
                  $('#myTable').append('</tbody>');

                  $("#graphData").jChart({
                      name: "Annual Interruptions Graph ",
                      headers: headers,
                      values: values,
                      colors: ["#191970", "#000080", "#00008B", "#0000CD", "#0000FF", "#4169E1", "#1E90FF", "#00BFFF", "#6495ED", "#87CEEB", "#87CEFA", "#B0E0E6", "#ADD8E6", "#B0C4DE", "#4682B4", "#5F9EA0"]
                  });
                  $('#refesh_page').hide();
              })
              .error(function () { $('#myTable').append('Failed to load Power Interruption Data'); })

        function MouseOverHandler(row) {
            console.log(row);
            $(".2014").tooltip();
        }



        function MouseOutHandler(row) {
            console.log(row);
        }

        $("tbody").on("click", "tr", function (e) {
            $(this)
               .toggleClass("selected")
               .siblings(".selected")
                   .removeClass("selected");
        });

        jQuery(document).ready(function ($) {
            $('refresh_page').hide();
        });

        function refeshPage() {
            $.getJSON("/api/AnnualPowerInterruptions", function (data) {

            })
              .success(function (data) {
                  var headers = [];
                  var values = [];

                  $.each(data, function (key, value) {
                      headers.push(value.year);
                      values.push(value.customers);
                  });


                  $("#graphData").jChart({
                      name: "Annual Interruptions Graph ",
                      headers: headers,
                      values: values,
                      colors: ["#191970", "#000080", "#00008B", "#0000CD", "#0000FF", "#4169E1", "#1E90FF", "#00BFFF", "#6495ED", "#87CEEB", "#87CEFA", "#B0E0E6", "#ADD8E6", "#B0C4DE", "#4682B4", "#5F9EA0"]
                  });
                  $('#refesh_page').hide();
              })
              .error(function () { $('#graphData').append('Failed to load Power Interruption Data'); })
        }

        function doSomethingElse(e) {
            console.log(e);
            $.getJSON("/api/MonthlyPowerInterruptions/" + e, function (data) {

            })
            .success(function (data) {
                var headers = [];
                var values = [];
                $.each(data, function (key, value) {
                    headers.push(value.month);
                    values.push(value.customers);
                    console.log("Month: " + value.month + " Customers: " + value.customers);
                });


                $("#graphData").jChart({
                    name: "Monthly Interruptions Graph ",
                    headers: headers,
                    values: values,
                    colors: ["#191970", "#000080", "#00008B", "#0000CD", "#0000FF", "#4169E1", "#1E90FF", "#00BFFF", "#6495ED", "#87CEEB", "#87CEFA", "#B0E0E6", "#ADD8E6", "#B0C4DE", "#4682B4", "#5F9EA0"]
                });

                $('#refesh_page').show();
            })
            .error(function () { $('#graphData').append('Failed to load Power Interruption Data'); })
        }
      
    </script>
    <div class="row">
      <div class="col-md-0">
         <div id="tableData">
            <table class="table table-bordered table-hover" id="myTable">
            </table>
         </div>
        </div>
        <div class="col-md-offset-1">
            <div id="graphData" data-sort="false" data-width="550" class="jChart chart-lg">
             </div>
        </div>
        <div class="col-md-5 col-md-offset-1">
            <button type="button" onclick="refeshPage()" id="refesh_page" class="btn btn-primary">Reload Annual</button>
        </div>
     </div>
</asp:Content>
