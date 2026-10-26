#!/usr/bin/env python3
"""Собирает tasks/<тема>/<NN-slug>/THEORY.md из вопросов theory/interview.md по маппингу theory/tasks.map.

Запуск из любого каталога:  python3 theory/build.py
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / "theory" / "interview.md"
MAP = ROOT / "theory" / "tasks.map"
HEADING = re.compile(r"^(#{1,6})\s+(.*?)\s*$")


def parse_sections(lines):
    """Вопрос = заголовок уровня 2–3 вне блоков кода; ответ — до следующего такого заголовка."""
    heads, fence = [], False
    for i, line in enumerate(lines):
        if line.lstrip().startswith("```"):
            fence = not fence
            continue
        m = None if fence else HEADING.match(line)
        if m:
            heads.append((i, len(m.group(1)), m.group(2)))
    sections = {}
    for k, (i, level, title) in enumerate(heads):
        if level > 3:
            continue
        end = next((j for j, lvl, _ in heads[k + 1:] if lvl <= 3), len(lines))
        sections.setdefault(title, (i, end))   # при дублях берём первое вхождение
    return sections


def parse_map(text):
    tasks, current = {}, None
    for raw in text.splitlines():
        line = raw.rstrip()
        if not line or line.startswith("#"):
            continue
        m = re.fullmatch(r"\[([a-z0-9]+-\d{2})\]", line)
        if m:
            current = tasks.setdefault(m.group(1), [])
        elif current is not None:
            current.append(line)
    return tasks


def task_dir(task_id):
    topic, num = task_id.rsplit("-", 1)
    found = sorted((ROOT / "tasks" / topic).glob(f"{num}-*/task.env"))
    return found[0].parent if found else None


def render_answer(lines, start, end, img_prefix):
    body, fence = [], False
    for line in lines[start + 1:end]:
        if line.lstrip().startswith("```"):
            fence = not fence
        elif not fence:
            m = HEADING.match(line)
            if m:   # вложенные заголовки ответа опускаем на уровень ниже вопроса
                line = "#" * max(len(m.group(1)), 3) + " " + m.group(2) + "\n"
            line = line.replace("](/imgs/", f"]({img_prefix}imgs/").replace("](imgs/", f"]({img_prefix}imgs/")
        body.append(line)
    text = "".join(body).rstrip()
    while text.endswith("---"):   # у ответов в interview.md свои разделители в конце
        text = text[:-3].rstrip()
    return text.strip("\n")


def main():
    lines = SOURCE.read_text(encoding="utf-8").splitlines(keepends=True)
    sections = parse_sections(lines)
    tasks = parse_map(MAP.read_text(encoding="utf-8"))
    errors = 0
    for task_id, entries in tasks.items():
        d = task_dir(task_id)
        if d is None:
            print(f"[!] {task_id}: каталог задачи не найден", file=sys.stderr)
            errors += 1
            continue
        notes = [e[2:] for e in entries if e.startswith("> ")]
        questions = [e for e in entries if not e.startswith("> ")]
        rel = "../" * len(d.relative_to(ROOT).parts)
        out = [f"# {task_id} · Теория\n",
               f"Вопросы с ответами из [theory/interview.md]({rel}theory/interview.md), относящиеся к этой задаче.",
               "Файл собирается автоматически (`python3 theory/build.py`): правь ответы в interview.md, "
               "а список вопросов — в theory/tasks.map.\n"]
        out += [f"> {n}\n" for n in notes]
        found = [q for q in questions if q in sections]
        for q in questions:
            if q not in sections:
                print(f"[!] {task_id}: вопрос не найден в interview.md: {q}", file=sys.stderr)
                errors += 1
        out.append("**Вопросы:**\n")
        out += [f"{n}. {q}" for n, q in enumerate(found, 1)]
        for q in found:
            start, end = sections[q]
            out += ["\n---\n", f"## {q}\n", render_answer(lines, start, end, rel + "theory/")]
        (d / "THEORY.md").write_text("\n".join(out).rstrip() + "\n", encoding="utf-8")
        print(f"{task_id}: {len(found)} вопр. → {d.relative_to(ROOT)}/THEORY.md")
    sys.exit(1 if errors else 0)


if __name__ == "__main__":
    main()
