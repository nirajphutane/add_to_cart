import 'package:flutter/material.dart';

class AnimatedTranslate extends StatefulWidget {

  @override
  _AnimatedTranslateState createState() => _AnimatedTranslateState();
}

class _AnimatedTranslateState extends State<AnimatedTranslate> with SingleTickerProviderStateMixin{

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
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
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
                child: ElevatedButton(
                  key: targetKey,
                  child: Text('Upload'),
                  onPressed: () {
                    upload();
                  },
                ),
              )
            ],
          ),
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
    Translate translate = Translate(context: context, targetKey: targetKey);
    for(ItemModel item in items){
      await Future.delayed(Duration(milliseconds: 250));
      late OverlayEntry overlayEntry;
      overlayEntry = translate.animate(imagePath: item.path, sourceKey: item.key, animationStatus: (AnimationStatus status){
        if(status == AnimationStatus.completed){
          overlayEntry.remove();
        }
      });
      Overlay.of(context)!.insert(overlayEntry);
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

class Translate{

  final BuildContext context;
  late RenderBox targetBox;
  late Offset targetOffset;

  Translate({required this.context, required final GlobalKey targetKey}){
    targetBox = targetKey.currentContext!.findRenderObject() as RenderBox;
    targetOffset = targetBox.localToGlobal(Offset.zero);
  }

  OverlayEntry animate({required String imagePath, required GlobalKey sourceKey, required Function animationStatus}){
    RenderBox? sourceBox = sourceKey.currentContext!.findRenderObject() as RenderBox?;
    Offset sourceOffset = sourceBox!.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) {
        return TranslateAnimation(
          child: Image.asset(imagePath, width: sourceBox.size.width, height: sourceBox.size.height),
          // source: Offset(sourceOffset.dx+(sourceBox.size.width/2), sourceOffset.dy+(sourceBox.size.height/2)),
          // target: targetOffset,
          source: sourceOffset,
          target: Offset(targetOffset.dx+((targetBox.size.width-sourceBox.size.width)/2), targetOffset.dy+((targetBox.size.height+sourceBox.size.height)/2)),
          animationStatus: animationStatus,
        );
      },
    );
  }
}


class TranslateAnimation extends StatefulWidget {

  final Widget child;
  final Offset source, target;
  final Function animationStatus;

  TranslateAnimation({
    required this.child,
    required this.source,
    required this.target,
    required this.animationStatus
  });

  @override
  _TranslateAnimationState createState() => _TranslateAnimationState();
}

class _TranslateAnimationState extends State<TranslateAnimation> with SingleTickerProviderStateMixin{

  late AnimationController controller;
  late Animation<Offset> translateAnimation;
  late Animation<double> opacityAnimation;

  @override
  void initState() {
    controller = AnimationController(duration: Duration(milliseconds: 1000), vsync: this);
    translateAnimation = Tween<Offset>(begin: widget.source, end: widget.target).animate(controller);
    opacityAnimation = Tween<double>(begin: 1, end: 0.1).animate(controller);
    controller.forward();
    controller.addStatusListener((status) {
      widget.animationStatus(status);
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
              offset: translateAnimation.value,
              child: Opacity(
                opacity: opacityAnimation.value,
                child: widget.child
              ),
            );
          },
        ),
      ],
    );
  }
}
