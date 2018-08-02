import 'package:flutter/material.dart';

class SyllabusView extends StatefulWidget {
  SyllabusViewState createState() => SyllabusViewState();
}

class SyllabusViewState extends State<SyllabusView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Structures'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.info_outline), onPressed: () {})
        ],
      ),
      body: SingleChildScrollView(
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
}

final syllabus = """
UNIT-1
Water Treatment
Introduction, hardness of water, units of hardness, determination of hardness by EDTA method, disadvantages of hard water – boiler scales, boiler corrosion and caustic embrittlement, qualities of drinking water, treatment of water for municipal supply, desalination of water – reverse osmosis and electro dialysis, waste water – COD and BOD, treatment of waste water – primary, secondary and tertiary treatment methods, Principle and experimental determination of COD of waste water, estimation of dissolved alkali and alkaline earth metals in water by flame photometry, applications of nanotechnology in water treatment, problems [09 hours]

UNIT-2
Electrochemical Energy Systems
a) Electrode potential and cells – Introduction, classification of cells-primary, secondary and concentration cells, reference electrodes–calomel electrode and Ag/AgCl electrode, ion-selective electrode- glass electrode, determination of pHusing glass electrode, applications of these electrodes in determining strength of acids, bases and red-ox reactions, numerical problems b) Batteries - Basic concepts, battery characteristics, classification of batteries– primary, secondary and reserve batteries, modern batteries - construction, working and applications of zinc–air, nickel-metal hydride and Li-MnO batteries 2 c) Fuel cells - Introduction, types of fuel cells - alkaline, phosphoric acid, molten carbonate, solid polymer electrolyte and solid oxide fuel cells, construction and working of methanol-oxygen fuel cell. [10 hours]

UNIT-3
Chemical Fuels and Photovoltaic Cells
a) Chemical fuels - Definition, classification, calorific value-definition, gross and net calorific values, determination of calorific value of a solid / liquid fuel using Bomb calorimeter and problems on calorific value, petroleum cracking - fluidized bed catalytic cracking, reformation of petrol, octane number, cetane number, knocking – mechanism, prevention of knocking, anti-knocking agents, unleaded petrol, synthetic petrol – Fischer-Tropsch's process, power alcohol, biodiesel and hydrogen as a fuel. b) Photovoltaic cells – Production of solar grade silicon, physical and chemical properties of silicon relevant to photovoltaics, doping of silicon, construction and working of a PV- cell and uses. [09 hours] 

UNIT-4
Corrosion Science and Metal Finishing
a) Corrosion – Definition of chemical corrosion, electrochemical theory of corrosion, types of corrosion - differential metal, differential aeration corrosion (pitting and water line corrosion),stress corrosion, factors affecting the rate of corrosion, corrosion control: inorganic coatings – galvanizing and phosphating, metal coatings – galvanizing and tinning, corrosion inhibitors,cathodic protection by sacrificial anode method. b) Metal finishing - Technological importance of metal finishing, significance of polarization, decomposition potential and over-voltage in electroplating processes. Electroplating – Process, effect of plating variables on the nature of electro - deposit, surface preparation, electroplating of Cr and Au, estimation of copper in the effluent of electroplating industries by colorimetric method Electroless plating - Distinction between electroplating and electroless plating, advantages of electroless plating, electroless plating of copper on PCB [10 hours]

UNIT-5
Polymer Chemistry Polymers-Introduction, mechanism of coordination polymerization (Zeigler-Natta polymerization), methods of polymerization – bulk, solution, suspension and emulsion polymerization, glass transition temperature, structure and property relationship of polymers, number average molecular weight, weight average molecular weight and their determination a) Plastics - Definition of resins and plastics, compounding of resins to plastics, (mouldingconstituents), synthesis, properties and applications of PMMA and UF. b) Elastomers - Synthesis and application of butyl rubber and nitrile rubber c) Adhesives - Preparation and applications of epoxy resins d) Polymer composites, Wood polymer composites (WPC),Nano compositescomposition, effect of size on properties and usese) Conducting polymers – Definition, structure, properties and mechanism of  conduction in polyaniline and uses [10 hours] """;
