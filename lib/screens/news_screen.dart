import 'package:flutter/material.dart';

import 'news_detail_screen.dart';

class NewsScreen extends StatelessWidget {
  NewsScreen({super.key});

  final List<Map<String, String>> events = [
    {
      "title": "Aanayat 3.0 – Open Mic Competition",
      "date": "13 April 2026",
      "full": """✨ UNCUT – Literary Society, VSBS presents ✨

🎤 Aanayat 3.0 – Open Mic Competition

“Shabdon se sur tak, har hunar ka ek hi manch.”

We are excited to invite you to showcase your talent at Aanayat 3.0! Whether it’s poetry, music, storytelling, or any form of expression — this is your stage to shine.

📅 Date: 13th April 2026
⏰ Time: 11 AM onwards
📍 Venue: GDPI Room, A Block

🏆 Win exciting prizes up to ₹5,000!

Don’t miss this opportunity to express, perform, and inspire. Scan the QR code on the poster to register now!

See you on stage! 🌟""",
    },

    {
      "title": "Mega Health Camp 🏥",
      "date": "1 April 2026",
      "full": """Mega Health Camp 🏥

"Health is the greatest wealth."

The NSS unit of VIPS-TC is organizing a Mega Health Camp, the biggest event of the semester, aimed at promoting health awareness and encouraging preventive healthcare among students and staff.

📅 Date: 1st April 2026
📍 Venue: Conference Room, B-Block
🕒 Timings: 10 AM onwards

⚠️ Attendance of all volunteers for health check-up is compulsory.
⚠️ Attendance of all female volunteers for session is compulsory.

📌 Volunteers will be awarded extra NSS credits.

For any queries:
Ananya Chauhan: +91 88003 01006
Riya: +91 9220458425

Regards
NSS VIPS-TC""",
    },

    {
      "title": "Period Pain Stimulation Event",
      "date": "15 April 2026",
      "full":
          """“Understanding pain builds empathy — experience it to respect it!”

The NSS Unit of VIPS-TC is organizing a Period Pain Stimulation Event to spread awareness and break stigmas surrounding menstrual health.

📅 Date: 15th April 2026
⏰ Time: 11:00 AM onwards
📍 Venue: Between A–B Block

📌 Open for all students
📌 NSS HOURS WILL BE PROVIDED

Contact:
Gaurika: 9971715297
Vanshika: 8569991819""",
    },

    {
      "title": "Scribble Day ✍️👕",
      "date": "17 April 2026",
      "full": """BCA'26 SCRIBBLE DAY!

The pens are ready, the wall is waiting, and the memories are calling!

📅 Date: 17th April
🕛 Time: 12:00 PM – 3:00 PM
📍 Behind C Block

Celebrate your journey, friendships, and memories.

Organised by Cultural Society, VSIT""",
    },

    {
      "title": "Food Donation Drive",
      "date": "9 April 2026",
      "full": """Food Donation Drive

We are organising a Food Donation Drive to support the underprivileged.

Donate rice, grains, pulses, biscuits, or packaged food.

Even a small contribution can make a difference.

Let’s help together ❤️""",
    },

    {
      "title": "Creative Exhibition 🌍",
      "date": "21 April 2026",
      "full": """Creative Exhibition

On World Creativity Day, VSIT is organising an exhibition for innovative ideas aligned with SDGs.

📅 Event Date: 21 April 2026
📍 Room 807, Block-C

🎓 E-Certificates for all participants

Showcase your creativity and innovation!""",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Campus News")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      NewsDetailScreen(event["title"]!, event["full"]!),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE5D9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event["title"]!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(event["date"]!),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
