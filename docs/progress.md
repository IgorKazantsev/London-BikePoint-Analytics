# Sprint 2 Progress

## Mis on valmis

* Docker Compose keskkond on seadistatud.
* PostgreSQL, Airflow, dbt ja Superset konteinerid on seadistatud ja käivitatavad.
* TfL BikePoint API ühendus töötab.
* Loodud Python ingestion skript korduvaks andmete sissevõtuks.
* API vastused salvestatakse Bronze kihti (`bronze.bikepoint_raw`) raw JSON kujul.
* Loodud dbt projekt transformatsioonide jaoks.
* Silver kiht (`silver_bikepoint_status`) parsib ja normaliseerib API andmed.
* Gold kiht (`gold_station_latest`) loob analüüsiks sobiva tabeli BikePoint jaamade viimase seisuga.
* Andmevoog API → Bronze → Silver → Gold töötab edukalt.

## Järgmised sammud

* Ühendada PostgreSQL Apache Supersetiga.
* Luua esimene visualiseering BikePoint jaamade asukohtade ja saadaval olevate rataste kohta.
* Lisada dbt andmekvaliteedi testid.
* Rakendada mõõdikud rataste defitsiidi ja dokkide tühjenemise kiiruse analüüsimiseks.

## Mis takistab

* Apache Superseti ühendamine PostgreSQL andmebaasiga vajab täiendavat seadistamist.
* Visualiseering ei ole veel valmis, kuid vajalikud andmed on Gold kihis olemas.

## Kontrollpunkt

Toimiv minimaalne andmevoog on olemas:

TfL BikePoint API → Python ingestion → Bronze (raw JSON) → dbt Silver → dbt Gold

Andmed laaditakse edukalt PostgreSQL andmebaasi ning dbt transformatsioonid töötavad korrektselt.
