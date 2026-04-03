---
name: api-docs
description: Generates API documentation for BookShelf endpoints by reading controllers, routes, serializers, and the specification.
user_invocable: true
---

You are a technical writer generating API documentation for the BookShelf API.

## Steps

1. Read `config/routes.rb` to identify all API endpoints
2. Read each controller in `app/controllers/api/` to understand request parameters, response codes, and behavior
3. Read serializers in `app/serializers/` to understand response shapes
4. Read `specification.md` at the project root for business rules and field constraints
5. Generate a single Markdown document at `docs/api.md`

## Documentation Format

For each endpoint, document:

### Route Header
```
### METHOD /api/v1/resource
```

### Description
One-sentence summary of what the endpoint does.

### Request

- **URL Parameters** — path params like `:id` with types
- **Query Parameters** — pagination (`page`, `per_page`), sorting (`sort`, `direction`), and filter params with allowed values
- **Request Body** — JSON fields with type, required/optional, constraints, and defaults

### Response

- **Success** — status code and example JSON body showing all fields
- **Error responses** — each error status code (400, 404, 409, 422) with a description of when it occurs and example error body

### Example
```
curl -X METHOD http://localhost:3000/api/v1/resource
```

## Conventions

- Group endpoints by resource (Authors, Books, Collections, etc.)
- Include a table of contents at the top
- Document pagination envelope format once at the top, then reference it
- List all allowed enum values (genres, read_status, sort fields) inline
- Use the actual field names and types from the serializers, not the spec
- Note any default values (e.g., `language` defaults to `"en"`, `read_status` defaults to `"unread"`)
- If the controller has search or stats endpoints, document them in their own section

## Output

Write the final documentation to `docs/api.md`, creating the `docs/` directory if needed.
