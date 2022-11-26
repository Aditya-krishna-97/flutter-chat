import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatefulWidget {
  MessageBubble(
    this.message,
    this.userName,
    this.userImage,
    this.isMe,
    this.createdAt,
      {
    this.key, this.gestureTapCallBack,
  });

  final Key key;
  final String message;
  final String userName;
  final String userImage;
  final bool isMe;
  final DateTime createdAt;
  final GestureTapCallback gestureTapCallBack;

  @override
  _MessageBubbleState createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {

  @override
  Widget build(BuildContext context) {
    //print(createdAt);
    return Stack(
      children: [
        GestureDetector(
    onLongPress: widget.isMe ? widget.gestureTapCallBack : (()=>print("Do nothing")),
          child: Row(
            mainAxisAlignment:
                widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 180,
                padding: EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 16,
                ),
                margin: EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: widget.isMe ? Colors.grey[600] : Theme.of(context).accentColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                    bottomLeft: !widget.isMe ? Radius.circular(0) : Radius.circular(12),
                    bottomRight: widget.isMe ? Radius.circular(0) : Radius.circular(12),
                  ),
                ),

                  child: Column(
                    crossAxisAlignment:
                        widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.userName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: widget.isMe
                              ? Colors.black
                              : Theme.of(context).accentTextTheme.title.color,
                        ),
                        textAlign: widget.isMe ? TextAlign.end : (TextAlign.justify),
                      ),
                      Text(
                        widget.message,
                        style: TextStyle(
                          color: widget.isMe
                              ? Colors.black
                              : Theme.of(context).accentTextTheme.title.color,
                        ),
                        textAlign: TextAlign.start,
                      ),

                      Text(
                        DateFormat('HH:mm').format(widget.createdAt),
                        style: TextStyle(
                            color: widget.isMe ? Colors.blue : Colors.blue,
                            fontSize: 12.0,
                        ),
                        textAlign: widget.isMe ? TextAlign.end : TextAlign.start,
                      )
                    ],
                  ),
                ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          left: widget.isMe ? null : 180,
          right: widget.isMe ? 180 : null,
          child: CircleAvatar(
            backgroundImage: NetworkImage(
              widget.userImage,
            ),
          ),
        ),
      ],
      overflow: Overflow.visible,
    );
  }
}
