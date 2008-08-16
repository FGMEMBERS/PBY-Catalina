#Taken and extracted from Boeing314A Model ( the nice and accurate FG Clipper) thanks to his unknown Author 


# EXPORT : functions ending by export are called from xml
# CRON : functions ending by cron are called from timer
# SCHEDULE : functions ending by schedule are called from cron



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
   globals.mooring.constantaero = ConstantAero.new();
   globals.mooring.mooringsystem = Mooring.new();
  
}

BoeingMain.init = func {
   me.instantiate();

   # schedule the 1st call
 
   settimer(func { me.sec5cron(); },0);
  
   # saved on exit, restored at launch
#me.savedata();
}


catalina = setlistener("/sim/signals/fdm-initialized", func { seaplane = BoeingMain.new(); removelistener(catalina); } );
