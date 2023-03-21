import 'package:attendance_system/student%20panel/functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

import '../student_home_screen.dart';

class AppliedPhysicsView extends StatefulWidget {
  const AppliedPhysicsView({super.key});

  @override
  State<AppliedPhysicsView> createState() => _AppliedPhysicsViewState();
}

class _AppliedPhysicsViewState extends State<AppliedPhysicsView> {
  CollectionReference? apRef;
  Map<String, int> values = {'P': 0, 'A': 0, 'L': 0};
  final dataMap = <String, double>{'Present': 0};
  double totalValue = 0.0;
  final colorList = <Color>[Colors.green];
  bool isLoaded = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    apRef = firestore.collection('attendance').doc(uid).collection('ap');
    getTotal();
  }

  void getTotal() async {
    var totalSnapshot = await apRef!.doc('total').get();
    if (totalSnapshot.exists) {
      int p = totalSnapshot.get('P');
      int a = totalSnapshot.get('A');
      int l = totalSnapshot.get('L');
      totalValue = p.toDouble() + a.toDouble() + l.toDouble();
      values.update('P', (value) => p);
      values.update('A', (value) => a);
      values.update('L', (value) => l);
      dataMap.update('Present', (value) => p.toDouble());
    }
    setState(() {
      isLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: isLoaded == false
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const ListTile(
                  contentPadding: EdgeInsets.all(20),
                  trailing:
                      Icon(Icons.arrow_circle_right, color: Colors.lightBlue),
                  leading: CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage('assets/images/ap.jpg')),
                  title: FittedBox(
                    child: Text(
                      'Applied Physics',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(children: [
                      const Text('Present',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Text(values['P'].toString(),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)))
                    ]),
                    Column(children: [
                      const Text('Absent',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      CircleAvatar(
                          backgroundColor: Colors.red,
                          child: Text(values['A'].toString(),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)))
                    ]),
                    Column(children: [
                      const Text('Leaves',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      CircleAvatar(
                          backgroundColor: Colors.amber,
                          child: Text(values['L'].toString(),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)))
                    ]),
                  ],
                ),
                const Divider(thickness: 3),
                Container(
                  width: screenWidth / 1.5,
                  padding: const EdgeInsets.all(20.0),
                  child: PieChart(
                    dataMap: dataMap,
                    chartType: ChartType.ring,
                    baseChartColor: Colors.grey,
                    colorList: colorList,
                    chartValuesOptions: const ChartValuesOptions(
                      showChartValuesInPercentage: true,
                    ),
                    totalValue: totalValue,
                  ),
                ),
                const Divider(thickness: 3),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: apRef!.snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data!.docs.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return ListView.builder(
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              //do not display the total here
                              if (snapshot.data!.docs[index].id == 'total') {
                                return const SizedBox.shrink();
                              } else if (!(snapshot.data!.docs[index]
                                  ['isMarked'])) {
                                return const SizedBox.shrink();
                              }
                              //to check if present or absent
                              var value = snapshot.data!.docs[index]['value'];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 10.0),
                                elevation: 10,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0)),
                                color: value == 'P'
                                    ? Colors.lightGreen
                                    : Colors.redAccent,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(children: [
                                    FittedBox(
                                      child: Text(
                                        '${snapshot.data!.docs[index].id}: ',
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 20),
                                      ),
                                    ),
                                    FittedBox(
                                      child: Text(
                                        snapshot.data!.docs[index]['value'],
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 20),
                                      ),
                                    )
                                  ]),
                                ),
                              );
                            });
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
