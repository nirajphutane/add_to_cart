import 'package:flutter/material.dart';

class Items extends StatefulWidget {

  @override
  _ItemsState createState() => _ItemsState();
}

class _ItemsState extends State<Items> {

  List<ItemModel> items = [];
  GlobalKey targetKey = GlobalKey();

  @override
  void initState() {
    items = getItems();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  key: items[index].key,
                  child: Image.asset(items[index].path),
                );
              }
            ),
          ),

          Center(
            child: TextButton(
              key: targetKey,
              child: Text('Upload'),
              style: TextButton.styleFrom(primary: Colors.blue,),
              onPressed: () {
                upload();
              },
            ),
          )
        ],
      ),
    );
  }

  List<ItemModel> getItems() {
    List<ItemModel> items = [];
    for(int i = 1; i <= 12; i++){
      items.add(ItemModel('assets/coffee_assets/$i.png', GlobalKey()));
    }
    return items;
  }

  void upload() async {
    for(ItemModel item in items){
      RenderBox? sourceBox = item.key.currentContext!.findRenderObject() as RenderBox?;
      Offset sourceOffset = sourceBox!.localToGlobal(Offset.zero);
      RenderBox? targetBox = targetKey.currentContext!.findRenderObject() as RenderBox?;
      Offset targetOffset = targetBox!.localToGlobal(Offset.zero);
      targetOffset = Offset(targetOffset.dx+(targetBox.size.width/2), targetOffset.dy+(targetBox.size.height/2));
      Navigator.push(context,
        Translation(
          Image.asset(item.path, width: 50, height: 50),
          sourceOffset,
          targetOffset,
          () async {
            print('CallBack');
          }
        )
      );
      await Future.delayed(Duration(milliseconds: 600));
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class ItemModel {
  final String path;
  final GlobalKey key;

  ItemModel(this.path, this.key);
}

class Translation extends PopupRoute {

  final Widget child;
  final Offset source, target;
  final Function callBack;

  Translation(this.child, this.source, this.target, this.callBack);

  @override
  Color get barrierColor => Colors.transparent;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'Motion';

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return Movement(child: child, source: source, target: target, callBack: callBack);
  }

  @override
  Duration get transitionDuration => Duration(milliseconds: 0);
}


class Movement extends StatefulWidget {

  final Widget child;
  final Offset source, target;
  final Function callBack;

  Movement({
    required this.child,
    required this.source,
    required this.target,
    required this.callBack
  });

  @override
  _MovementState createState() => _MovementState();
}

class _MovementState extends State<Movement> with SingleTickerProviderStateMixin{

  late AnimationController controller;
  late Animation<Offset> animation;

  @override
  void initState() {
    controller = AnimationController(duration: Duration(milliseconds: 500), vsync: this);
    animation = Tween(begin: widget.source, end: widget.target).animate(controller);
    controller.forward();
    controller.addStatusListener((status) {
      if(status == AnimationStatus.completed){
        Navigator.of(context).pop();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: controller,
          builder: (BuildContext context, Widget? child) {
            return Transform.translate(
              offset: animation.value,
              child: widget.child,
            );
          },
        ),
      ],
    );
  }
}
