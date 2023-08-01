#!/bin/bash

# Navigiere zu dem Verzeichnis, in dem sich das Skript befindet
cd "$(dirname "$0")"

# Schleife über alle Verzeichnisse in der aktuellen Ebene
for folder in */; do
  # Wechsle in das aktuelle Verzeichnis
  cd "$folder"
  
  # Führe den Befehl aus
  postProcess -func sampleDict -latestTime
  
  # Gehe zurück in das ursprüngliche Verzeichnis
  cd ..
done
