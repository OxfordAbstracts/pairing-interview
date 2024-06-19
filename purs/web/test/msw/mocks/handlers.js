import { http, HttpResponse } from 'msw'

export const handlers = [
  http.get('http://localhost:8123/abstracts', () => {
    return HttpResponse.json([])
  }),
]
