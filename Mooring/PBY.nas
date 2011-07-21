#Taken and adapted from Boeing314A Model ( the nice and accurate FG Clipper) thanks to his unknown Author




Constant = {};

Constant.new = func {
   obj = { parents : [Constant],

           TRUE : 1.0,                             # no boolean
           FALSE : 0.0,
         };



   return obj;
};

# ==============
# Initialization
# ==============

BoeingMain = {};

BoeingMain.new = func {
   obj = { parents : [BoeingMain]
         };

   obj.init();

   return obj;
}



# 5 s cron
BoeingMain.sec5cron = func {
   mooringsystem.schedule();

   # schedule the next call
   settimer(func{ me.sec5cron(); },mooringsystem.MOORINGSEC);
}

# global variables in Boeing314 namespace, for call by XML
BoeingMain.instantiate = func {

   globals.mooring.constant = Constant.new();

   globals.mooring.mooringsystem = Mooring.new();

}

BoeingMain.init = func {
   me.instantiate();

   # schedule the 1st call

   settimer(func { me.sec5cron(); },0);

   # saved on exit, restored at launch
#me.savedata();
}




if (getprop("/sim/mooring")){
catalina = setlistener("/sim/signals/fdm-initialized", func { seaplane = BoeingMain.new(); removelistener(catalina); }
);
}

# =================
# AUTOMATIC MOORING
# =================

Mooring = {};

Mooring.new = func {
   var obj = { parents : [Mooring],

           mooring : nil,
           presets : nil,
           seaplanes : nil,

           MOORINGSEC : 1.0,
           AIRPORTSEC : 1.0,
           HARBOURSEC : 1.0,

           BOATDEG : 0.0001,

           FLIGHTFT : 20,


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

   me.mooragechange();
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



Mooring.setboatdefault = func {
   var airport = me.presets.getChild("airport-id").getValue();
   var latitudedeg = getprop("/position/latitude-deg");
   var longitudedeg = getprop("/position/longitude-deg");

   me.setboatposition( latitudedeg, longitudedeg, airport );
}



# computes boat altitude, once seaplane on the water
Mooring.mooragechange = func {
   if( me.boataltitude ) {
       me.setboatsea();
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

# goes to the harbour
Mooring.presetharbour = func {
   var aglft = 0.0;
   var airport = "";
   var harbour = "";
   var found = constant.FALSE;
    if( getprop("/controls/mooring/automatic") ) {
           airport = me.presets.getChild("airport-id").getValue();
           if( airport != nil and airport != "" ) {
               for(var i=0; i<size(me.seaplanes); i=i+1) {
                   harbour = me.seaplanes[ i ].getChild("airport-id").getValue();
                   if( harbour == airport ) {
                       me.setmoorage( i, airport );
                       fgcommand("presets-commit", props.Node.new());
                       found = constant.TRUE;
                       break;
                   }
               }
           }
        }
}

