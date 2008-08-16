#Taken and extracted from Boeing314A Model ( the nice and accurate  FG Clipper) thanks to his unknown Author 


# =================
# AUTOMATIC MOORING
# =================

Mooring = {};

Mooring.new = func {
   var obj = { parents : [Mooring],

           mooring : nil,
           presets : nil,
           seaplanes : nil,

           MOORINGSEC : 5.0,
           AIRPORTSEC : 3.0,
           HARBOURSEC : 2.0,

           BOATDEG : 0.0001,

           FLIGHTFT : 20,
           BOATFT : 10,                                            # crew in a boat
           
           boataltitude : constant.FALSE
         };

   obj.init();

   return obj;
};

Mooring.init = func {
   me.mooring = props.globals.getNode("/systems/mooring");
   me.presets = props.globals.getNode("/sim/presets");
   me.seaplanes = props.globals.getNode("/systems/mooring/route").getChildren("seaplane");

   me.presetseaplane();
}

Mooring.schedule = func {
   me.towerchange();
   me.mooragechange();
}

Mooring.dialogexport = func {
   var harbour = "";
   var dialog = me.mooring.getChild("dialog").getValue();
   
   # KSFO  Treasure Island ==> KSFO
   var idcomment = split( " ", dialog );
   var moorage = idcomment[0];

   for(var i=0; i<size(me.seaplanes); i=i+1) {
       harbour = me.seaplanes[ i ].getChild("airport-id").getValue();

       if( harbour == moorage ) {
           me.setmoorage( i, moorage );

           setprop("/sim/tower/airport-id",moorage);
           break;
       }
   }
}

Mooring.setmoorage = func( index, moorage ) {
    var latitudedeg = me.seaplanes[ index ].getChild("latitude-deg").getValue();
    var longitudedeg = me.seaplanes[ index ].getChild("longitude-deg").getValue();
    var headingdeg = me.seaplanes[ index ].getChild("heading-deg").getValue();

    me.presets.getChild("latitude-deg").setValue(latitudedeg);
    me.presets.getChild("longitude-deg").setValue(longitudedeg);

    me.setboatposition( latitudedeg, longitudedeg, moorage );

    me.presets.getChild("heading-deg").setValue(headingdeg);

    # forces the computation of ground
    me.presets.getChild("altitude-ft").setValue(-9999);

    me.presets.getChild("airspeed-kt").setValue(0);

    me.setadf( index, moorage );
}

Mooring.setadf = func( index, beacon ) {
   var frequency = 0.0;
   var adf = me.seaplanes[ index ].getNode("adf");

   if( adf != nil ) {
       frequency = adf.getChild("selected-khz");
       if( frequency != nil ) {
           frequencykz = frequency.getValue();
           setprop("/instrumentation/adf/frequencies/selected-khz",frequencykz);
       }
       frequency = adf.getChild("standby-khz");
       if( frequency != nil ) {
           frequencykz = frequency.getValue();
           setprop("/instrumentation/adf/frequencies/standby-khz",frequencykz);
       }
   }
}

Mooring.setboatposition = func( latitudedeg, longitudedeg, airport ) {
   # offset to be outside the hull
   var latitudedeg = latitudedeg + me.BOATDEG;
   var longitudedeg = longitudedeg + me.BOATDEG;

   setprop( "/systems/seat/position/boat-view/latitude-deg", latitudedeg );
   setprop( "/systems/seat/position/boat-view/longitude-deg", longitudedeg );

   me.mooring.getChild("boat-id").setValue(airport);

   me.boataltitude = constant.TRUE;
}

Mooring.setboatheight = func( altitudeft ) {
   setprop( "/systems/seat/position/boat-view/altitude-ft", altitudeft );

   me.boataltitude = constant.FALSE;
}

Mooring.setboatdefault = func {
   var airport = me.presets.getChild("airport-id").getValue();
   var latitudedeg = getprop("/position/latitude-deg");
   var longitudedeg = getprop("/position/longitude-deg");

   me.setboatposition( latitudedeg, longitudedeg, airport );

   me.setboatsea();
}

Mooring.setboatsea = func {
   var altitudeft = getprop("/position/altitude-ft");
   var aglft = getprop("/position/altitude-agl-ft");

   # sea level
   var altitudeft = altitudeft - aglft - constantaero.AGLFT;

   # boat level
   altitudeft = altitudeft + me.BOATFT;

   me.setboatheight( altitudeft );
}

# computes boat altitude, once seaplane on the water
Mooring.mooragechange = func {
   if( me.boataltitude ) {
       me.setboatsea();
   }
}

# tower changed by dialog (destination or airport location)
Mooring.towerchange = func {
   var latitudedeg = 0.0;
   var longitudedeg = 0.0;
   var altitudeft = 0.0;
   var harbour = "";
   var tower = getprop("/sim/tower/airport-id");

   if( tower != me.mooring.getChild("boat-id").getValue() ) {

       for(var i=0; i<size(me.seaplanes); i=i+1) {
           harbour = me.seaplanes[ i ].getChild("airport-id").getValue();
           if( harbour == tower ) {

               # boat corresponding to the tower
               latitudedeg = me.seaplanes[ i ].getChild("latitude-deg").getValue();
               longitudedeg = me.seaplanes[ i ].getChild("longitude-deg").getValue();

               me.setboatposition( latitudedeg, longitudedeg, tower );

               # rough guess of boat altitude from tower !
               altitudeft = getprop("/sim/tower/altitude-ft" );
               me.setboatheight( altitudeft );
               break;
           }
       }
   }
}

# change of airport
Mooring.presetairport = func {
   var airport = me.presets.getChild("airport-id").getValue();

   if( airport != nil and airport != "" ) {
       settimer(func{ me.presetseaplane(); },me.HARBOURSEC);
   }

   # unchanged
   else {
       settimer(func{ me.presetairport(); },me.AIRPORTSEC);
   }
}

# automatic seaplane preset
Mooring.presetseaplane = func {
   # wait for end of trim
   if( getprop("/sim/sceneryloaded") ) {
       settimer(func{ me.presetharbour(); },me.HARBOURSEC);
   }

   # wait for end of initialization
   else {
       settimer(func{ me.presetseaplane(); },me.HARBOURSEC);
   }
}

# goes to the harbour, once one has the tower
Mooring.presetharbour = func {
   var aglft = 0.0;
   var airport = "";
   var harbour = "";
   var found = constant.FALSE;

   if( getprop("/controls/mooring/automatic") ) {
       aglft = getprop("/position/altitude-agl-ft");

       # on sea
       if( aglft < me.FLIGHTFT ) {
           airport = me.presets.getChild("airport-id").getValue();
           if( airport != nil and airport != "" ) {
               for(var i=0; i<size(me.seaplanes); i=i+1) {
                   harbour = me.seaplanes[ i ].getChild("airport-id").getValue();

                   if( harbour == airport ) {
                       me.setmoorage( i, airport );

                       fgcommand("presets-commit", props.Node.new());

                       # presets cuts the engines
                       var eng = props.globals.getNode("/controls/engines");
                       if (eng != nil) {
                           foreach (var c; eng.getChildren("engine")) {
                                    c.getNode("magnetos", 1).setIntValue(3);
                           }
                       }

                       found = constant.TRUE;
                       break;
                   }
               }
           }
       }
   }

   # in flight
   if( !found ) {
       me.setboatdefault();
   }
}
