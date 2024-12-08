import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:expense_tracker/models/gemini_model.dart';
import 'package:intl/intl.dart';
import 'home_page.dart';
import 'manage_monthly_budget.dart';
import 'monthly_expense_management_screen.dart';

class GeminiChatbot extends StatefulWidget {
  const GeminiChatbot({super.key});
  @override
  State<GeminiChatbot> createState() => _GeminiChatbotState();
}

class _GeminiChatbotState extends State<GeminiChatbot> {
  TextEditingController promprController = TextEditingController();
  static const apiKey = "AIzaSyCLMsBceiiyadT4_8slP101uzLYa6AiyV0";
  final model = GenerativeModel(model: "gemini-pro", apiKey: apiKey);
  final List<ModelMessage> prompt = [];

  Future<void> sendMessage() async {
    final message = promprController.text;
    setState(() {
      prompt.add(ModelMessage(
        isPrompt: true,
        message: message,
        time: DateTime.now(),
      ));
    });
    final content = [Content.text(message)];
    final response = await model.generateContent(content);
    setState(() {
      prompt.add(ModelMessage(
        isPrompt: false,
        message: response.text ?? "",
        time: DateTime.now(),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 20,
        title: const Text('AI ChatBot'),
        centerTitle: true,
        backgroundColor: Color(0xFF6699FF),
      ),
      body: Column(
        children: [
          Expanded(
              child: ListView.builder(
                  itemCount: prompt.length,
                  itemBuilder: (context, index) {
                    final message = prompt[index];
                    return UserPrompt(
                        isPrompt: message.isPrompt,
                        message: message.message,
                        date: DateFormat('hh:mm a').format(message.time));
                  })),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Expanded(
                  flex: 17,
                  child: TextField(
                    controller: promprController,
                    style: const TextStyle(color: Colors.black, fontSize: 15),
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
                        hintText: "Enter a prompt here"),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    sendMessage();
                    promprController.clear();
                  },
                  child: const CircleAvatar(
                    radius: 23,
                    backgroundColor: Color(0xFF6699FF),
                    child: Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        height: 65,
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomePage(),
                  ),
                );
              },
              tooltip: "Manage Monthly Expenses",
            ),
            IconButton(
              icon: const Icon(Icons.insert_chart_outlined),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MonthlyExpenseScreen(),
                  ),
                );
              },
              tooltip: "Overview",
            ),
            IconButton(
              icon: const Icon(Icons.access_time_outlined),
              onPressed: () {
                // Điều hướng đến trang cài đặt hoặc bất kỳ hành động nào
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ManageMonthlyBudgetScreen(),
                  ),
                );
              },
              tooltip: "Monthly Budget",
            ),
            IconButton(
              icon: const Icon(Icons.android),
              onPressed: () {},
              tooltip: "AI chat",
            ),
          ],
        ),
      ),
    );
  }

  Container UserPrompt(
      {required final bool isPrompt,
      required String message,
      required String date}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      margin: EdgeInsets.symmetric(vertical: 15)
          .copyWith(left: isPrompt ? 80 : 15, right: isPrompt ? 15 : 80),
      decoration: BoxDecoration(
          color: isPrompt ? Color(0xFF6699FF) : Colors.grey,
          borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: isPrompt ? Radius.circular(20) : Radius.zero,
              bottomRight: isPrompt ? Radius.zero : Radius.circular(20))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: TextStyle(
              fontWeight: isPrompt ? FontWeight.bold : FontWeight.normal,
              fontSize: 18,
              color: isPrompt ? Colors.white : Colors.black,
            ),
          ),
          Text(
            date,
            style: TextStyle(
              fontSize: 14,
              color: isPrompt ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
