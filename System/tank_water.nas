#Mise à jour de la capacité des réservoirs d'eau

setprop("/fdm/jsbsim/fcs/water-tank-capacity",0);
setprop("/consumables/fuel/tank[3]level-gal_us",0);




Tank_water=func{
            water_loading=getprop("/fdm/jsbsim/fcs/water-tank-capacity");
            setprop("/consumables/fuel/tank[3]level-gal_us",water_loading);
            settimer ( Tank_water, 0.5 );
            }
            
 Tank_water();
 
 
 Bomb_water=func{
            if(getprop("/fdm/jsbsim/fcs/water-bombing-timing") == 1) {
            setprop("/sim/model/waterloading",0);
            setprop("/ai/submodels/submodel/count",20);
            setprop("/consumables/fuel/tank[3]level-gal_us",0);
            setprop("/fdm/jsbsim/fcs/waterloading-cmd-norm",0);
            setprop("/fdm/jsbsim/fcs/water-reload-position",0);
            setprop("/fdm/jsbsim/fcs/water-tank-capacity",0);
            setprop("/fdm/jsbsim/fcs/water-loaded-pos",0);
            print("bombing done");
            }else{
            print("loop");
             settimer ( Bomb_water, 0.1 );
             }
     }