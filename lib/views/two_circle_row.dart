import 'package:flutter/material.dart';

class DualCircleRow extends StatelessWidget {
  final List<CircleData> circleDataList;

  const DualCircleRow({Key? key, required this.circleDataList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: circleDataList.map((circleData) {
        return CircleWidget2(
          color: circleData.color,
          icon: circleData.icon,
          text: circleData.text,
        );
      }).toList(),
    );
  }
}

class CircleWidget2 extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;

  const CircleWidget2({
    Key? key,
    required this.color,
    required this.icon,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 32,
                ),
                SizedBox(height: 4),
                Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CircleData {
  final Color color;
  final IconData icon;
  final String text;

  CircleData({
    required this.color,
    required this.icon,
    required this.text,
  });
}
