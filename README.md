FG's PBY-5A Catalina Pelican
===========================
![USATourReady](usatour.png)

The Catalina Pelican (PBY-5A) has been refurbished in January/February 2016 in preparation of the USA Tour Leg 45th: The Flying Caravels.
Several changes were made, including

* FDM JSBsim updated, and new set file (PBY-5A)
* Autopilot updates, more stability
* Range adjustment
* New USA Tour Ready Splash Screen
* Model UVMap has been redone, favorishing a single texture, which facilitates Livery making
* Enabling multiplayer livery system
* Creation of new additional Liveries
* Fixing of the Ubershader (Normalmap and reflection), and a completed normal map now including other parts in addition to wings and hstab
* Updated method for Mooring (see note belown in Mooring)


Enjoy!<br>
USA Tour Consortium Team<br>
February 2016

GRTUX README
===============

That Package contains the Consolidated Catalina PBY6 model which was converted to be a  Firefighting aircraft with FlightGear Simulator you can  use it with 

        --aircraft=Catalina-plib

which works with FG cvs version  with Plib animations only

        --aircraft=Catalina

which works only with FG cvs built with Openscengraph. with both plib and osg animations

<b>USA Tour Consortium Note:</b>

Now, you can also use

       --aircraft=PBY-5A

To select, and use the USA Tour version of the Catalina Pelican

TODO
----

- Cockipt equipement
- More externals details  and animationson the fuse and engines 
- Texture improvement
- Variant textures
- FDM to be improved

HOW TO START THE AIRCRAFT
--------------------------

The model start with the engines stopped.

The how to start is explained  on the GUI "Menu/Help/Aircraft Help"
 
MOORING
--------

It is a Seaplane, so i have included the  mooring feature which is part of the  wonderful model  seaplane Boeing314
 
To start from an airport which has a close mooring place, situate the Seaplane  automatically on that place, with  Floats DOWN.
 
For example, KSFO which has a mooring place on the San Fransisco Bay near Bay Bridge. Or LFML (Marseilles Marignane) has a mooring place on the Etang de Berre.
 
The Cables which hold the aircraft in place, are simulated, with the "Brake Parking" feature

<b>USA Tour Consortium Note: This behavior has changed</b>

Use

         --prop:/sim/mooring=true

to enable mooring on any particular location. The advantage being, it now also works with any lat, lon, heading keypairs.

<u>Examples</u>

         --airport=KSFO --prop:/sim/mooring=true  #launches in Moor position at KSFO
         --airport=KSFO  # Launches on Runway
         --lat=0 --lon=0 --heading=0 --prop:/sim/mooring=true  #launches floating in specified coordinate.


WATER-BOMBING
-------------

The bombing effect is only done with our standard submodels, which works with  FG osg and FG plib.

You want AI Models being activated with the fgfs option

         --enable-ai-models

Water loading operation.
------------------------

The best process  is to get in touch, gliding on the water, at 100 kts with half  throttle and the elevator pushed to keep the nose on the water. You want, during loading, to increase to full throttle and, to pull the  elevator, in order, to raise the nose, and to reduce the coming drag, the aircraft  is getting more and more weight and the speed decrease to 70 kts (during the  loading period you must see the wakes, which is significant that you are in  touch). When the water tank (/consumables/fuel/tank[3] is fully loaded (1083 gal_us)  the Aircraft has some difficulties  to get altitude, be prepared to it.  Anyhow, in order to give that feature easier, I have included a switch which  accept to bomb with at least 500 gal_us of water (you have it).

****

:copyright: 2007, GRTUX team <br>
:copyright: 2016, Peter Brendt (Jabberwocky) <br>
:copyright: 2016, Israel Hernandez (IAHM-COL)