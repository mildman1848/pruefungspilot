# scripts/update_questions.py – Skript zum Download, OCR und Update von questions.json.

import hashlib
import json
import os
import re
from pathlib import Path

import fitz  # pymupdf für PDF-Text-Extraktion und Image-Extraction
import pytesseract  # Für OCR, falls textbasiert nicht möglich
import requests
from PIL import Image

# PDF-URLs (aktualisiere bei Bedarf)
QUESTIONS_URL = "https://www.tieraerztekammer-nordrhein.de/wp-content/uploads/2024/11/Sachkundefragen-neu-ab-01.01.2025.pdf"
SOLUTIONS_URL = "https://www.tieraerztekammer-nordrhein.de/wp-content/uploads/2024/11/Sachkundefragen-Loesungen-neu-ab-01.01.2025.pdf"

REQUEST_HEADERS = {
    "User-Agent": "Mozilla/5.0 (compatible; pruefungspilot PDF updater; +https://github.com/mildman1848/pruefungspilot)",
    "Accept": "application/pdf,*/*",
}

# Lokale Pfade
BASE_DIR = Path(__file__).resolve().parent.parent
QUESTIONS_PDF = BASE_DIR / "temp_questions.pdf"
SOLUTIONS_PDF = BASE_DIR / "temp_solutions.pdf"
JSON_PATH = BASE_DIR / "assets/questions.json"
IMAGES_DIR = BASE_DIR / "assets/images"  # Verzeichnis für extrahierte Bilder

# Stelle sicher, dass Verzeichnisse existieren
os.makedirs(IMAGES_DIR, exist_ok=True)

def download_pdf(url, path):
    """PDF herunterladen."""
    response = requests.get(url, headers=REQUEST_HEADERS, timeout=60)
    content_type = response.headers.get("content-type", "").lower()
    if (
        response.status_code == 200
        and response.content.startswith(b"%PDF")
        and ("pdf" in content_type or content_type == "application/octet-stream")
    ):
        with open(path, 'wb') as f:
            f.write(response.content)
        return True
    print(f"Failed to download PDF: {url} status={response.status_code} content-type={content_type}")
    return False

def get_pdf_hash(path):
    """Hash der PDF berechnen."""
    if os.path.exists(path):
        hasher = hashlib.sha256()
        with open(path, 'rb') as f:
            hasher.update(f.read())
        return hasher.hexdigest()
    return None

def check_pdf_changed(url, local_path):
    """Prüfen, ob PDF geändert (Head-Request für Last-Modified, fallback Hash)."""
    try:
        requests.head(url, headers=REQUEST_HEADERS, timeout=30)
    except requests.RequestException as exc:
        print(f"HEAD request failed for {url}: {exc}; falling back to GET")

    if os.path.exists(local_path):
        # Wenn ETag oder Last-Modified verfügbar, vergleichen (einfach, da local keine Metadaten speichert)
        # Für Einfachheit: Immer Hash vergleichen, wenn Download klein ist
        temp_path = local_path.with_suffix(f"{local_path.suffix}.download")
        if download_pdf(url, temp_path):
            new_hash = get_pdf_hash(temp_path)
            old_hash = get_pdf_hash(local_path)
            changed = old_hash != new_hash
            if changed:
                os.replace(temp_path, local_path)  # Ersetze local mit new
            else:
                os.remove(temp_path)
            return changed
    else:
        if download_pdf(url, local_path):
            return True
        raise FileNotFoundError(f"Failed to download required PDF from {url}")
    return False

def extract_text_from_pdf(path):
    """Text aus PDF extrahieren (Text-based oder OCR)."""
    doc = fitz.open(path)
    text = ""
    for page in doc:
        page_text = page.get_text()
        if page_text.strip():  # Text-based
            text += page_text + "\n"
        else:  # Image-based, OCR
            pix = page.get_pixmap()
            img = Image.frombytes("RGB", [pix.width, pix.height], pix.samples)
            text += pytesseract.image_to_string(img, lang='deu') + "\n"
    doc.close()
    return text

def extract_images_from_pdf(path):
    """Bilder aus PDF extrahieren und speichern."""
    doc = fitz.open(path)
    images = {}
    for page_num, page in enumerate(doc):
        image_list = page.get_images(full=True)
        for img_index, img in enumerate(image_list):
            xref = img[0]
            base_image = doc.extract_image(xref)
            image_bytes = base_image["image"]
            image_ext = base_image["ext"]
            image_path = IMAGES_DIR / f"question_page{page_num}_img{img_index}.{image_ext}"
            with open(image_path, "wb") as image_file:
                image_file.write(image_bytes)
            images[(page_num, img_index)] = str(image_path)
    doc.close()
    return images

