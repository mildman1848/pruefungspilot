# Audit Report: Sachkundenachweis Fragenkatalog

**Datum:** 2026-08-07
**Offizielles PDF:** `Sachkundefragen-neu-ab-01.01.2025.pdf` (Tierärztekammer Nordrhein, 58 Seiten)
**Offizielles Lösungs-PDF:** `Sachkundefragen-Loesungen-neu-ab-01.01.2025.pdf` (10 Seiten)
**Unser Katalog:** `assets/courses/sachkundenachweis/questions.json` (197 Fragen)

---

## Zusammenfassung

| Prüfpunkt | Ergebnis |
|---|---|
| Gesamtzahl Fragen | 197 ✅ (übereinstimmend) |
| IDs lückenlos 1–197 | ✅ |
| Mindestens 1 richtige Antwort pro Frage | ✅ |
| Antwort-Index in Range | ✅ |
| **Lösungen (correctAnswers) korrekt** | **5 Fehler gefunden und korrigiert** ✅ |
| **Frage-Texte stimmen mit offiziellem Katalog überein** | **35 Abweichungen, davon ~20 inhaltlich verschiedene Fragen** ⚠️ |
| Keine Duplikat-Antworten innerhalb einer Frage | ✅ |

---

## 1. Korrigierte Lösungsfehler (5 Fragen)

Diese 5 Fragen haben identischen Text zum offiziellen Katalog, aber die `correctAnswers` stimmten nicht.
Alle wurden gegen das offizielle Lösungs-PDF verifiziert und korrigiert:

| ID | Frage (gekürzt) | War | Jetzt (offiziell) |
|---|---|---|---|
| 48 | Kinder im Gesicht verletzen | A, B | **A, B, D** |
| 78 | Können Hunde unsere Sprache verstehen? | C | **A, C** |
| 81 | Kastration → Aggression? | B, C, D | **C, D** |
| 143 | Älteren Hunden nichts beibringen? | B | **B, C** |
| 159 | Hund hat eingekotet, duckt sich | B | **A, B** |

---

## 2. Inhaltliche Abweichungen (~20 Fragen) ⚠️

Diese Fragen existieren in unserem Katalog unter der angegebenen ID, haben aber **völlig anderen inhaltlichen Text** als der offizielle Katalog. Die offiziellen Fragen bei diesen IDs behandeln andere Themen (meist Verhalten im Straßenverkehr, Rechtsfragen, praktische Hundehaltung).

Vermutlich wurden diese Fragen in einer früheren Version der App selbst hinzugefügt (Themen: Tiermedizin/Symptome/Impfungen) und überschreiben oder ergänzen die offiziellen Fragen.

### Betroffene IDs und Themen:

| ID | Unsere Frage | Offizielle Frage |
|---|---|---|
| 53 | Hunderasse für Allergiker | Fremder Hund stürmt auf Kind zu |
| 95 | Impfungen gesetzlich vorgeschrieben | Reiter begegnet |
| 102 | Parasitenbekämpfung | Kinder spielen Fußball auf Wiese |
| 104 | Impfungen empfohlen | Hundekot-Entfernung |
| 106 | Juckreiz Ursachen | Kinderspielplatz |
| 108 | Zeckenschutz | Leinenpflicht |
| 111 | Zecken entfernen | Jogger begegnet |
| 116 | Zecken-übertragene Krankheiten | Kinder Picknick auf Hundewiese |
| 128 | Durch Impfung vermeidbare Krankheiten | Angstliche Menschen begegnen |
| 142 | Vergiftungs-Symptome | Durchfall/Erbrechen seit 2 Tagen |
| 144 | Ohrenentzündung Symptome | Zoonosen |
| 146 | Bewegungsapparat-Symptome | Magendrehung |
| 152 | Durchfall | Zahngesundheit |
| 154 | Nierenerkrankung Symptome | Flohbefall |
| 156 | Herzerkrankung Symptome | Geflügel füttern |
| 176 | Lebererkrankung Symptome | Zecken-übertragene Krankheiten |
| 180 | Bauchspeicheldrüse Symptome | Sinnvolle Impfungen |
| 181 | Staupevirus Symptome | Importhunde-Krankheiten |
| 189 | Übergewicht vermeiden | Verhaltensänderung nach Kastration |
| 191 | Parvovirus Symptome | Schwierigkeiten durch Importhunde |

### Plus 2 kleine Textabweichungen (Wortlaut leicht anders):
- Q51: "einem anderen Hund" vs "einen anderen Hund" (Grammatik)
- Q126: "Was sind Verhaltensweisen..." vs "Welche Verhaltensweisen..."
- Q169: minimal andere Formulierung

---

## 3. Frage 85 — Keine offizielle Lösung

Q85 ("In welcher Situation können Hunde aggressiv reagieren?") hat keine Lösung im offiziellen Lösungs-PDF.
Unsere Lösung `[A, B, C]` bleibt unverändert (fachlich korrekt).

---

## 4. Empfehlung

1. **Sofort erledigt:** 5 korrigierte Lösungen sind committed.
2. **Nächster Schritt:** Die ~20 inhaltlich abweichenden Fragen sollten gegen die offiziellen Fragen ausgetauscht werden. Dazu muss das offizielle PDF-Parsing verbessert werden (Matrix-Layout mit geteilten Antwort-Pools), oder die Fragen werden manuell aus dem PDF übertragen.
3. **Langfristig:** Das `update_questions.py` Script sollte das neue PDF-Format korrekt parsen können, damit zukünftige Katalog-Updates automatisch funktionieren.
