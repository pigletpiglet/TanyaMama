import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart' as ui;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter/material.dart';

import 'package:flutter_tanya_mama/basics/widgets/core_stateful_widget.dart';
import 'package:flutter_tanya_mama/configs/configs.dart';

class HomePage extends CoreStatefulWidget {
  const HomePage({super.key});

  @override
  CoreStatefulWidgetState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends CoreStatefulWidgetState<HomePage> {
  final List<types.Message> _messages = [];

  late User user;
  late types.User _user;
  late types.User _mama;
  late ScrollController _scrollController;
  late Session session;
  late SessionHelper _sessionHelper;
  late ChatHelper _chatHelper;
  late String mamaEmotion;
  late bool isInitial;

  @override
  void initState() {
    _user = const types.User(id: "user@nasihatmama.com");
    _mama = const types.User(id: 'mama');
    _scrollController = ScrollController();
    _sessionHelper = SessionHelper();
    _chatHelper = ChatHelper();
    mamaEmotion = "smile";
    isInitial = false;

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return UserBuilder(builder: (user) {
      this.user = user;
      return FutureBuilder<Session>(
        future: _sessionHelper.getSession(user.email),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            session ??= snapshot.data;

            if (session.isEmpty) {
              return StartSessionWidget(
                onPressedStartSession: () {
                  setState(() {
                    session = Session(
                      id: randomString(),
                      userId: user.id,
                      isActive: true,
                    );
                    _sessionHelper.create(session);
                    _addMessageFromUser(
                      "Mama, ada waktu gak, mau tanya tanya nih mengenai barang ini?",
                    );
                    _addMessageFromMama(
                      "Ya, ${user.getFirstName()}, apa yang mau kamu beli?",
                    );
                    isInitial = true;
                  });
                },
              );
            }

            return FutureUse<Iterable<Chat>>(
              future: _chatHelper.getList(session.id),
              builder: (context, snapshot) {
                if (snapshot.hasData && !isInitial) {
                  final chats = snapshot.data;
                  for (var chat in chats) {
                    types.Message message;

                    if (chat.userId == user.id) {
                      message = types.TextMessage(
                        author: _user,
                        id: chat.id,
                        text: chat.content,
                      );
                    } else {
                      message = types.TextMessage(
                        author: _mama,
                        id: chat.id,
                        text: chat.content,
                      );
                    }

                    if (_messages.where((e) => e.id == message.id).isEmpty) {
                      _messages.insert(0, message);
                    }
                  }
                }

                return Column(
                  children: [
                    Image.asset(
                      getMamaImage(mamaEmotion),
                      width: MediaQuery.of(context).size.width * 0.4,
                    ),
                    Expanded(
                      child: ui.Chat(
                        messages: _messages,
                        customBottomWidget: !session.isActive
                            ? Container(
                                width: double.infinity,
                                color: Configs.secondaryColor,
                                height: 100,
                                child: Center(
                                  child: LongRaisedButton(
                                    height: 50,
                                    onPressed: () {
                                      setState(() {
                                        session = Session(
                                          id: randomString(),
                                          userId: user.id,
                                          isActive: true,
                                        );
                                        mamaEmotion = "smile";
                                        _messages.clear();
                                        _sessionHelper.create(session);
                                        _addMessageFromUser(
                                          "Mama, ada waktu gak, mau tanya tanya nih mengenai barang ini?",
                                        );
                                        _addMessageFromMama(
                                          "Ya, ${user.getFirstName()}, apa yang mau kamu beli?",
                                        );
                                        isInitial = true;
                                      });
                                    },
                                    child: const CustomText(
                                      "Chat Lagi dengan Mama",
                                      color: Configs.backgroundColor,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )
                            : null,
                        onPreviewDataFetched: _handlePreviewDataFetched,
                        onSendPressed: _handleSendPressed,
                        user: _user,
                        scrollController: _scrollController,
                      ),
                    ),
                  ],
                );
              },
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      );
    });
  }

  String getMamaImage(String name) {
    return "assets/mama_${name}_512.png";
  }

  void _addMessageFromMama(String message) {
    _addMessage(_mama, message);
  }

  void _addMessageFromUser(String message) {
    _addMessage(_user, message);
  }

  void _addMessage(types.User author, String text) {
    setState(() {
      final message = types.TextMessage(
        author: author,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: randomString(),
        text: text,
      );

      final now = DateTime.now().toUtc().millisecondsSinceEpoch;

      final chat = Chat(
        id: "${now}_${author.id}",
        sessionId: session.id,
        userId: author.id,
        content: text,
        chatType: ChatType.Text,
      );
      _chatHelper.create(chat);

      _messages.insert(0, message);
    });
  }

  void _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = (_messages[index] as types.TextMessage).copyWith(
      previewData: previewData,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _messages[index] = updatedMessage;
      });
    });
  }

  void _handleSendPressed(types.PartialText message) async {
    _addMessageFromUser(message.text);

    try {
      _scrollController.animateTo(
        0,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 500),
      );
    } catch (err) {}

    final reply = await MamaLogic.getReply(session, message.text);

    if (reply != null) {
      session = reply.session;
      if (session.verdict != null) {
        await _sessionHelper.update(session);
        _sessionHelper.endSession(session.id);
        session.isActive = false;
      }
      mamaEmotion = reply.mamaEmotion;

      for (final message in reply.replies) {
        _addMessageFromMama(message);
      }
    }
  }

  String randomString() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(255));
    return base64UrlEncode(values);
  }
}

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _rnd = Random();
String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));