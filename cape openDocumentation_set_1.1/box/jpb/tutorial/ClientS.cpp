// ********************************************************************
//
// Using the SMST Component: Sequencing Analysis on a Flowsheet
//
// May 3th 1999 - JPB - CAPE-OPEN Project
//
// ********************************************************************
//
//


// Include Files
#include <conio.h>
#include <fstream.h>
#include "ICapeNumericSMST_c.hh"


// The main program
int main(int argc, char* const* argv) {

  try {

    // Initialize the ORB -----------------------------------------------------

    CORBA::ORB_var orb = CORBA::ORB_init(argc, argv);


	// "Bind" Process to a ICapeNumericGATComponent Object using the Trader file ---------

	ifstream infile("Trader.txt", ios::nocreate);
	if (!infile) throw "Trader File Error";
	char IOR[527];
	infile >> IOR ;
	infile.close();
	ICapeNumericGATComponent_ptr cocomponent = ICapeNumericGATComponent::_narrow(orb->string_to_object(IOR));

	cout<<endl;
	cout<<"  -->  Bind to a CO Compliant SMST Component "<<endl;
	cout<<"  ----------------------------------------------------------------------------------"<<endl;
	cout<<"    Name        : "<<cocomponent->GetComponentName()<<endl;	
	cout<<"    Version     : "<<cocomponent->GetVersionNumber()<<endl;
	cout<<"    Description : "<<cocomponent->GetComponentDescription()<<endl;
	cout<<"    Location    : ";
	if(cocomponent->_is_remote()==char(1)) cout<<"Remote Object"<<endl;
	else cout<<"No Remote Object"<<endl;
	cout<<"  ----------------------------------------------------------------------------------"<<endl;
	cout<<endl;
	

	// Build the flowsheet ----------------------------------------------------

	//     Create the Flowsheet Factory
	cout<<endl;
	cout<<"  -->  Connection to the FlowsheetFactory"<<endl;
	ICapeNumericFlowsheetFactory_ptr gserver = cocomponent->CreateFlowsheetFactory("Flowsheet Service");
	if(CORBA::is_nil(gserver)==char(1)) throw "CreateFlowsheetFactory() - ObjRef=NIL";


	//     Create the flowsheet
	cout<<endl;
	cout<<"  -->  Flowsheet Creation"<<endl;
	ICapeNumericProcessGraph_ptr graph;
	CapeString gname="M&W Flowsheet";
	graph=ICapeNumericProcessGraph::_narrow(gserver->CreateFlowsheet(PROCESS_GRAPH, gname));
	if(CORBA::is_nil(graph)==char(1)) throw "CreateFlowsheet() - ObjRef=NIL";

	
	//     Complete the flowsheet     
	cout<<endl;
	cout<<"  -->  Flowsheet Completion"<<endl;

	graph->AddStream(1,1,2);
	graph->AddStream(4,4,5);
	graph->AddStream(2,2,3);
	graph->AddStream(8,3,0);
	graph->AddStream(3,3,4);
	graph->AddStream(7,0,1);
	graph->AddStream(9,5,0);
	graph->AddStream(5,5,6);

	graph->AddStreamType(7,FEED);
	graph->AddStreamType(8,PRODUCT);
	graph->AddStreamType(9,PRODUCT);



	// Build a Numeric Analysis

	//     Create the Analysis Factory
	cout<<endl;
	cout<<"  -->  Connection to the Numeric Server"<<endl;
	ICapeNumericAnalysisFactory_ptr nserver = cocomponent->CreateAnalysisFactory("Analysis Factory");
	if(CORBA::is_nil(nserver)==char(1)) throw "ReleaseAnalysisFactory() - ObjRef=NIL";

	cout<<"         Is the Sequencing Analysis available ? : ";
	CapeBoolean reply=nserver->SequencingImplementation();
	if(char(1)==reply) cout<<"Yes"<<endl;
	else cout<<"No !"<<endl;

	//     Create the Sequencing Analysis
	cout<<endl;
	cout<<"  -->  Sequencing Analysis Creation"<<endl;
	ICapeNumericAnalysis_ptr num=nserver->CreateNumericAnalysis(SEQUENCING, "Sequencing Analysis");
	if(CORBA::is_nil(num)==char(1)) throw "CreateNumericAnalysis() - ObjRef=NIL";
	cout<<"         Does the Sequencing Analysis have specific Parameters ? :";
	if(char(0)==num->ParameterAvailable()) cout<<" No"<<endl;
	else cout<<" Yes"<<endl;

	//     Perform the Sequencing Analysis on the flowsheet
	cout<<endl;
	cout<<"  -->  Sequencing Analysis Computation "<<endl;
	num->Perform(graph);

	//     Display the Sequencing Analysis Results
	cout<<endl;
	cout<<"  -->  Sequencing Analysis Results"<<endl;
	CapeLongSequence_var listofunits =(ICapeNumericSequencing::_narrow(num))->GetUnits();
	cout<<"          * List of Units ";
	if(listofunits->length()!=0){
		for (unsigned long int k=0;k<listofunits->length();k++) cout<<listofunits[k]<<" ";
	}
	cout<<endl;

	
	// Release Objects References and Exit process

	num->Destroy();
	num->_release();
	nserver->Destroy();
	nserver->_release();
	graph->Destroy();
	graph->_release();
	gserver->Destroy();
	gserver->_release();
	//cocomponent->Shutdown(); If you want to shutdown the server
	cocomponent->_release();

  }
	catch(CORBA::Exception& e) {
	cerr << e << endl;
    return(1);
	}
	catch(const char * s) {
	cerr << s << endl;
	return(1);
	}
  return(0);
}
