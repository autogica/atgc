# atg-core-energy

Manage the energy flow through the simulation.

`atgc-core-energy` acts like a global bank, except instead of storing money
and using dollars as a currency, we store and exchange `Joules`.

Joules will be used to buy and sell stuff, solar panel will bring in joules etc
also joules will be used to directly power jet engines, actuators, lasers..

using only one unit is really because it is convenient, and simpler than mixing
different units like money or watts. It's simple, universal, and nicely models all
kind of homeostatic and energy equilibrium patterns found in natural or artificial systems.
