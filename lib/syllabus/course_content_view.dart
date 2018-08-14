import 'package:flutter/material.dart';

class SyllabusView extends StatefulWidget {
  SyllabusViewState createState() => SyllabusViewState();
}

class SyllabusViewState extends State<SyllabusView> {

  static var syllabus = """UNIT-1
SET THEORY AND RELATIONS 11 Hours 
Introduction to sets and subsets, operations on sets, laws of set theory. Duality, Principle of duality for the equality of sets. Countable and uncountable sets. Addition Principle. Introduction to Relations. Definition, Types of functions, operations on relations, matrix representation of relations, composition of relations, properties of relations, equivalence relations, partial orders, Hasse diagram. Posets- extremal elements on posets. (8L+3T)
 Suggested Reading: Some particular functions- Floor and ceiling functions, Projection, Unary and Binary operations.

UNIT-2
ALGEBRAIC STRUCTURES-GROUPS 10 Hours
 Groups, properties of groups. Some particular groups- The Klein 4-group, additive group of integers modulo n, multiplicative group of integers mod p, permutation groups. Subgroups, Cyclic groups, Coset decomposition of a group, homomorphism, isomorphism. (7L+3T) 
Suggested Reading: Lagrange's theorem and its consequences.

UNIT-3
COMBINATORICS 09 Hours 
Principles of counting: The rules of sum and product, permutations. Combinations- Binomial and multinomial theorems. Catalan numbers, Ramsey numbers. The Pigeon hole principle, the principle of inclusion and exclusion. Derangements, Rook polynomials. (7L+2T) 
Suggested Reading: Ordinary Generating Functions, Partitions of integers and their generating functions, exponential generating functions.

UNIT-4
GRAPH THEORY 09 Hours
Basic concepts: Types of graphs, order and size of a graph, in-degree and out-degree, connected and disconnected graphs, Eulerian graph, Hamiltonian graphs, sub-graphs, dual graphs, isomorphic graphs. Matrix representation of graphs: adjacency matrix, incidence matrix. Trees: spanning tree, breadth first search. Minimal spanning tree: Kruskal's algorithm, Prim's algorithm, shortest path-Dijkstra's algorithm. (7L+2T) 
Suggested Reading: Konigsberg bridge problem, Utilities problem, seating problem.

UNIT-5
NUMBER THEORY 09 Hours 
Introduction: Integers, properties of integers. Primes. Congruences-: Introduction, Equivalence Relations, Linear Congruences, Linear Diophantine Equations and the Chinese Remainder Theorem, Modular Arithmetic: Fermat's Theorem, Wilson's Theorem and Fermat Numbers. Polynomial congruences, Pythagorean equations. (7L+2T)  
Suggested Reading: Prime counting function, Test of primality by trial division, Sieve of Eratosthenes, Canonical factorization, Fundamental theorem of arithmetic, determining the Canonical factorization of a natural number.
 
Mathematics Lab
• Hasse diagram
• Rook Polynomials
• Minimal spanning tree- Kruskal's algorithm, Prim's algorithm.
• Shortest Path- Dijkstra'salgorithm.
""";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Structures'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.info_outline),
              onPressed: () {
                showLtpsTable();
              })
        ],
      ),
      body: SingleChildScrollView(
        controller: ScrollController(),
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Text(
            syllabus,
            textAlign: TextAlign.justify,
            textScaleFactor: 1.1,
          ),
        ),
      ),
    );
  }

  showLtpsTable() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SizedBox(
            //height: 100.0,
            child: BottomSheet(//TODO Animation Controller
                onClosing: () {},
                builder: (context) {
                  return Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Table(
                      border: TableBorder.all(color: Colors.black38),
                      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                      children: [
                        getTableRow(['L','T','P','S']),
                        getTableRow(['2','3','2','1'])
                      ],
                    ),
                  );
                }),
          );
        });
  }

  TableRow getTableRow(List<String> data){
    assert(data.length==4);
    return TableRow(
      children: List.generate(data.length, (index){
        return TableCell(child: Text(data[index],textAlign: TextAlign.center,style: TextStyle(fontSize: 16.0),));
      })
    );
  }
}

var reg = '[a-zA-Z].[a-zA-Z]';