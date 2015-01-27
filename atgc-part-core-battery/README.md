# atgc-part-core-battery

Energy storing module. Can store joules and redeliver them at a fixed or variable
throughput. 

## Options

- capacity:
  - entry model : 10 000 J (price: 10 000 000 J) (10 €)
  - high end model: 1 000 000 J (price: 1 000 000 000 J (1000 €))

## Sensors

- battery level (free):
  - a double from 0 to 1

## Actuators

- None


quelques ordres de grandeur copiés-collés depuis internet :

une batterie de voiture électrique : 15 à 30 kWh

un accu coutant 10€ = 10 000 000 joules consommés pour le fabriquer

Exemple: Accu 1.2V de 2000 mAh. L'énergie est de 2 A x 1.2V x 3600 secondes =
  8640 joules = 0.0024kWh
  Cet accu coûte 10 CHF, donc 4000 CHF par kWh pour la première décharg
