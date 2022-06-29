# PidiSim

PidiSim is a simulation software that completely emulates the Personal Integrated Dive Instrument PIDI on a personal computer. With this utility virtual dives with various mixed gases and dive profiles can be simulated realistically. This way software changes can be verified and tested first before they are downloaded into the target system.
![PidiSim](https://github.com/seanussystems/PidiSim/blob/main/Docu/PidiSim.jpg)

# Development

PidiSim is written in Pascal and has been migrated to Embarcadero Delphi Vers. 10.4.
It needs the following packages:
* KSVC bonus package (Konopka Signature VCL Controls aka Raize Components) vers. 6.1
* DiveCharts (TDepthChart and TPolarChart) vers. 2.0

# Installation

1. add the path '..\PidiSim\lib' to the environment variable
2. start Delphi and install the packages 'KSVC_Design.bpl' and 'divecharts_design.bpl'
3. open the project 'PidiSim.dproj' and rebuild it 