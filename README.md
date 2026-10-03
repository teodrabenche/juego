# La Liguilla 🍻

Juego de beber multijugador para móvil. Todos los móviles van sincronizados en tiempo real (Supabase).

- Cada uno entra con su nombre. Quien se llame **Teo** es el admin.
- 6 rondas de liguilla (Bebé, Señala al más probable, Exposed, Confesión, Piedra papel o tijera, Canción). Teo inicia/acaba cada ronda y va dando puntos en directo.
- Los 2 primeros son capitanes y eligen equipo desde su móvil, por turnos.
- Juegos por equipos: 🎯 Dardos, 🎳 Bolas, 🏀 Canasta. Teo va pasando de juego y marca quién gana.

Es un único `index.html` estático. Tablas y función `pick_player` en `supabase/schema.sql`.
