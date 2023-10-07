import 'package:flutter/material.dart';

class Items extends StatefulWidget {

  @override
  _ItemsState createState() => _ItemsState();
}

class _ItemsState extends State<Items> {

  List<ItemModel> items = [];
  GlobalKey targetKey = GlobalKey();
  OverlayEntry? overlayEntry;

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
                return GestureDetector(
                  child: Card(
                    key: items[index].key,
                    child: Image.asset(items[index].path),
                  ),
                  onTap: (){
                    RenderBox? sourceBox = items[index].key.currentContext!.findRenderObject() as RenderBox?;
                    Offset sourceOffset = sourceBox!.localToGlobal(Offset.zero);
                    print(sourceOffset);
                  },
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
                RenderBox? sourceBox = targetKey.currentContext!.findRenderObject() as RenderBox?;
                Offset sourceOffset = sourceBox!.localToGlobal(Offset.zero);
                print(sourceOffset);
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
      overlayEntry = await ItemsAnimation(context, targetKey).move(item);
      Overlay.of(context)!.insert(overlayEntry!);
      await Future.delayed(Duration(milliseconds: 1000));
      overlayEntry!.remove();
    }
  }

  @override
  void dispose() {
    overlayEntry!.dispose();
    super.dispose();
  }
}

class ItemModel {
  final String path;
  final GlobalKey key;

  ItemModel(this.path, this.key);
}

class ItemsAnimation{

  final BuildContext context;
  final GlobalKey targetKey;

  ItemsAnimation(this.context, this.targetKey);

  Future<OverlayEntry> move(final ItemModel item) async {
    RenderBox? sourceBox = item.key.currentContext!.findRenderObject() as RenderBox?;
    Offset sourceOffset = sourceBox!.localToGlobal(Offset.zero);

    RenderBox? targetBox = targetKey.currentContext!.findRenderObject() as RenderBox?;
    Offset targetOffset = targetBox!.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) {
        return Movement(
          child: Image.asset(item.path, width: sourceBox.size.width, height: sourceBox.size.height),
          source: sourceOffset,
          target: targetOffset
        );
      },
    );
  }

}

class Movement extends StatefulWidget {

  final Widget child;
  final Offset source, target;

  Movement({
    required this.child,
    required this.source,
    required this.target
  });

  @override
  _MovementState createState() => _MovementState();
}

class _MovementState extends State<Movement> with SingleTickerProviderStateMixin{

  late AnimationController controller;
  late Animation<Offset> animation;

  @override
  void initState() {
    controller = AnimationController(duration: Duration(milliseconds: 1200), vsync: this);
    animation = Tween(begin: widget.source, end: widget.target).animate(controller);
    controller.addStatusListener((AnimationStatus status) {
      print('${animation.value}: ${status.name}');
    });
    controller.forward();
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
              // child: Icon(Icons.location_on),
            );
          },
        ),
      ],
    );
  }
}
