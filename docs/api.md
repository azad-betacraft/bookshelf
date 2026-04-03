# BookShelf API Documentation

## Table of Contents

- [Response Envelope](#response-envelope)
- [Pagination](#pagination)
- [Sorting](#sorting)
- [Error Responses](#error-responses)
- [Authors](#authors)
  - [GET /api/authors](#get-apiauthors)
  - [GET /api/authors/:id](#get-apiauthorsid)
  - [POST /api/authors](#post-apiauthors)
  - [PUT /api/authors/:id](#put-apiauthorsid)
  - [DELETE /api/authors/:id](#delete-apiauthorsid)
  - [GET /api/authors/:author_id/books](#get-apiauthorsauthor_idbooks)

---

## Response Envelope

All successful responses are wrapped in a standard envelope:

```json
{
  "data": { ... },
  "meta": { ... }
}
```

- `data` — the response payload (object or array)
- `meta` — included on paginated list endpoints (see [Pagination](#pagination))

## Pagination

List endpoints support pagination via query parameters:

| Parameter  | Type    | Default | Constraints       |
|------------|---------|---------|-------------------|
| `page`     | integer | `1`     | Must be >= 1      |
| `per_page` | integer | `20`    | Must be 1–100     |

Paginated responses include a `meta` object:

```json
{
  "meta": {
    "page": 1,
    "per_page": 20,
    "total_items": 42,
    "total_pages": 3
  }
}
```

## Sorting

List endpoints that support sorting accept these query parameters:

| Parameter    | Type   | Default     | Constraints                          |
|--------------|--------|-------------|--------------------------------------|
| `sort_by`    | string | (per-route) | Must be one of the allowed fields    |
| `sort_order` | string | `"asc"`     | `"asc"` or `"desc"`                  |

Invalid sort fields or orders return a `400 BAD_REQUEST` error.

## Error Responses

All errors follow this format:

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable message",
    "details": [...]
  }
}
```

`details` is only present on validation errors.

| HTTP Status | Code                | When                                          |
|-------------|---------------------|-----------------------------------------------|
| 400         | `BAD_REQUEST`       | Invalid JSON, invalid pagination/sort params  |
| 404         | `NOT_FOUND`         | Record not found                              |
| 409         | `DEPENDENCY_EXISTS` | Deleting a record that has dependent records  |
| 422         | `VALIDATION_ERROR`  | Model validation failures                     |

---

## Authors

### GET /api/authors

Returns a paginated list of authors.

#### Request

- **Query Parameters**

  | Parameter  | Type    | Default       | Description                              |
  |------------|---------|---------------|------------------------------------------|
  | `page`     | integer | `1`           | Page number (see [Pagination](#pagination)) |
  | `per_page` | integer | `20`          | Items per page (1–100)                   |
  | `sort_by`  | string  | `"last_name"` | Sort field. Allowed: `last_name`, `first_name`, `created_at`, `book_count` |
  | `sort_order` | string | `"asc"`      | `"asc"` or `"desc"`                     |
  | `search`   | string  | —             | Case-insensitive search on first and last name |

#### Response

- **200 OK**

```json
{
  "data": [
    {
      "id": 1,
      "first_name": "Ursula",
      "last_name": "Le Guin",
      "bio": "American author best known for...",
      "birth_year": 1929,
      "death_year": 2018,
      "website": "https://www.ursulakleguin.com",
      "created_at": "2026-01-15T10:30:00.000Z",
      "updated_at": "2026-01-15T10:30:00.000Z",
      "book_count": 5
    }
  ],
  "meta": {
    "page": 1,
    "per_page": 20,
    "total_items": 1,
    "total_pages": 1
  }
}
```

- **400 Bad Request** — invalid `sort_by`, `sort_order`, `page`, or `per_page` values

```json
{
  "error": {
    "code": "BAD_REQUEST",
    "message": "Invalid sort field: foo. Allowed: last_name, first_name, created_at, book_count"
  }
}
```

#### Example

```bash
curl http://localhost:3000/api/authors?search=leguin&sort_by=last_name&sort_order=asc&page=1&per_page=10
```

---

### GET /api/authors/:id

Returns a single author with their 5 most recently added books.

#### Request

- **URL Parameters**

  | Parameter | Type    | Description |
  |-----------|---------|-------------|
  | `id`      | integer | Author ID   |

#### Response

- **200 OK**

```json
{
  "data": {
    "id": 1,
    "first_name": "Ursula",
    "last_name": "Le Guin",
    "bio": "American author best known for...",
    "birth_year": 1929,
    "death_year": 2018,
    "website": "https://www.ursulakleguin.com",
    "created_at": "2026-01-15T10:30:00.000Z",
    "updated_at": "2026-01-15T10:30:00.000Z",
    "book_count": 5,
    "recent_books": [
      {
        "id": 10,
        "title": "The Left Hand of Darkness",
        "isbn": "9780441478125",
        "author_id": 1,
        "published_year": 1969,
        "genre": "science_fiction",
        "description": "A groundbreaking work...",
        "page_count": 304,
        "language": "en",
        "rating": 4.5,
        "read_status": "read",
        "date_added": "2026-01-15T10:30:00.000Z",
        "created_at": "2026-01-15T10:30:00.000Z",
        "updated_at": "2026-01-15T10:30:00.000Z",
        "author_name": "Ursula Le Guin"
      }
    ]
  }
}
```

- **404 Not Found** — author with given ID does not exist

```json
{
  "error": {
    "code": "NOT_FOUND",
    "message": "Couldn't find Author with 'id'=999"
  }
}
```

#### Example

```bash
curl http://localhost:3000/api/authors/1
```

---

### POST /api/authors

Creates a new author.

#### Request

- **Headers** — `Content-Type: application/json` (required)
- **Request Body**

  | Field        | Type    | Required | Constraints                                   |
  |--------------|---------|----------|-----------------------------------------------|
  | `first_name` | string  | Yes      | Max 100 characters. HTML stripped, whitespace trimmed. |
  | `last_name`  | string  | Yes      | Max 100 characters. HTML stripped, whitespace trimmed. |
  | `bio`        | string  | No       | Max 2000 characters                           |
  | `birth_year` | integer | No       | Must be <= current year                       |
  | `death_year` | integer | No       | Must be >= `birth_year` if both provided      |
  | `website`    | string  | No       | Must be a valid HTTP or HTTPS URL             |

```json
{
  "author": {
    "first_name": "Ursula",
    "last_name": "Le Guin",
    "bio": "American author best known for...",
    "birth_year": 1929,
    "death_year": 2018,
    "website": "https://www.ursulakleguin.com"
  }
}
```

#### Response

- **201 Created**

```json
{
  "data": {
    "id": 1,
    "first_name": "Ursula",
    "last_name": "Le Guin",
    "bio": "American author best known for...",
    "birth_year": 1929,
    "death_year": 2018,
    "website": "https://www.ursulakleguin.com",
    "created_at": "2026-01-15T10:30:00.000Z",
    "updated_at": "2026-01-15T10:30:00.000Z",
    "book_count": 0
  }
}
```

- **400 Bad Request** — invalid JSON in request body

```json
{
  "error": {
    "code": "BAD_REQUEST",
    "message": "Invalid JSON in request body"
  }
}
```

- **422 Unprocessable Entity** — validation failures

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": [
      { "field": "first_name", "message": "can't be blank" },
      { "field": "website", "message": "is invalid" }
    ]
  }
}
```

#### Example

```bash
curl -X POST http://localhost:3000/api/authors \
  -H "Content-Type: application/json" \
  -d '{"author": {"first_name": "Ursula", "last_name": "Le Guin", "birth_year": 1929}}'
```

---

### PUT /api/authors/:id

Updates an existing author.

#### Request

- **Headers** — `Content-Type: application/json` (required)
- **URL Parameters**

  | Parameter | Type    | Description |
  |-----------|---------|-------------|
  | `id`      | integer | Author ID   |

- **Request Body** — same fields as [POST /api/authors](#post-apiauthors), all optional. Only provided fields are updated.

```json
{
  "author": {
    "bio": "Updated biography text."
  }
}
```

#### Response

- **200 OK** — returns the updated author (same shape as POST response)

```json
{
  "data": {
    "id": 1,
    "first_name": "Ursula",
    "last_name": "Le Guin",
    "bio": "Updated biography text.",
    "birth_year": 1929,
    "death_year": 2018,
    "website": "https://www.ursulakleguin.com",
    "created_at": "2026-01-15T10:30:00.000Z",
    "updated_at": "2026-01-16T08:00:00.000Z",
    "book_count": 5
  }
}
```

- **404 Not Found** — author does not exist
- **422 Unprocessable Entity** — validation failures (same format as POST)

#### Example

```bash
curl -X PUT http://localhost:3000/api/authors/1 \
  -H "Content-Type: application/json" \
  -d '{"author": {"bio": "Updated biography text."}}'
```

---

### DELETE /api/authors/:id

Deletes an author. Fails if the author has any associated books.

#### Request

- **URL Parameters**

  | Parameter | Type    | Description |
  |-----------|---------|-------------|
  | `id`      | integer | Author ID   |

#### Response

- **204 No Content** — author deleted successfully (empty response body)

- **404 Not Found** — author does not exist

```json
{
  "error": {
    "code": "NOT_FOUND",
    "message": "Couldn't find Author with 'id'=999"
  }
}
```

- **409 Conflict** — author has associated books

```json
{
  "error": {
    "code": "DEPENDENCY_EXISTS",
    "message": "Cannot delete author: 3 books are associated with this author"
  }
}
```

#### Example

```bash
curl -X DELETE http://localhost:3000/api/authors/1
```

---

### GET /api/authors/:author_id/books

Returns a paginated list of books belonging to a specific author.

#### Request

- **URL Parameters**

  | Parameter   | Type    | Description |
  |-------------|---------|-------------|
  | `author_id` | integer | Author ID   |

- **Query Parameters**

  | Parameter    | Type    | Default        | Description                              |
  |--------------|---------|----------------|------------------------------------------|
  | `page`       | integer | `1`            | Page number (see [Pagination](#pagination)) |
  | `per_page`   | integer | `20`           | Items per page (1–100)                   |
  | `sort_by`    | string  | `"date_added"` | Sort field. Allowed: `title`, `published_year`, `date_added`, `rating`, `page_count` |
  | `sort_order` | string  | `"asc"`        | `"asc"` or `"desc"`                     |

#### Response

- **200 OK**

```json
{
  "data": [
    {
      "id": 10,
      "title": "The Left Hand of Darkness",
      "isbn": "9780441478125",
      "author_id": 1,
      "published_year": 1969,
      "genre": "science_fiction",
      "description": "A groundbreaking work...",
      "page_count": 304,
      "language": "en",
      "rating": 4.5,
      "read_status": "read",
      "date_added": "2026-01-15T10:30:00.000Z",
      "created_at": "2026-01-15T10:30:00.000Z",
      "updated_at": "2026-01-15T10:30:00.000Z",
      "author_name": "Ursula Le Guin"
    }
  ],
  "meta": {
    "page": 1,
    "per_page": 20,
    "total_items": 5,
    "total_pages": 1
  }
}
```

- **404 Not Found** — author does not exist

```json
{
  "error": {
    "code": "NOT_FOUND",
    "message": "Couldn't find Author with 'id'=999"
  }
}
```

- **400 Bad Request** — invalid sort or pagination params

#### Example

```bash
curl http://localhost:3000/api/authors/1/books?sort_by=rating&sort_order=desc&page=1&per_page=10
```
