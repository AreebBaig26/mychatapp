import 'package:chatapp_real/pages/chat_page.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff703eff),
      body: Container(
        margin: EdgeInsets.only(top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Row(
                children: [
                  Image.asset("images/wave.png", height: 40),
                  SizedBox(width: 10),
                  Text(
                    "Hello,",
                    // textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    " Areeb",
                    // textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  Container(
                    margin: EdgeInsets.only(right: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.person,
                      size: 30,
                      color: Color(0xff703eff),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                "Welcome To",
                // textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color.fromARGB(255, 238, 219, 219),
                  fontSize: 23.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                "Chat Up",
                // textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color.fromARGB(255, 238, 219, 219),
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xffececf8),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            prefixIcon: Icon(Icons.search),
                            hintText: "Search Username...",
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Material(
                        elevation: 3.0,
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            width: MediaQuery.of(context).size.width,
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatPage(),
                                  ),
                                );
                              },
                              // shape: RoundedRectangleBorder(),
                              leading: CircleAvatar(
                                backgroundImage: AssetImage("images/boy.jpg"),
                              ),
                              title: Text(
                                "Areeb Baig",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text("How are you..?"),
                              trailing: Text("7:15 PM"),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
