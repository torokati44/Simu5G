//
//                  Simu5G
//
// Authors: Giovanni Nardini, Giovanni Stea, Antonio Virdis (University of Pisa)
//
// This file is part of a software released under the license included in file
// "license.pdf". Please read LICENSE and README files before using it.
// The above files and the present reference are part of the software itself,
// and cannot be removed from it.
//


package simu5g.stack.rlc;

//
// Muxer for the RLC layer of LTE Stack.
// Mux/Demux of data to/from MAC layer
//
simple LteRlcMux
{
    parameters:
        @display("i=block/classifier");                        // Display preferences

    gates:
        //#
        //# Gates connecting TM/UM/AM modules and RLC Mux
        //#
        inout TM_Sap;    // Transparent Mode SAP
        inout UM_Sap;    // Unacknowledged Mode SAP
        inout AM_Sap;    // Acknowledged Mode SAP

        //#
        //# Gates connecting RLC and MAC Layers
        //#
        input MAC_to_RLC;    // MAC to RLC
        output RLC_to_MAC;    // RLC to MAC
}

