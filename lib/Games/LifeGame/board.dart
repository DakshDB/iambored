import 'package:flutter/material.dart';

class Board extends StatefulWidget {
  const Board({Key? key, required this.cells, required this.rows, required this.columns}) : super(key: key);

  final List<List<bool>> cells;
  final int rows;
  final int columns;

  @override
  State<Board> createState() => _BoardState();
}

class _BoardState extends State<Board> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(width: 1.0, color: Colors.black),
          left: BorderSide(width: 1.0, color: Colors.black),
          right: BorderSide(width: 1.0, color: Colors.black),
          bottom: BorderSide(width: 1.0, color: Colors.black),
        ),
      ),
      child: GridView.builder(
        shrinkWrap: true, // Set shrinkWrap to true
        itemCount: widget.rows * widget.columns,
        gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.columns,
          crossAxisSpacing: 0,
          mainAxisSpacing: 0,
        ),
        itemBuilder: (BuildContext context, int index) {

          return Container(
            decoration: BoxDecoration(
              border: const Border(
                top: BorderSide(width: 1.0, color: Colors.black),
                left: BorderSide(width: 1.0, color: Colors.black),
                right: BorderSide(width: 1.0, color: Colors.black),
                bottom: BorderSide(width: 1.0, color: Colors.black),
              ),
              color: widget.cells[index ~/ (widget.columns) ][index % (widget.columns)] ? Colors.black : Colors.white,
            ),
          );
        },
      ),
    );

  }
}