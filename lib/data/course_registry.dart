// Path: lib/data/course_registry.dart
// Description: Central registry of all available study courses.
// To add a new course: add an entry here, create a questions JSON, and it works
// end-to-end with the existing screens. No further code changes needed.

import 'package:flutter/material.dart';
import '../models/course_model.dart';

/// All available courses in the app, ordered by display priority.
final List<Course> allCourses = [
  // ─── Sachkundenachweis (existing, migrated) ─────────────────────────────
  const Course(
    id: 'sachkundenachweis',
    title: 'Sachkundenachweis',
    subtitle: 'Hundeführung NRW (LHundG)',
    description:
        'Vorbereitung auf den Sachkundenachweis gemäß Landesgefahrverordnung NRW. '
        '197 offizielle Fragen zu Ausdrucksverhalten, Rassen, Training, '
        'Gesundheit, Recht und mehr.',
    icon: Icons.pets,
    primaryColor: Color(0xFF388E3C),
    questionsAsset: 'assets/courses/sachkundenachweis/questions.json',
    categoryTitles: {
      'ausdrucksverhalten_bilder': 'Ausdrucksverhalten Bilder',
      'ausdrucksverhalten_fragen': 'Ausdrucksverhalten Fragen',
      'rassen': 'Rassen',
      'hund_und_kind': 'Hund und Kind',
      'umgang_verstaendnis': 'Umgang und Verständnis',
      'training': 'Training',
      'strafen': 'Strafen',
      'hundewahl': 'Hundewahl',
      'hundebegegnungen': 'Hundebegegnungen',
      'aufzucht': 'Aufzucht',
      'hilfsmittel': 'Hilfsmittel',
      'probleme_verstaendnis': 'Probleme – Verständnis',
      'probleme_ursachen_vorbeugen': 'Probleme – Ursachen und Vorbeugen',
      'probleme_massnahmen': 'Probleme – Maßnahmen',
      'rechtliches': 'Rechtliches',
      'haltung': 'Haltung',
      'gesundheit': 'Gesundheit',
      'geschlechter': 'Geschlechter',
      'krankheiten': 'Krankheiten',
      'oeffentlichkeit': 'Öffentlichkeit',
    },
    questionCategories: {
      'ausdrucksverhalten_bilder': [6, 16, 26, 46, 56, 65, 75],
      'ausdrucksverhalten_fragen': [1, 31, 41, 51, 61, 86, 88, 121, 126, 167],
      'rassen': [2, 12, 161, 171, 184, 185, 186, 187, 196, 197],
      'hund_und_kind': [3, 28, 33, 38, 43, 48, 58, 107, 110, 112],
      'umgang_verstaendnis': [18, 62, 78, 76, 89, 91, 96, 131, 157, 159],
      'training': [70, 134, 136, 141, 143, 147, 162, 164, 165, 166],
      'strafen': [5, 9, 59, 99, 129, 138, 145, 149, 150, 192],
      'hundewahl': [17, 22, 27, 45, 47, 49, 52, 54, 57, 173],
      'hundebegegnungen': [8, 11, 13, 25, 80, 93, 98, 109, 122, 139],
      'aufzucht': [4, 14, 19, 29, 34, 39, 44, 63, 68, 73],
      'hilfsmittel': [7, 10, 15, 20, 36, 84, 87, 90, 100, 168],
      'probleme_verstaendnis': [21, 24, 67, 72, 82, 103, 114, 119, 123, 151],
      'probleme_ursachen_vorbeugen': [85, 117, 132, 153, 155, 169, 172, 190, 193, 195],
      'probleme_massnahmen': [23, 71, 77, 81, 92, 125, 160, 163, 170, 188],
      'rechtliches': [30, 35, 50, 60, 69, 74, 79, 174, 182, 194],
      'haltung': [32, 37, 42, 55, 64, 66, 83, 101, 120, 175],
      'gesundheit': [94, 97, 105, 127, 130, 140, 158, 178, 179, 183],
      'geschlechter': [113, 115, 118, 124, 133, 135, 137, 148, 177, 189],
      'krankheiten': [40, 142, 144, 146, 152, 154, 156, 176, 180, 181],
      'oeffentlichkeit': [53, 95, 102, 104, 106, 108, 111, 116, 128, 191],
    },
  ),

  // ─── Begleithundprüfung (new) ───────────────────────────────────────────
  const Course(
    id: 'begleithund',
    title: 'Begleithundprüfung',
    subtitle: 'BH/VT – VDH-Prüfungsordnung',
    description:
        'Vorbereitung auf die Begleithundprüfung (BH) gemäß VDH-Prüfungsordnung. '
        'Umfassende Fragen zu Unterordnung, Verhalten im Straßenverkehr, '
        'Leinenführigkeit und Theorie der Hundeausbildung.',
    icon: Icons.school,
    primaryColor: Color(0xFF1565C0),
    questionsAsset: 'assets/courses/begleithund/questions.json',
    categoryTitles: {
      'grundlagen': 'Grundlagen der Hundeausbildung',
      'unterordnung': 'Unterordnung (Platz)',
      'strassenverkehr': 'Verhalten im Straßenverkehr',
      'leinenfuehrigkeit': 'Leinenführigkeit',
      'fussgehen': 'Fußgehen',
      'sitz_uebung': 'Sitz-Übung',
      'ablegen': 'Ablegen (Platz Bleib)',
      'heranrufen': 'Heranrufen / Rückruf',
      'vorfuehren': 'Vorführen am Stand',
      'theorie': 'Theorie & Wesen',
      'pruefungsaufbau': 'Prüfungsaufbau & Bewertung',
      'ausruestung': 'Ausrüstung & Hilfsmittel',
    },
    questionCategories: {
      'grundlagen': [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
      'unterordnung': [11, 12, 13, 14, 15, 16, 17, 18, 19, 20],
      'strassenverkehr': [21, 22, 23, 24, 25, 26, 27, 28, 29, 30],
      'leinenfuehrigkeit': [31, 32, 33, 34, 35, 36, 37, 38, 39, 40],
      'fussgehen': [41, 42, 43, 44, 45, 46, 47, 48, 49, 50],
      'sitz_uebung': [51, 52, 53, 54, 55, 56, 57, 58, 59, 60],
      'ablegen': [61, 62, 63, 64, 65, 66, 67, 68, 69, 70],
      'heranrufen': [71, 72, 73, 74, 75, 76, 77, 78, 79, 80],
      'vorfuehren': [81, 82, 83, 84, 85, 86, 87, 88, 89, 90],
      'theorie': [91, 92, 93, 94, 95, 96, 97, 98, 99, 100],
      'pruefungsaufbau': [101, 102, 103, 104, 105, 106, 107, 108, 109, 110],
      'ausruestung': [111, 112, 113, 114, 115],
    },
  ),

  // ─── FiButroniker (new) ─────────────────────────────────────────────────
  const Course(
    id: 'fibutroniker',
    title: 'FiButroniker',
    subtitle: 'Digitale Kanzlei (IFU / ISM)',
    description:
        'Vorbereitung auf die Zertifizierung zum/zur FiButroniker/in (IFU / ISM). '
        'Themen: Digitale Prozesswelt, KI-Einsatz, eRechnung, Cyber Security, '
        'RPA, GoBD, Datenanalyse und Changemanagement.',
    icon: Icons.analytics,
    primaryColor: Color(0xFF00897B),
    questionsAsset: 'assets/courses/fibutroniker/questions.json',
    categoryTitles: {
      'digitale_prozesswelt': 'Digitale Prozesswelt & Change-Management',
      'geschaeftsprozessanalyse': 'Geschäftsprozessanalyse',
      'schnittstellen_daten': 'Schnittstellen & Datenmanagement',
      'erechnung': 'eRechnung',
      'datenschutz_gobd': 'Datenschutz & GoBD',
      'cyber_security': 'Cyber Security & Notfallpläne',
      'ki_kanzlei': 'KI-Einsatz in der Kanzlei',
      'rpa': 'Robotic Process Automation (RPA)',
      'finanzverwaltung': 'Digitale Zusammenarbeit mit Finanzverwaltung',
      'lohnbuchhaltung': 'Automatisierung Lohnbuchhaltung',
      'finanzbuchhaltung': 'Automatisierung Finanzbuchhaltung',
      'datenanalyse': 'Datenanalyse & Dashboards',
    },
    questionCategories: {
      'digitale_prozesswelt': [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
      'geschaeftsprozessanalyse': [11, 12, 13, 14, 15, 16, 17, 18, 19, 20],
      'schnittstellen_daten': [21, 22, 23, 24, 25, 26, 27, 28, 29, 30],
      'erechnung': [31, 32, 33, 34, 35, 36, 37, 38, 39, 40],
      'datenschutz_gobd': [41, 42, 43, 44, 45, 46, 47, 48, 49, 50],
      'cyber_security': [51, 52, 53, 54, 55, 56, 57, 58, 59, 60],
      'ki_kanzlei': [61, 62, 63, 64, 65, 66, 67, 68, 69, 70],
      'rpa': [71, 72, 73, 74, 75, 76, 77, 78, 79, 80],
      'finanzverwaltung': [81, 82, 83, 84, 85, 86, 87, 88, 89, 90],
      'lohnbuchhaltung': [91, 92, 93, 94, 95, 96, 97, 98, 99, 100],
      'finanzbuchhaltung': [101, 102, 103, 104, 105, 106, 107, 108, 109, 110],
      'datenanalyse': [111, 112, 113, 114, 115, 116, 117, 118, 119, 120],
    },
  ),
];

/// Lookup helper: find a course by ID.
Course? findCourseById(String id) {
  for (final c in allCourses) {
    if (c.id == id) return c;
  }
  return null;
}
