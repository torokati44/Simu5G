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
package simu5g.nodes;

import inet.common.MessageDispatcher;
import inet.linklayer.ppp.PppInterface;
import inet.transportlayer.udp.Udp;
import inet.node.base.NetworkLayerNodeBase;
import simu5g.corenetwork.gtp.GtpUser;
import simu5g.corenetwork.trafficFlowFilter.TrafficFlowFilter;

//
// Implements a simple model of the 5GC UPF
//
// The core network can contain multiple UPFs: see example in "simulations/NR/standalone"
// UPF not connected to an external Data Network are intermediate UPFs. In the current version, intermediate UPFs just act
// like IP routers.
// UPFs connected to an external Data Network take care of (de)tunneling packets according to GTP
//
module Upf extends NetworkLayerNodeBase
{
    parameters:
        @display("bgb=1348.9225,1103.51;i=abstract/switch");
        @figure[applicationLayer](type=rectangle; pos=250,6; size=1000,130; lineColor=#808080; cornerRadius=5; fillColor=#ffff00; fillOpacity=0.1);
        @figure[applicationLayer.title](type=text; pos=1245,11; anchor=ne; text="application layer");
        @figure[transportLayer](type=rectangle; pos=250,156; size=1000,130; fillColor=#ff0000; lineColor=#808080; cornerRadius=5; fillOpacity=0.1);
        @figure[transportLayer.title](type=text; pos=1245,161; anchor=ne; text="transport layer");
        @figure[submodules];

        string nodeType = default("UPF");   // do NOT change!
        forwarding = default(true);
        multicastForwarding = default(false);

    gates:
        // this gate is used for the UPF connected to the external data network
        // it must be left unconnected for intermediate UPFs
        inout filterGate @loose @labels(PppFrame-conn);

    submodules:
        pppIf: PppInterface {
            parameters:
                @display("p=1150,525");
        }
        udp: Udp {
            parameters:
                @display("p=374.0425,201.4075");
        }
        trafficFlowFilter: TrafficFlowFilter {
            parameters:
                @display("p=881.7925,79.5475");
                ownerType = parent.nodeType;
        }
        gtp_user: GtpUser {
            parameters:
                @display("p=525,80");
        }
        tn: MessageDispatcher {
            parameters:
                @display("p=750,296;b=1000,5,,,,1");
        }
        at: MessageDispatcher {
            parameters:
                @display("p=750,146;b=1000,5,,,,1");
        }

    connections:

        gtp_user.socketOut --> at.in++;
        gtp_user.socketIn <-- at.out++;

        pppIf.upperLayerOut --> trafficFlowFilter.internetFilterGateIn;
        pppIf.upperLayerIn <-- gtp_user.pppGate;

        trafficFlowFilter.gtpUserGateOut --> gtp_user.trafficFlowFilterGate;

        // at dispatcher to transport layer connections
        at.out++ --> udp.appIn;
        at.in++ <-- udp.appOut;

        // transport layer to tn dispatcher connections
        udp.ipOut --> tn.in++;
        udp.ipIn <-- tn.out++;

        // tn dispatcher to network layer connections
        tn.out++ --> ipv4.transportIn if hasIpv4;
        tn.in++ <-- ipv4.transportOut if hasIpv4;

        tn.out++ --> ipv6.transportIn if hasIpv6;
        tn.in++ <-- ipv6.transportOut if hasIpv6;

        tn.out++ --> generic.transportIn if hasGn;
        tn.in++ <-- generic.transportOut if hasGn;

        tn.out++ --> nl.in++;
        tn.in++ <-- nl.out++;

        pppIf.phys <--> filterGate;
}
