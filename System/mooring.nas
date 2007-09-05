#from Boeing314 with specific addon

# =========
# CONSTANTS
# =========

Constant = {};

Constant.new = func {
   obj = { parents : [Constant],

           HOURTOSECOND : 3600.0,
           MINUTETOSECOND : 60.0,
         };

   return obj;
};

 setprop("/sim/model/onsea",0);
# =================
# AUTOMATIC MOORING
# =================

Mooring = {};

Mooring.new = func {
   obj = { parents : [Mooring],
           AIRPORTSEC : 3.0
         };

   obj.init();

   return obj;
};

Mooring.init = func {
   me.presetseaplane();
}

# cannot make a settimer on a class member
presetairportcron = func {
   mooringsystem.presetairport();
}

# change of airport
Mooring.presetairport = func {
   airport = getprop("/sim/presets/airport-id");
   runway = getprop("/sim/presets/runway");

   if( getprop("/sim/presets/mooring/airport-id") != airport or
       getprop("/sim/presets/mooring/runway") != runway ) {
       altitude = getprop("/sim/presets/altitude-ft");

       if( altitude <= 0 ) {
           settimer(presetseaplanecron,1.0);
       }
       
       # in flight
       else {
           settimer(presetairportcron,me.AIRPORTSEC);
       }
   }

   # unchanged
   else {
       settimer(presetairportcron,me.AIRPORTSEC);
   }
}

# cannot make a settimer on a class member
presetseaplanecron = func {
   mooringsystem.presetseaplane();
}

# automatic seaplane preset
Mooring.presetseaplane = func {
   moorage = getprop("/sim/presets/moorage");
   if( moorage == nil or moorage ) {
       # wait for end of trim
       if( getprop("/sim/sceneryloaded") ) {
           settimer(presetharbourcron,1.0);
       }

       # wait for end initialization
       else {
           settimer(presetseaplanecron,1.0);
       }
   }

   # no automatic mooring
   else {
       settimer(presetairportcron,me.AIRPORTSEC);
   }
}

# cannot make a settimer on a class member
presetharbourcron = func {
   mooringsystem.presetharbour();
}

# goes to the harbour, once one has the tower
Mooring.presetharbour = func {
   found = "false";
   airport = getprop("/sim/presets/airport-id");
   if( airport != nil and airport != "" ) {
       seaplanes = props.globals.getNode("/sim/presets/mooring").getChildren("seaplane");
       for(i=0; i<size(seaplanes); i=i+1) {
            harbour = seaplanes[ i ].getChild("airport-id").getValue();
            if( harbour == airport ) {
                latitudedeg = seaplanes[ i ].getChild("latitude-deg").getValue();
                setprop("/position/latitude-deg",latitudedeg);
                longitudedeg = seaplanes[ i ].getChild("longitude-deg").getValue();
                setprop("/position/longitude-deg",longitudedeg);
                headingdeg = seaplanes[ i ].getChild("heading-deg").getValue();
                setprop("/orientation/heading-deg",headingdeg);
                adf = seaplanes[ i ].getNode("adf");
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

                runway = getprop("/sim/presets/runway");
                setprop("/sim/presets/mooring/airport-id",airport);
                setprop("/sim/presets/mooring/runway",runway);

                found = "true";
                setprop("/sim/model/onsea",1);

                # doesn't work in the same event, needs some delay
                settimer(presetwatercron,1.5);
                break;
            }
       }
   }

   # moorage not found
   if( found == "false" ) {
       settimer(presetairportcron,me.AIRPORTSEC);
   }
}

# cannot make a settimer on a class member
presetwatercron = func {
   mooringsystem.presetwater();
}

# computes the water level
Mooring.presetwater = func {
   altitudeft = getprop("/position/altitude-ft");
   aglft = getprop("/position/altitude-agl-ft");
   altitudeft = altitudeft - aglft;
   setprop("/position/altitude-ft",altitudeft);

   # scan airport change
   settimer(presetairportcron,me.AIRPORTSEC);
}


# ==============
# Initialization
# ==============



init = func {
   # schedule the 1st call
   
}

# objects must be here, otherwise local to init()
constant = Constant.new();
mooringsystem = Mooring.new();



init();
