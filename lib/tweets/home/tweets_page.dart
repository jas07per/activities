import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../widgets/item_button.dart';
import '../posts/tweet_details_page.dart';
import '../posts/tweet_post_page.dart';

class TweetsPage extends StatefulWidget {
  const TweetsPage({Key? key}) : super(key: key);

  @override
  State<TweetsPage> createState() => _TweetsPageState();
}

class _TweetsPageState extends State<TweetsPage> {
  final tweetsCollection = FirebaseFirestore.instance.collection('tweets');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tweets'),
      ),
      body: Center(
        child: Stack(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: tweetsCollection.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      // Add this to read the document data
                      final data = snapshot.data!.docs[index].data()
                          as Map<String, dynamic>;
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) {
                              return TweetDetailsPage(
                                id: snapshot.data!.docs[index].id,
                                title: data['title'],
                                description: data['description'],
                                date: data['date'],
                                onItemDeleted: () async {
                                  // Delete
                                  await tweetsCollection
                                      .doc(snapshot.data!.docs[index].id)
                                      .delete();
                                },
                              );
                            }),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (data['title'] is String)
                                Text('Title: ${data['title']}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              if (data['description'] is String)
                                Text('Description: ${data['description']}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              if (data['date'] is String)
                                Text('Date: ${data['date']}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }

                return const Center(
                  child: Text('No items founds.'),
                );
              },
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: ItemButton(
                title: 'New Item',
                color: Colors.green,
                onItemPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TweetPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
