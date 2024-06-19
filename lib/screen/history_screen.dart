import 'package:flutter/material.dart';
import 'package:xoxo/data/database_helper.dart';

class HistoryScreen extends StatelessWidget {
  final dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Game History'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _clearHistory(context),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: dbHelper.getGamesInReverseOrder(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No game history yet.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final game = snapshot.data![index];
                final gameNumber = snapshot.data!.length - index;
                final moves = game['moves'] as String;
                final movesList = moves.split(',');

                // ปรับขนาดตารางเล็กลง
                int gridSize = (movesList.length <= 9) ? 3 : 4;

                return Card(
                  elevation: 3,
                  margin: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Game $gameNumber',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: gridSize,
                          mainAxisSpacing: 4.0,
                          crossAxisSpacing: 4.0,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: movesList.length,
                        itemBuilder: (context, moveIndex) {
                          return Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                            ),
                            padding: EdgeInsets.all(8.0),
                            child: Center(
                              child: Text(
                                movesList[moveIndex],
                                style: TextStyle(fontSize: 16.0),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<void> _clearHistory(BuildContext context) async {
    await dbHelper.clearGames();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('ลบประวัติการเล่นเรียบร้อยแล้ว')),
    );
  }
}
