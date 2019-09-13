
var min_carrier_alt = 2;

# Do terrain modelling ourselves.
setprop("sim/fdm/surface/override-level", 1);

terrain_survol = maketimer (0.1, func () {

var lat = getprop("/position/latitude-deg");
var lon = getprop("/position/longitude-deg");
var info = geodinfo(lat, lon);




 if (info != nil) {
    if (info[0] != nil){
       setprop("fdm/jsbsim/environment/terrain-hight",info[0]);
#var terrain_hight = info[0];
#print("TERRAIN ",terrain_hight);
    }
    if (info[1] != nil){
      if (info[1].solid !=nil){
        setprop("fdm/jsbsim/environment/terrain-undefined",0);
        setprop("fdm/jsbsim/environment/terrain-solid",info[1].solid);
#var solid = info[1].solid;
#print("SOLID ",solid);

    }
      if (info[1].light_coverage !=nil)
       setprop("fdm/jsbsim/environment/terrain-light-coverage",info[1].light_coverage);
      if (info[1].load_resistance !=nil)
       setprop("fdm/jsbsim/environment/terrain-load-resistance",info[1].load_resistance);
      if (info[1].friction_factor !=nil)
       setprop("fdm/jsbsim/environment/terrain-friction-factor",info[1].friction_factor);
      if (info[1].bumpiness !=nil)
       setprop("fdm/jsbsim/environment/terrain-bumpiness",info[1].bumpiness);
      if (info[1].rolling_friction !=nil)
       setprop("fdm/jsbsim/environment/terrain-rolling-friction",info[1].rolling_friction);
      if (info[1].names !=nil)
       setprop("fdm/jsbsim/environment/terrain-names",info[1].names[0]);

#unfortunately when on carrier the info[1]  is nil,  only info[0] is valid
#var terrain_name = info[1].names[0];
#print("NAME ",terrain_name);
      #if (terrain_name == "Ocean" and terrain_hight >  min_carrier_alt)
        #setprop("fdm/jsbsim/environment/terrain-oncarrier",1);
    }else{
setprop("fdm/jsbsim/environment/terrain-undefined",1);
}
	      #debug.dump(geodinfo(lat, lon));


  }else {
    setprop("fdm/jsbsim/environment/terrain-hight",0);
    setprop("fdm/jsbsim/environment/terrain-solid",1);
    setprop("fdm/jsbsim/environment/terrain-oncarrier",0);
    setprop("fdm/jsbsim/environment/terrain-light-coverage",1);
    setprop("fdm/jsbsim/environment/terrain-load-resistance",1e+30);
    setprop("fdm/jsbsim/environment/terrain-friction-factor",1);
    setprop("fdm/jsbsim/environment/terrain-bumpiness",0);
    setprop("fdm/jsbsim/environment/terrain-rolling-friction",0.02);
    setprop("fdm/jsbsim/environment/terrain-names","unknown");
    }
});

terrain_survol.start ();

# Ctrl+Shift+Click starts a wildfire if enabled, see /usr/share/games/flightgear/Docs/README.wildfire

start_wildfire = func () {
  if (__kbd.shift.getBoolValue() and __kbd.ctrl.getBoolValue()) {
    wildfire.ignite (geo.click_position());
    if (wildfire.CAFire.cells_burning > 0) {
      if (wildfire.CAFire.cells_burning > 1) {
        setprop ("/sim/messages/copilot", wildfire.CAFire.cells_burning ~ " fires are burning!");
      }
      else {
        setprop ("/sim/messages/copilot", "A fire is burning!");
      }
    }
    else {
      setprop ("/sim/messages/copilot", "No fire is burning!");
    }
  }
};

wildfire_listener = nil;

setlistener ("/environment/wildfire/enabled", func (node) {
  if (node.getBoolValue ()) {
    wildfire_listener = setlistener ("/sim/signals/click", start_wildfire);
    # wildfire.trace = print; # uncomment to obtain traces from wildfire.nas
    setprop ("/sim/messages/copilot", "Ctrl+Shift+Click on the ground to start a wildfire!");
  }
  else if (wildfire_listener != nil) {
    removelistener (wildfire_listener);
    setprop ("/sim/messages/copilot", "Wildfires disabled.");
  }
}, init=1, type=0);