def parse_to_json(questions_text, solutions_text):
    """Text parsen zu JSON-Struktur."""
    questions = []
    current_question = None
    answers = []
    id = None
    question_str = ""
    in_answers = False

    # Parse Questions
    lines = questions_text.split('\n')
    for line in lines:
        line = line.strip()
        if line and line.startswith('| ') and 'Welchen Ausdruck' in line:  # Frage-Start (anpassen an reales Format)
            if current_question:
                current_question['answers'] = answers
                questions.append(current_question)
            parts = line.split('|')
            if len(parts) > 1:
                id_str = parts[1].strip()
                if id_str.isdigit():
                    id = int(id_str)
                    question_str = ' '.join(parts[2:]).strip() if len(parts) > 2 else ""
                    current_question = {"id": id, "question": question_str, "answers": [], "correctAnswers": [], "image": None}
                    answers = []
                    in_answers = True
        elif in_answers and line.startswith('| '):
            parts = line.split('|')
            if len(parts) > 1 and parts[1].strip() in ['A.', 'B.', 'C.', 'D.']:
                answer = ' '.join(parts[2:]).strip() if len(parts) > 2 else ""
                answers.append(answer.replace('.', ''))
    if current_question:
        current_question['answers'] = answers
        questions.append(current_question)

    # Parse Solutions
    solutions = {}
    lines = solutions_text.split('\n')
    in_table = False
    for line in lines:
        line = line.strip()
        if line.startswith('| Frage Nr. | Lösung |'):
            in_table = True
            continue
        if in_table and line.startswith('| ') and ' | ' in line:
            parts = line.split(' | ')
            if len(parts) >= 3:
                q_id_str = parts[1].strip()
                sol = parts[2].strip()
                if q_id_str.isdigit():
                    q_id = int(q_id_str)
                    correct_letters = re.split(r',\s*', sol)
                    solutions[q_id] = [ord(letter) - ord('A') for letter in correct_letters if letter in 'ABCD']

    # Match Solutions to Questions und Images hinzufügen (bei "zeigt dieser Hund")
    for q in questions:
        if q['id'] in solutions:
            q['correctAnswers'] = solutions[q['id']]
        if 'zeigt dieser Hund' in q['question']:
            q['image'] = f"assets/images/question_{q['id']}.png"  # Annahme: Extrahierte Images benennen

    return questions


def parse_solutions_map(solutions_text):
    """Parse the solutions PDF text into question id -> correct answer indexes.

    The chamber PDF is not emitted as a markdown table. PyMuPDF returns it as
    alternating lines, e.g. ``Frage Nr.``, ``Lösung``, ``6``, ``C``.
    Keep this parser deliberately conservative so ambiguous rows do not corrupt
    the existing local question bank.
    """
    solutions = {}
    lines = [line.strip() for line in solutions_text.split('\n') if line.strip()]
    answer_re = re.compile(r'^[ABCD](?:,\s*[ABCD])*$')
    for idx, line in enumerate(lines[:-1]):
        if not re.fullmatch(r'\d{1,3}', line):
            continue
        answer_line = lines[idx + 1].replace(' ', '')
        if not answer_re.fullmatch(answer_line):
            continue
        q_id = int(line)
        answers = [ord(letter) - ord('A') for letter in answer_line.split(',') if letter in 'ABCD']
        if answers:
            solutions[q_id] = answers
    return solutions


def update_existing_questions_with_solutions(existing_questions, solutions):
    """Return existing questions with refreshed correctAnswers where possible."""
    updated = []
    changed = False
    for item in existing_questions:
        q = dict(item)
        q_id = q.get('id')
        if isinstance(q_id, int) and q_id in solutions and q.get('correctAnswers') != solutions[q_id]:
            q['correctAnswers'] = solutions[q_id]
            changed = True
        updated.append(q)
    return updated, changed

def update_json():
    """Hauptfunktion: Prüfen, Download, Extraktion, Update."""
    changed = False
    if check_pdf_changed(QUESTIONS_URL, QUESTIONS_PDF):
        changed = True
    if check_pdf_changed(SOLUTIONS_URL, SOLUTIONS_PDF):
        changed = True

    if changed:
        questions_text = extract_text_from_pdf(QUESTIONS_PDF)
        solutions_text = extract_text_from_pdf(SOLUTIONS_PDF)
        # Images extrahieren (optional, falls benötigt)
        extract_images_from_pdf(QUESTIONS_PDF)  # Extrahiert alle Bilder
        data = parse_to_json(questions_text, solutions_text)
        if not data:
            print(
                "PDFs were downloaded, but the question layout was not parsed. "
                "Keeping existing questions.json and refreshing solutions where possible."
            )
            if not JSON_PATH.exists():
                raise RuntimeError(
                    "PDFs were downloaded, but no questions were parsed and no existing "
                    "questions.json is available as a safe fallback."
                )
            with open(JSON_PATH, 'r', encoding='utf-8') as f:
                existing = json.load(f)
            if not isinstance(existing, list) or not existing:
                raise RuntimeError("Existing questions.json is empty or malformed; refusing fallback update.")
            solutions = parse_solutions_map(solutions_text)
            print(
                f"Parsed {len(solutions)} solution rows, but skipped automatic fallback writes "
                "because the question text layout could not be parsed safely."
            )
            print(f"Kept {len(existing)} existing questions unchanged.")
            return
        with open(JSON_PATH, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        print(f"questions.json updated with {len(data)} questions.")
    else:
        print("No changes in PDFs.")

if __name__ == "__main__":
    update_json()
