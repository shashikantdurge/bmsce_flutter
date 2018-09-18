import 'package:bmsce/academics/student.dart';

/// Timeseries chart with example of updating external state based on selection.
///
/// A SelectionModelConfig can be provided for each of the different
/// [SelectionModel] (currently info and action).
///
/// [SelectionModelType.info] is the default selection chart exploration type
/// initiated by some tap event. This is a different model from
/// [SelectionModelType.action] which is typically used to select some value as
/// an input to some other UI component. This allows dual state of exploring
/// and selecting data via different touch events.
///
/// See [SelectNearest] behavior on setting the different ways of triggering
/// [SelectionModel] updates from hover & click events.
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class GpaBarChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final List<charts.TickSpec<String>> semesterLabel;
  final semestersCount;
  final bool animate;

  GpaBarChart(
      {this.seriesList, this.animate, this.semesterLabel, this.semestersCount});

  factory GpaBarChart.fromStudentDetail(StudentDetail student) {
    List<SemesterGpa> sgpaArr = [];
    List<SemesterGpa> cgpaArr = [];
    List<charts.TickSpec<String>> semesterLabel = [];
    student.semestersGps.forEach((gpa) {
      sgpaArr.add(SemesterGpa(gpa.semKey, gpa.sgpa));
      cgpaArr.add(SemesterGpa(gpa.semKey, gpa.cgpa));
      semesterLabel.add(new charts.TickSpec(
        gpa.semKey,
        label: gpa.sem,
      ));
    });
    List<charts.Series<SemesterGpa, String>> gpaCharts = [
      new charts.Series<SemesterGpa, String>(
        id: 'SGPA',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault.darker,
        domainFn: (SemesterGpa gpa, _) => gpa.semester,
        measureFn: (SemesterGpa gpa, _) => gpa.gpa,
        data: sgpaArr,
      ),
      new charts.Series<SemesterGpa, String>(
        id: 'CGPA',
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault.lighter,
        domainFn: (SemesterGpa gpa, _) => gpa.semester,
        measureFn: (SemesterGpa gpa, _) => gpa.gpa,
        data: cgpaArr,
      )
    ];

    return new GpaBarChart(
      seriesList: gpaCharts,
      semesterLabel: semesterLabel,
      semestersCount: student.semestersGps.length,
      animate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        height: 250.0,
        width: semestersCount < 2 ? 80.0 * 2 : 80.0 * semestersCount,
        child: new charts.BarChart(
          seriesList,
          primaryMeasureAxis: charts.NumericAxisSpec(
              tickProviderSpec: new charts.BasicNumericTickProviderSpec(
                  // Make sure we don't have values less than 1 as ticks
                  // (ie: counts).
                  dataIsInWholeNumbers: true,
                  // Fixed tick count to highlight the integer only behavior
                  // generating ticks [0, 1, 2, 3, 4].
                  desiredTickCount: 11)),
          animate: animate,
          barGroupingType: charts.BarGroupingType.grouped,
          domainAxis: new charts.OrdinalAxisSpec(
              tickProviderSpec:
                  new charts.StaticOrdinalTickProviderSpec(semesterLabel)),
          // Add the legend behavior to the chart to turn on legends.
          // This example shows how to optionally show measure and provide a custom
          // formatter.

          behaviors: [
            new charts.SeriesLegend(
              // Positions for "start" and "end" will be left and right respectively
              // for widgets with a build context that has directionality ltr.
              // For rtl, "start" and "end" will be right and left respectively.
              // Since this example has directionality of ltr, the legend is
              // positioned on the right side of the chart.
              position: charts.BehaviorPosition.bottom,
              // By default, if the position of the chart is on the left or right of
              // the chart, [horizontalFirst] is set to false. This means that the
              // legend entries will grow as new rows first instead of a new column.
              horizontalFirst: false,
              // This defines the padding around each legend entry.
              cellPadding: new EdgeInsets.only(right: 4.0, bottom: 4.0),
              // Set show measures to true to display measures in series legend,
              // when the datum is selected.
              showMeasures: true,

              // Optionally provide a measure formatter to format the measure value.
              // If none is specified the value is formatted as a decimal.
              measureFormatter: (num value) {
                return value == null ? '-' : '${value.toStringAsFixed(2)}';
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Sample ordinal data type.
class SemesterGpa {
  final String semester;
  final double gpa;

  SemesterGpa(this.semester, this.gpa);
}
