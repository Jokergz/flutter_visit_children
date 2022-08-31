import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Visit Children'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      process();
    });

    c = ScrollController();
    c.addListener(() {
      process();
    });
  }

  late ScrollController c;
  GlobalKey listViewKey = GlobalKey();

  List visitData = [];

  SliverMultiBoxAdaptorElement? listViewElement;
  Rect? listViewRect;
  Offset? listViewOffset;
  void process() {
    listViewElement ??= getElement(listViewKey.currentContext!);
    listViewRect ??= listViewElement!.renderObject.paintBounds;
    listViewOffset ??=
        (listViewKey.currentContext!.findRenderObject() as RenderBox)
            .globalToLocal(Offset.zero);
    visitData.clear();
    listViewElement!.visitChildren((e) {
      RenderBox box = e.renderObject as RenderBox;
      Offset offset = box.localToGlobal(listViewOffset!);
      if ((offset.dy + box.size.height) >= 0 &&
          offset.dy < listViewRect!.height) {
        Map item = {
          'slot': e.slot as int,
          'dy': offset.dy.floor(),
          'h': box.size.height,
          'ratio': 1,
        };
        if (offset.dy < 0) {
          item['ratio'] = (box.size.height + offset.dy) / box.size.height;
        } else if (offset.dy + box.size.height > listViewRect!.height) {
          item['ratio'] = (listViewRect!.height - offset.dy) / box.size.height;
        }
        visitData.add(item);
      }
    });
    setState(() {});
  }

  SliverMultiBoxAdaptorElement getElement(BuildContext e) {
    bool isFind = false;
    while (!isFind) {
      e.visitChildElements((element) {
        e = element;
      });
      if (e is SliverMultiBoxAdaptorElement) {
        isFind = true;
      }
    }
    return e as SliverMultiBoxAdaptorElement;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          ListView.builder(
            key: listViewKey,
            itemCount: 50,
            controller: c,
            itemBuilder: (_, i) {
              return Item(i: i);
            },
          ),
          Center(
            child: Container(
              color: Colors.black54,
              width: 300,
              child: Wrap(
                children: [
                  for (Map item in visitData)
                    Visit(
                      slot: '${item['slot']}',
                      ratio: item['ratio'].toStringAsFixed(2),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Visit extends StatelessWidget {
  const Visit({Key? key, required this.slot, required this.ratio})
      : super(key: key);
  final String slot;
  final String ratio;
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: 50,
      height: 80,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            slot,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            ratio,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class Item extends StatelessWidget {
  const Item({Key? key, required this.i}) : super(key: key);
  final int i;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.blue,
            width: 5,
          ),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        i.toString(),
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
