# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

BookShelf is a Rails 8 API-only app (Ruby 3.4.8, PostgreSQL 17) for personal library management. See `specification.md` (project root) for the complete product spec and `engineering.md` for the architectural plan.

## Commands

```bash
bin/rails db:create db:migrate     # setup databases
bin/rails db:seed                  # seed sample data
bin/rails server                   # start dev server (port 3000)
bundle exec rspec                  # run full test suite
bundle exec rspec spec/models/     # run model specs only
bundle exec rspec spec/requests/   # run request specs only
bundle exec rspec spec/path_spec.rb:42  # run single test by line
bundle exec rubocop                # lint
bundle exec rubocop -a             # lint + auto-fix
bin/rails routes                   # show all routes
```

## Architecture

- **API-only** — no views, JSON responses only, all endpoints under `/api/`
- **Response envelope** — `{ data:, meta: }` for success, `{ error: { code:, message:, details: } }` for errors. Implemented in `ApiResponse` concern, not a gem.
- **Error handling** — custom error hierarchy in `app/errors/` (ApplicationError → NotFoundError, ConflictError, DependencyExistsError, BadRequestError). Global `rescue_from` in `ExceptionHandler` concern.
- **Controllers** — namespaced under `Api::`, each includes `Paginatable`/`Sortable` concerns as needed. Filtering is done per-controller via `apply_filters` chaining model scopes.
- **Serializers** — Alba-based in `app/serializers/`. List vs detail variants (e.g., `AuthorSerializer` vs `AuthorDetailSerializer`).
- **Services** — `IsbnValidator` (ISBN-13 check digit), `StatsCalculator` (aggregate queries), `CollectionPositionManager` (add/remove/reorder with position integrity).
- **Models** — `InputSanitizable` concern strips HTML and trims whitespace on all string attributes before validation.

## Key Business Rules

- Author deletion blocked if books exist (409 DEPENDENCY_EXISTS)
- Book deletion cascades to remove from all collections (DB-level `on_delete: cascade` on collection_books.book_id)
- Collection book positions must be contiguous starting at 1
- ISBN-13 validated with check digit algorithm
- Rating: 0.0–5.0 in 0.5 increments only
- Content-Type enforcement: POST/PUT require `application/json`

## Testing

RSpec with factory_bot, shoulda-matchers. Specs live in:
- `spec/models/` — validations, scopes, associations
- `spec/services/` — ISBN, stats, position manager
- `spec/requests/api/` — endpoint integration tests
- `spec/factories/` — factory definitions
