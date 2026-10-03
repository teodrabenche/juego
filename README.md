# La Liguilla 🍻

Juego de beber multijugador para móvil. Todos los móviles van sincronizados en tiempo real (Supabase).

- Cada uno entra con su nombre. Quien se llame **Teo** es el admin.
- 5 rondas de liguilla: Teo inicia/acaba cada ronda y pone los puntos.
- Los 2 primeros son capitanes y eligen equipo desde su móvil, por turnos.
- Juegos por equipos: 🎯 Dardos, 🎳 Bolas, 🏀 Canasta. Teo va pasando de juego y marca quién gana.

Es un único `index.html` estático. Tablas y función `pick_player` en `supabase/schema.sql`.
