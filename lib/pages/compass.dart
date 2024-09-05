import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class CompassScreen extends StatefulWidget {
    @override
    _CompassScreenState createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen> {
    double _heading = 0;
    double _pitch = 0;
    double _targetHeading = 0;
    double _roll = 0;
    final double _smoothingFactor = 1; // Adjust this value for smoother rotation

    @override
    void initState() {
        super.initState();
        _startListening();
    }

    @override
    Widget build(BuildContext context) {
        return Stack(children: [
            Center(
                child: Transform.rotate(
                    angle: 0, // Convert degrees to radians
                    child:
                        const Icon(Icons.north, size: 200.0, color: Colors.blueAccent,), // Add a compass image in the assets folder
                    )
            ),
            Center(
                child: Transform.translate(
                    offset: const Offset(0, 100), child: Transform.rotate(
                      angle: -(_heading * (pi / 180)), // Convert degrees to radians
                      child: Transform.translate(
                        offset: const Offset(100, 0),
                        child: const Icon(Icons.circle, size: 10.0 ,color: Colors.redAccent,), // Add a compass image in the assets folder
                      )
                    )
                )
            )
        ]
        );
    }

    void _startListening() {
         // Listen to the accelerometer updates
    accelerometerEventStream().listen((AccelerometerEvent accelEvent) {
      // Calculate pitch and roll
      _pitch = atan2(accelEvent.y, sqrt(accelEvent.x * accelEvent.x + accelEvent.z * accelEvent.z)) * (180 / pi);
      _roll = atan2(-accelEvent.x, sqrt(accelEvent.y * accelEvent.y + accelEvent.z * accelEvent.z)) * (180 / pi);
    });

    // Listen to the magnetometer updates
    magnetometerEventStream().listen((MagnetometerEvent magEvent) {
      // Calculate the heading based on the magnetometer data
      double heading = atan2(magEvent.y, magEvent.x) * (180 / pi);
      heading = heading < 0 ? heading + 360 : heading;

      // Adjust heading based on pitch and roll
      double correctedHeading = heading + _roll * 0.1; // Adjust this factor as needed

      //correctedHeading += -91; // Add declination
      correctedHeading = correctedHeading < 0 ? correctedHeading + 360 : correctedHeading;
      _targetHeading = correctedHeading;
      setState(() {
          _heading += (_targetHeading - _heading) * _smoothingFactor; // Interpolate towards the target heading
      });
    });
    }
}
