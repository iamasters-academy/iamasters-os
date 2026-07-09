---
name: backend-development
description: Diseño de APIs, arquitectura de base de datos, patrones de microservicios y desarrollo guiado por tests (TDD). Úsala cuando el operador diga o pida "diseña la API", "estructura la base de datos", "esquema de BBDD", "arquitectura backend", "endpoints REST", "modela el backend de esto" o construya la capa de servidor. Paso de implementación en la cadena de construir web/app.
source: wshobson/agents
license: MIT
---

# Backend Development

## API Design

### RESTful Conventions
```
GET    /users          # List users
POST   /users          # Create user
GET    /users/:id      # Get user
PUT    /users/:id      # Update user (full)
PATCH  /users/:id      # Update user (partial)
DELETE /users/:id      # Delete user

GET    /users/:id/posts  # List user's posts
POST   /users/:id/posts  # Create post for user
```

### Response Format
```json
{
  "data": { ... },
  "meta": {
    "page": 1,
    "per_page": 20,
    "total": 100
  }
}
```

### Error Format
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input",
    "details": [
      { "field": "email", "message": "Invalid format" }
    ]
  }
}
```

## Database Patterns

### Schema Design
```sql
-- Use UUIDs for public IDs
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  public_id UUID DEFAULT gen_random_uuid() UNIQUE,
  email VARCHAR(255) UNIQUE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Soft deletes
ALTER TABLE users ADD COLUMN deleted_at TIMESTAMPTZ;

-- Indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_created ON users(created_at DESC);
```

### Query Patterns
```sql
-- Pagination with cursor
SELECT * FROM posts
WHERE created_at < $cursor
ORDER BY created_at DESC
LIMIT 20;

-- Efficient counting
SELECT reltuples::bigint AS estimate
FROM pg_class WHERE relname = 'users';
```

## Authentication

### JWT Pattern
```typescript
interface TokenPayload {
  sub: string;      // User ID
  iat: number;      // Issued at
  exp: number;      // Expiration
  scope: string[];  // Permissions
}
```

### Middleware
```typescript
async function authenticate(req: Request, res: Response, next: Next) {
  const token = req.headers.authorization?.replace('Bearer ', '');
  if (!token) return res.status(401).json({ error: 'Unauthorized' });
  // ... verification logic
}
```

## Caching Strategy

```typescript
// Cache-aside pattern
async function getUser(id: string): Promise<User> {
  const cached = await redis.get(`user:${id}`);
  if (cached) return JSON.parse(cached);

  const user = await db.users.findById(id);
  await redis.setex(`user:${id}`, 3600, JSON.stringify(user));
  return user;
}
```

## Observability

- **Logging**: Structured JSON logs with request IDs
- **Metrics**: Request latency, error rates, queue depths
- **Tracing**: Distributed tracing with correlation IDs
- **Health checks**: `/health` and `/ready` endpoints

## Referencias

- [wshobson/agents — backend-development](https://github.com/wshobson/agents) — Base original de la skill
- Licencia: MIT
