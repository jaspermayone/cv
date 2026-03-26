# Resume Bank

A catalog of all resume items — every job, project, skill set, and education entry — organized as ready-to-use LaTeX snippets. Use the generator to build targeted CVs without touching the main `jaspermayone-cv.tex`.

## Quick Start

```bash
./generate.sh
```

Follow the prompts. Use **TAB** to select multiple items, **ENTER** to confirm, **ESC** to skip a section. You'll get a new `.tex` file (and optionally a compiled PDF).

## Structure

```
bank/
├── BANK.yaml              ← master catalog with tags for every item
├── README.md              ← this file
├── templates/
│   ├── header.tex         ← document preamble + name/contact header
│   └── footer.tex         ← \end{document}
└── snippets/
    ├── experience/        ← one .tex per job (12 entries)
    ├── projects/          ← one .tex per project (6 entries)
    ├── education/         ← one .tex per school (3 entries)
    ├── skills/            ← 3 variants: tech, full, av-events
    └── activities/        ← one .tex per activity (3 entries)
```

## Tags

Items in `BANK.yaml` are tagged so you can quickly find what fits a role:

| Tag | Covers |
|-----|--------|
| `tech` | Software, IT, engineering roles |
| `software` | Programming-specific work |
| `leadership` | Managing teams, E-Board, mentoring |
| `support` | IT help desk, tech support |
| `events` | Event coordination and registration |
| `hospitality` | Food service, bussing, guest services |
| `av` | Lighting, audio/visual, Zoom, video |
| `media` | Filming, video editing, production |
| `sales` | Sales rep, client-facing work |
| `admin` | Spreadsheets, PO/rental mgmt, admin tasks |
| `aviation` | Glider operations |

## Adding New Items

1. Create a `.tex` file in the appropriate `snippets/` subdirectory.
   - Content only — no `\documentclass` or `\begin{document}`
   - Start with `\noindent`
   - Match the formatting style of existing snippets
2. Add an entry to `BANK.yaml` with `id`, `snippet` path, and `tags`.

